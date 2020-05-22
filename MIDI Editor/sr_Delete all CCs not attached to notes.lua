-- @description Delete all CCs not attached to notes
-- @version 1.0
-- @changelog
-- + initial release
-- @author Stephan Römer
-- @metapackage
-- @provides
--  [main=main,midi_editor,midi_inlineeditor] .
-- @about
--    # Description
--    * This script deletes all CCs that are not affecting any note data.
--    * The scripts work in the MIDI editor, inline editor and arrange view.
-- @link Forum Thread https://forums.cockos.com/showthread.php?p=1923923



-- Store all CCs to table
function StoreCCs(take, num_ccs)

    local ccs_t = {}

    for c = 0, num_ccs do
        local _, _, _, cc_ppqpos, _, _, _, _ = reaper.MIDI_GetCC(take, c)
        ccs_t[c] = {
            pos = cc_ppqpos,
            del = true
        }
    end
    return ccs_t
end

-- Flag CCs that are under notes
function FlagCCs(ccs_t, take, num_notes)

    for c = 0, #ccs_t do
        for n = 0, num_notes do
            
            local _, _, _, startppqpos, endppqpos, _, _, _ = reaper.MIDI_GetNote(take, n)
            
            if ccs_t[c].pos > startppqpos and ccs_t[c].pos < endppqpos then
                ccs_t[c].del = false -- if CC is under note, flag as "don't delete"
            end
        end
    end
    return ccs_t
end

-- Delete all CCs that don't have notes
function DeleteCCS(take)
    
    local _, num_notes, num_ccs, _ = reaper.MIDI_CountEvts(take)

    local ccs_t = StoreCCs(take, num_ccs)
    local ccs_t = FlagCCs(ccs_t, take, num_notes)
    
    reaper.MIDI_DisableSort( take )
    
    for c = #ccs_t, 0, -1 do
        if ccs_t[c].del == true then
            -- reaper.MIDI_SetCC(take, c, nil, nil, nil, nil, nil, nil, 0, true) -- set values to 0?
            reaper.MIDI_DeleteCC(take, c)
        end
    end
    reaper.MIDI_Sort(take)
end
                

function Main()
        
    -- check, where the user wants to change notes: MIDI editor, inline editor or anywhere else

    local take, item
    local window, _, _ = reaper.BR_GetMouseCursorContext() -- initialize cursor context
    local _, inline_editor, _, _, _, _ = reaper.BR_GetMouseCursorContext_MIDI() -- check if mouse hovers an inline editor

    if window == "midi_editor" then -- MIDI editor focused

        if 	not inline_editor then --  not hovering inline editor
            take = reaper.MIDIEditor_GetTake(reaper.MIDIEditor_GetActive()) -- get take from active MIDI editor
            DeleteCCS(take)
            
        else -- hovering inline editor (will ignore item selection and only change data in the hovered inline editor)
            take = reaper.BR_GetMouseCursorContext_Take() -- get take from mouse
            DeleteCCS(take)
        end
        
    else -- anywhere else (apply to selected items in arrane view)
        
        if reaper.CountSelectedMediaItems(0) ~= 0 then
            for i = 0, reaper.CountSelectedMediaItems(0)-1 do -- loop through all selected items
                item = reaper.GetSelectedMediaItem(0, i) -- get current selected item
                take = reaper.GetActiveTake(item) -- get take of item
                
                if reaper.TakeIsMIDI(take) then -- make sure, that take is MIDI
                    
                    DeleteCCS(take)
                else
                    reaper.ShowMessageBox("The selected item #".. i+1 .." does not contain a MIDI take and won't be altered", "Error", 0)
                end
            end
        else
            reaper.ShowMessageBox("Please select at least one item", "Error", 0)
            return false
        end
    end
reaper.UpdateArrange()
end

Main()
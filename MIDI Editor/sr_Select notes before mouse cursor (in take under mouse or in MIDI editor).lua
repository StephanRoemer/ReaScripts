-- @description Select notes before mouse cursor (in take under mouse or in MIDI editor)
-- @version 1.0
-- @changelog
--  * initial release
-- @author Stephan Römer, with a lot of help from FnA and Julian Sader
-- @provides [main=main,midi_editor,midi_inlineeditor] .
-- @about
--    # Description
--    * This script selects all notes after the mouse cursor in the currently focused MIDI editor or inline editor.
--    * Assign the script in the main action list, as well. That way, the inline editor will be opened automatically 
--    when hovering MIDI takes in the arrangement.
--    * This script works in the MIDI editor and inline editor and partly in the arrangement, as stated above
-- @link https://forums.cockos.com/showthread.php?p=1923923


function Select_Notes(take, item, mouse_pos)

    -- create table for note-ons

    local c, m

    note_on_selection = {}
    for c = 0, 15 do -- channel table
        note_on_selection[c] = {}
        for f = 0, 2, 2 do -- flag table
            note_on_selection[c][f] = {}
        end
    end

    local item_start = reaper.GetMediaItemInfo_Value(item, "D_POSITION") -- get start of item
    local item_start_ppq = reaper.MIDI_GetPPQPosFromProjTime(take, item_start) -- convert item_start_ppq to PPQ
    local mouse_position_ppq = reaper.MIDI_GetPPQPosFromProjTime(take, mouse_pos) -- convert mouse_pos to PPQ

    gotAllOK, MIDIstring = reaper.MIDI_GetAllEvts(take, "") -- write MIDI events to MIDIstring, get all events okay
    if not gotAllOK then reaper.ShowMessageBox("Error while loading MIDI", "Error", 0) return(false) end -- if getting the MIDI data failed
    
    MIDIlen = #MIDIstring -- get string length
    tableEvents = {} -- initialize table, MIDI events will temporarily be stored in this table until they are concatenated into a string again
    local stringPos = 1 -- position in MIDIstring while parsing through events 
    local sum_offset = 0 -- initialize sum_offset (adds all offsets to get the position of every event in ticks)

    while stringPos < MIDIlen-12 do -- parse through all events in the MIDI string, one-by-one, excluding the final 12 bytes, which provides REAPER's All-notes-off end-of-take message
        offset, flags, msg, stringPos = string.unpack("i4Bs4", MIDIstring, stringPos) -- unpack MIDI-string on stringPos
        sum_offset = sum_offset+offset -- add all event offsets to get next start position of event on each iteration
        local event_start = item_start_ppq+sum_offset -- calculate event start position based on item start position
        local event_type = msg:byte(1)>>4 -- save 1st nibble of status byte (contains info about the data type) to event_type, >>4 shifts the channel nibble into oblivion
        
        if event_type == 9 and msg:byte(3) ~= 0 then -- if note-on and velocity is not 0
            local channel = msg:byte(1)&0x0F
            local pitch = msg:byte(2)
            
            -- check if current note-on is already tagged = overlapping note-ons!
            if note_on_selection[channel][flags&2][pitch] then
                reaper.ShowMessageBox("Can't select notes, because overlapping notes were found", "Error", 0)
                return false

            -- note-on before cursor position? select	
            elseif event_start < mouse_position_ppq then
                flags = flags|1 -- select
                note_on_selection[channel][flags&2][pitch] = 1 -- tag note-on for selection

            -- note-on after cursor position? unselect 
            elseif event_start >= mouse_position_ppq then 
                flags = flags&~1 -- unselect
                note_on_selection[channel][flags&2][pitch] = 0 -- tag note-on for non-selection
            end
        
        elseif event_type == 8 or (event_type == 9 and msg:byte(3) == 0) then -- if note-off
                
            local channel = msg:byte(1)&0x0F
            local pitch = msg:byte(2)

            -- note-off anywhere and note-on before cursor? select
            if note_on_selection[channel][flags&2][pitch] == 1 then -- matching note-on tagged for selection?
                flags = flags|1 -- select
                note_on_selection[channel][flags&2][pitch] = nil -- reset tag
            
            -- note-off and note-on after cursor? unselect
            elseif note_on_selection[channel][flags&2][pitch] == 0 then -- matching note-on tagged for non-selection?
                flags = flags&~1 -- unselect
                note_on_selection[channel][flags&2][pitch] = nil -- reset tag
            end
        end
        table.insert(tableEvents, string.pack("i4Bs4", offset, flags, msg)) -- re-pack MIDI string and write to table
    end

    reaper.MIDI_SetAllEvts(take, table.concat(tableEvents) .. MIDIstring:sub(-12))
    reaper.MIDI_Sort(take)
end


-- check, where the user wants to select notes

local window, _, _ = reaper.BR_GetMouseCursorContext() -- initialize cursor context
local _, inline_editor, _, _, _, _ = reaper.BR_GetMouseCursorContext_MIDI() -- check if mouse hovers an inline editor

local mouse_pos = reaper.BR_GetMouseCursorContext_Position() -- get mouse position

if window == "midi_editor" and not inline_editor then -- MIDI editor focused and not hovering inline editor
    local midi_editor = reaper.MIDIEditor_GetActive() -- get active MIDI editor
    local take = reaper.MIDIEditor_GetTake(midi_editor) -- get take from active MIDI editor
    local item = reaper.GetMediaItemTake_Item(take) -- get item from take
    Select_Notes(take, item, mouse_pos) -- execute function

elseif window == "arrange" or inline_editor then -- if user is in the arrangement or hovering the inline editor
    local item = reaper.BR_GetMouseCursorContext_Item() -- get item under mouse
    local take = reaper.BR_GetMouseCursorContext_Take() -- get take under mouse
    
    if not item or not reaper.TakeIsMIDI(take) then -- if no item is hovered, or take is not MIDI
        reaper.ShowMessageBox("No MIDI take found. Please hover a MIDI take", "Error", 0)
        return false

    elseif reaper.BR_IsMidiOpenInInlineEditor(take) then -- if inline editor is active for hovered take
        Select_Notes(take, item, mouse_pos) -- execute function
    
    else  -- if user is hovering a MIDI take but inline editor is closed, open it
        reaper.Main_OnCommand(reaper.NamedCommandLookup('_SWS_SAVEALLSELITEMS1'), 0) -- save selected items
        reaper.Main_OnCommand(40289, 0) -- unselect all items
        reaper.SetMediaItemSelected(item, true) -- select item (under mouse)
        reaper.Main_OnCommand(40847, 0) -- open inline editor on selected item
        reaper.Main_OnCommand(reaper.NamedCommandLookup('_SWS_RESTALLSELITEMS1'), 0) -- restore selected items
        Select_Notes(take, item, mouse_pos) -- execute function
    end
end

reaper.UpdateArrange()
reaper.Undo_OnStateChange2(proj, "Select notes before mouse cursor (in take under mouse or in MIDI editor)")
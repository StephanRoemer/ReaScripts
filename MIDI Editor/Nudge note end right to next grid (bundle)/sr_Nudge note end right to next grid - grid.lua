--  @noindex


-- nudge note end in take in MIDI/inline editor (respect note selection)

local function NudgeNoteEndRightMIDIEditor(take)

    _, notes_count, _, _ = reaper.MIDI_CountEvts(take) -- count notes and save amount to notes_count
    
    if reaper.MIDI_EnumSelNotes(take, -1) ~= -1 then notes_selected = true end -- check, if there are selected notes, set notes_selected to true

    for n = 0, notes_count - 1 do -- loop through all notes
        _, selected, _, _, note_end_pos_ppq, _, _, _ = reaper.MIDI_GetNote(take, n) -- get note data

        note_end = reaper.MIDI_GetProjTimeFromPPQPos(take, note_end_pos_ppq) -- convert note end to seconds
        next_grid = reaper.BR_GetNextGridDivision(note_end) -- get next grid for current note (return value in seconds)
        next_grid_ppq = reaper.MIDI_GetPPQPosFromProjTime(take, next_grid) -- convert next_grid to PPQ
        
        if selected or not notes_selected then -- selected notes always move, unselected only move if no notes are selected
        
            reaper.MIDI_SetNote(take, n, nil, nil, nil, next_grid_ppq, nil, nil, nil, true) -- nudge note end to the next grid
                
        end
    end
    reaper.MIDI_Sort(take)
end


-- nudge note end in selected item(s) in arrange view (ignore note selection)

local function NudgeNoteEndRightArrange(take)
    
    _, notes_count, _, _ = reaper.MIDI_CountEvts(take) -- count notes and save amount to notes_count

    for n = 0, notes_count - 1 do -- loop through all notes
        _, selected, _, _, note_end_pos_ppq, _, _, _ = reaper.MIDI_GetNote(take, n) -- get note data

        note_end = reaper.MIDI_GetProjTimeFromPPQPos(take, note_end_pos_ppq) -- convert note end to seconds
        next_grid = reaper.BR_GetNextGridDivision(note_end) -- get next grid for current note (return value in seconds)
        next_grid_ppq = reaper.MIDI_GetPPQPosFromProjTime(take, next_grid) -- convert next_grid to PPQ
        
        reaper.MIDI_SetNote(take, n, nil, nil, nil, next_grid_ppq, nil, nil, nil, true) -- nudge note end to the next grid
                
    end
    reaper.MIDI_Sort(take)
end


-- check, where the user wants to change notes: MIDI editor, inline editor or anywhere else

local take, item, save_project_grid, save_swing, save_swing_amt, grid
local window, _, _ = reaper.BR_GetMouseCursorContext() -- initialize cursor context
local _, inline_editor, _, _, _, _ = reaper.BR_GetMouseCursorContext_MIDI() -- check if mouse hovers an inline editor

if window == "midi_editor" then -- MIDI editor focused

    if not inline_editor then -- not hovering inline editor
        
        _, save_project_grid, save_swing, save_swing_amt = reaper.GetSetProjectGrid(proj, false) -- backup current grid settings
        take = reaper.MIDIEditor_GetTake(reaper.MIDIEditor_GetActive()) -- get take from active MIDI editor
        grid, _, _ = reaper.MIDI_GetGrid(take) -- get grid value (in quarter note!) from MIDI editor
        reaper.GetSetProjectGrid(proj, true, grid/4, save_swing, save_swing_amt) -- set new grid value according MIDI editor

        NudgeNoteEndRightMIDIEditor(take) -- nudge note end
        
        reaper.GetSetProjectGrid(proj, true, save_project_grid, save_swing, save_swing_amt) -- restore saved grid settings
    
    else -- hovering inline editor (will ignore item selection and only change data in the hovered inline editor)
        take = reaper.BR_GetMouseCursorContext_Take() -- get take from mouse
        
        NudgeNoteEndRightMIDIEditor(take) -- nudge note end
        
    end
        
else -- anywhere else (apply to selected items in arrane view)
    
    if reaper.CountSelectedMediaItems(0) ~= 0 then
        for i = 0, reaper.CountSelectedMediaItems(0)-1 do -- loop through all selected items
            item = reaper.GetSelectedMediaItem(0, i) -- get current selected item
            take = reaper.GetActiveTake(item)
            
            if reaper.TakeIsMIDI(take) then -- make sure, that take is MIDI
                
                NudgeNoteEndRightArrange(take) -- nudge note end

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
reaper.Undo_OnStateChange2(proj, "Nudge note end right to next grid - grid")
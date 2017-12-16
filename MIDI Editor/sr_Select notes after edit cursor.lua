-- @description Select notes after the edit cursor
-- @version 1.0    
-- @author Stephan Römer
-- @about
--    # Description
--    - select all notes, that are located after the edit cursor position
--    - this script works in arrangement, MIDI Editor and Inline Editor
--    - for obvious reasons, this script only works with a single item and will popup a message box, if you have more than one item selected
--
-- @link https://forums.cockos.com/showthread.php?p=1923923
--
-- @provides [main=main,midi_editor,midi_inlineeditor]
-- @changelog
--     v1.0
-- 	  + Initial release

for i = 0, reaper.CountSelectedMediaItems(0)-1 do -- loop through all selected items
    item = reaper.GetSelectedMediaItem(0, i)
    if i > 0 then
        reaper.ShowMessageBox("Please select only one item", "Error" , 0) -- popup error message, if more than 1 item is selected
        return
    else
        for t = 0, reaper.CountTakes(item)-1 do -- Loop through all takes within each selected item
            take = reaper.GetTake(item, t)
            if reaper.TakeIsMIDI(take) then -- make sure, that take is MIDI
                cursor_position = reaper.GetCursorPosition()  -- get edit cursor position 
                cursor_position_ppq = reaper.MIDI_GetPPQPosFromProjTime(take, cursor_position) -- convert to PPQ
                notes = reaper.MIDI_CountEvts(take) -- count notes and save amount to "notes"
            end
        end
    end 
end


reaper.Undo_BeginBlock() reaper.PreventUIRefresh(1)

for n = 0, notes - 1 do -- loop thru all notes
    _, sel, _, start_note, end_note, _, _, _ = reaper.MIDI_GetNote(take, n) -- get selection status, start and end position
    if start_note >= cursor_position_ppq and end_note > cursor_position_ppq then 
		reaper.MIDI_SetNote(take, n, true, nil, nil, nil, nil, nil, nil) -- select note if condition above is true
    else
		reaper.MIDI_SetNote(take, n, false, nil, nil, nil, nil, nil, nil) -- unselect note if condition above is false
    end
end


reaper.PreventUIRefresh(-1) reaper.Undo_EndBlock('Select notes before cursor', 2)

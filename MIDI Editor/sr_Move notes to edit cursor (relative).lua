-- @description Move notes to edit cursor (relative)
-- @version 1.3
-- @changelog
--   code tidying
-- @author Stephan Römer
-- @provides [main=midi_editor] .
-- @about
--    # Description
--    * This script moves all selected notes to the edit cursor and keeps their relative offsets
--	  * wWen the mouse hovers a note, the hovered note is used as offset instead
--    * This script only works in the MIDI Editor
-- @link https://forums.cockos.com/showthread.php?p=1923923

take = reaper.MIDIEditor_GetTake(reaper.MIDIEditor_GetActive()) -- get active take in MIDI editor
cursor_position = reaper.GetCursorPosition()  -- get edit cursor position 
cursor_position_ppq = reaper.MIDI_GetPPQPosFromProjTime(take, cursor_position) -- convert cursor_position to PPQ
_, _, _ = reaper.BR_GetMouseCursorContext() -- initiate "get mouse cursor context"
_, _, note_row, _, _, _ = reaper.BR_GetMouseCursorContext_MIDI() -- get note row under mouse cursor
mouse_pos_ppq = reaper.MIDI_GetPPQPosFromProjTime(take, reaper.BR_GetMouseCursorContext_Position()) -- get mouse position in project time and convert to PPQ

if reaper.MIDI_EnumSelNotes(take, -1) ~= -1 then -- check, if there are selected notes
	_, notes_count, _, _ = reaper.MIDI_CountEvts(take) -- count notes and save amount to notes_count
else
	reaper.ShowMessageBox("please select some notes first", "Error", 0)
	return
end

-- first, check if the mouse cursor is hovering a note
for n = 0, notes_count - 1 do -- loop through all notes
	_, selected_out, _, startppqpos_out, endppqpos_out, _, pitch, _ = reaper.MIDI_GetNote(take, n) -- get selection status, pitch, start and end position
	if selected_out and startppqpos_out < mouse_pos_ppq and endppqpos_out > mouse_pos_ppq and note_row == pitch then -- is the current note the note under the mouse and selected?
		closest_note_offset = startppqpos_out -- get PPQ position from note under mouse cursor
		note_under_mouse = true -- the mouse is hovering a note
		break
	end
end

-- if mouse is NOT hovering a note, find closest note to cursor
if not note_under_mouse then
	for n = 0, notes_count - 1 do -- loop through all notes
		_, selected_out, _, startppqpos_out, endppqpos_out, _, pitch, _ = reaper.MIDI_GetNote(take, n) -- get selection status, pitch, start and end position
		if selected_out then -- check only selected notes
			closest_note_offset = startppqpos_out -- get PPQ position from closest note to cursor, this is always the first selected note, that Reaper's API returns (hooray, no sorting!)
			break -- exit loop, since first selected note was found
		end
	end
end

for n = 0, notes_count - 1 do -- loop through all notes
		_, selected_out, _, startppqpos_out, endppqpos_out, _, _, _ = reaper.MIDI_GetNote(take, n) -- get selection status, start and end position
		if selected_out == true then -- only move selected notes
			reaper.MIDI_SetNote(take, n, true, nil, cursor_position_ppq+startppqpos_out-closest_note_offset, cursor_position_ppq+endppqpos_out-closest_note_offset, nil, nil, nil, true) -- move all other notes to the cursor, keeping ther relative offset
	end
end

reaper.Undo_OnStateChange2(proj, "Move notes to edit cursor (relative)")
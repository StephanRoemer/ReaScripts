-- @description Move notes to edit cursor (relative)
-- @version 1.2
-- @author Stephan Römer
-- @about
--    # Description
--    - this script moves all selected notes to the edit cursor and keeps their relative offsets
--	  - when the mouse hovers a note, the hovered note is used as offset instead
--    - this script only works in the MIDI Editor
--
-- @link https://forums.cockos.com/showthread.php?p=1923923
--
-- @provides [main=midi_editor] .
-- @changelog
--     v1.2 (2018-07-16)
--     + when mouse cursor hovers note, this note is used as offset instead
--     v1.1 (2018-07-16)
--     + Bugfix
--     v1.0 (2018-07-13)
--     + Initial release

take = reaper.MIDIEditor_GetTake(reaper.MIDIEditor_GetActive()) -- get active take in MIDI editor
cursorPosition = reaper.GetCursorPosition()  -- get edit cursor position 
cursorPositionPPQ = reaper.MIDI_GetPPQPosFromProjTime(take, cursorPosition) -- convert cursorPosition to PPQ
_, _, _ = reaper.BR_GetMouseCursorContext() -- initiate "get mouse cursor context"
_, _, noteRow, _, _, _ = reaper.BR_GetMouseCursorContext_MIDI() -- get note row under mouse cursor
mousePosPPQ = reaper.MIDI_GetPPQPosFromProjTime(take, reaper.BR_GetMouseCursorContext_Position()) -- get mouse position in project time and convert to PPQ

if reaper.MIDI_EnumSelNotes(take, -1) ~= -1 then -- check, if there are selected notes
	_, notesCount, _, _ = reaper.MIDI_CountEvts(take) -- count notes and save amount to notesCount
else
	reaper.ShowMessageBox("please select some notes first", "Error", 0)
	return
end

-- first, check if the mouse cursor is hovering a note
for n = 0, notesCount - 1 do -- loop through all notes
	_, selectedOut, _, startppqposOut, endppqposOut, _, pitch, _ = reaper.MIDI_GetNote(take, n) -- get selection status, pitch, start and end position
	if selectedOut and startppqposOut < mousePosPPQ and endppqposOut > mousePosPPQ and noteRow == pitch then -- is the current note the note under the mouse and selected?
		closestNoteOffset = startppqposOut -- get PPQ position from note under mouse cursor
		noteUnderMouse = true -- the mouse is hovering a note
		break
	end
end

-- if mouse is NOT hovering a note, find closest note to cursor
if not noteUnderMouse then
	for n = 0, notesCount - 1 do -- loop through all notes
		_, selectedOut, _, startppqposOut, endppqposOut, _, pitch, _ = reaper.MIDI_GetNote(take, n) -- get selection status, pitch, start and end position
		if selectedOut then -- check only selected notes
			closestNoteOffset = startppqposOut -- get PPQ position from closest note to cursor, this is always the first selected note, that Reaper's API returns (hooray, no sorting!)
			break -- exit loop, since first selected note was found
		end
	end
end

for n = 0, notesCount - 1 do -- loop through all notes
		_, selectedOut, _, startppqposOut, endppqposOut, _, _, _ = reaper.MIDI_GetNote(take, n) -- get selection status, start and end position
		if selectedOut == true then -- only move selected notes
			reaper.MIDI_SetNote(take, n, true, nil, cursorPositionPPQ+startppqposOut-closestNoteOffset, cursorPositionPPQ+endppqposOut-closestNoteOffset, nil, nil, nil, true) -- move all other notes to the cursor, keeping ther relative offset
	end
end

reaper.Undo_OnStateChange2(proj, "Move notes to edit cursor (relative)")
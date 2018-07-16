-- @description Move notes to edit cursor (relative)
-- @version 1.1
-- @author Stephan Römer
-- @about
--    # Description
--    - this script moves all selected notes to the edit cursor and keeps their relative offsets
--    - this script only works in the MIDI Editor
--
-- @link https://forums.cockos.com/showthread.php?p=1923923
--
-- @provides [main=midi_editor] .
-- @changelog
--     v1.0 (2018-07-16)
--     + Bugfix
--     v1.0 (2018-07-13)
--     + Initial release

take = reaper.MIDIEditor_GetTake(reaper.MIDIEditor_GetActive()) -- get active take in MIDI editor
cursorPosition = reaper.GetCursorPosition()  -- get edit cursor position 
cursorPositionPPQ = reaper.MIDI_GetPPQPosFromProjTime(take, cursorPosition) -- convert cursorPosition to PPQ

if reaper.MIDI_EnumSelNotes(take, -1) ~= -1 then -- check, if there are selected notes
	_, notesCount, _, _ = reaper.MIDI_CountEvts(take) -- count notes and save amount to notesCount
else
	reaper.ShowMessageBox("please select some notes first", "Error", 0)
	return
end

-- find closest note to cursor
for n = 0, notesCount - 1 do -- loop through all notes
	_, selectedOut, _, startppqposOut, _, _, _, _ = reaper.MIDI_GetNote(take, n) -- get selection status, start and end position
	if selectedOut == true then -- only find selected notes
		closestNoteOffset = startppqposOut -- get PPQ position from closest note to cursor, this is always the first selected note, that Reaper's API returns (hooray, no sorting!)
		break -- break loop, since closest (1st) note was found
	end
end

for n = 0, notesCount - 1 do -- loop through all notes
	_, selectedOut, _, startppqposOut, endppqposOut, _, _, _ = reaper.MIDI_GetNote(take, n) -- get selection status, start and end position
	if selectedOut == true then -- only move selected notes
		reaper.MIDI_SetNote(take, n, true, nil, cursorPositionPPQ+startppqposOut-closestNoteOffset, cursorPositionPPQ+endppqposOut-closestNoteOffset, nil, nil, nil, true) -- move all other notes to the cursor, keeping ther relative offset
	end
end

reaper.Undo_OnStateChange2(proj, "Move notes to edit cursor (relative)")
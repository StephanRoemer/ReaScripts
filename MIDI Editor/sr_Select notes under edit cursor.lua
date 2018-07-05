-- @description Select notes under edit cursor
-- @version 1.0
-- @author Stephan Römer
-- @about
--    # Description
--    - this script selects the notes under the edit cursor, all other notes will be unselected
--    - this script works in arrangement, the MIDI Editor and Inline Editor
--
-- @link https://forums.cockos.com/showthread.php?p=1923923
--
-- @provides [main=main,midi_editor,midi_inlineeditor] .
-- @changelog
--     v1.0 (2018-07-05)
--     + Initial release

reaper.Undo_BeginBlock()

curEditor = reaper.MIDIEditor_GetActive() -- get current editor
take = reaper.MIDIEditor_GetTake(curEditor) -- get current take opened in editor
editCursorPos = reaper.GetCursorPosition() -- get edit cursor position
editCursor_ppq_pos = reaper.MIDI_GetPPQPosFromProjTime(take, editCursorPos) -- convert project time to PPQ
notesCount, _, _ = reaper.MIDI_CountEvts(take) -- count notes in current take

for n = 0, notesCount - 1 do
	_, selected, _, startppqposOut, endppqposOut, _, _, _ = reaper.MIDI_GetNote(take, n) -- get note start/end position
	if startppqposOut < editCursor_ppq_pos and endppqposOut > editCursor_ppq_pos then -- is current note under the cursor?
		reaper.MIDI_SetNote(take, n, true, nil, nil, nil, nil, nil, nil, true) -- select notes
	else
		reaper.MIDI_SetNote(take, n, false, nil, nil, nil, nil, nil, nil, true) -- unselect notes
	end
end

reaper.Undo_EndBlock("Select notes under edit cursor", -1)

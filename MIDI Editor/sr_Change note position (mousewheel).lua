-- @description Change note position (mousewheel)
-- @version 1.1
-- @author Stephan Römer
-- @about
--    # Description
--    - this script changes the note position via mousewheel
--    - when there is no note selection, only the note under the mouse cursor is altered
--    - this script only works in the MIDI Editor
--
-- @link https://forums.cockos.com/showthread.php?p=1923923
--
-- @provides [main=midi_editor] .
-- @changelog
--     v1.1 (2018-07-12)
--     + some code optimizations
--     v1.0 (2018-07-02)
--     + Initial release

reaper.Undo_BeginBlock()

_,_,_,_,_,_, val = reaper.get_action_context() -- receive mousewheel action
take = reaper.MIDIEditor_GetTake(reaper.MIDIEditor_GetActive()) -- get current take opened in editor
_, _, _ = reaper.BR_GetMouseCursorContext() -- initiate "get mouse cursor context"
_, _, noteRow, _, _, _ = reaper.BR_GetMouseCursorContext_MIDI() -- get note row under mouse cursor
mouse_ppq_pos = reaper.MIDI_GetPPQPosFromProjTime(take, reaper.BR_GetMouseCursorContext_Position()) -- get mouse position in project time and convert to PPQ
notesCount, _, _ = reaper.MIDI_CountEvts(take) -- count notes in current take

-- are there selected notes?
if reaper.MIDI_EnumSelNotes(take, -1) ~= -1 then -- check, if there are selected notes
	notesSelected = true -- set notesSelected to true
end

for n = 0, notesCount - 1 do
	_, selectedOut, _, startppqposOut, endppqposOut, _, pitch, _ = reaper.MIDI_GetNote(take, n) -- get note selection status, start/end position and pitch
	if notesSelected == true then -- if there are selected notes
		if selectedOut == true then -- is current note selected?
			if val > 0 then -- if mousewheel up
				reaper.MIDI_SetNote(take, n, nil, nil, startppqposOut+val, endppqposOut+val, nil, nil, nil, true) -- increase note position by val
			else 			-- if mousewheel down
				reaper.MIDI_SetNote(take, n, nil, nil, startppqposOut+val, endppqposOut+val, nil, nil, nil, true) -- decrease note position by val
			end
		end
	else -- if there are no selected notes, only change the position of the note under the mouse cursor
		if startppqposOut < mouse_ppq_pos and endppqposOut > mouse_ppq_pos and noteRow == pitch then -- is current note the note under the cursor?
			if val > 0 then -- if mousewheel up
				reaper.MIDI_SetNote(take, n, nil, nil, startppqposOut+val, endppqposOut+val, nil, nil, nil, true) -- increase note position by val
			else 			-- if mousewheel down
				reaper.MIDI_SetNote(take, n, nil, nil, startppqposOut+val, endppqposOut+val, nil, nil, nil, true) -- decrease note position by val
			end
		end
	end
end

reaper.Undo_EndBlock("Change note position (mousewheel)", -1)

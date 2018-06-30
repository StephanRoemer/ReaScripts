-- @description Change note length (mousewheel)
-- @version 1.0
-- @author Stephan Römer
-- @about
--    # Description
--    - this script changes the note length via mousewheel
--    - this script works in the MIDI Editor and Inline Editor
--
-- @link https://forums.cockos.com/showthread.php?p=1923923
--
-- @provides [main=midi_editor,midi_inlineeditor] .
-- @changelog
--     v1.0 (2018-06-30)
--     + Initial release

reaper.Undo_BeginBlock()

_,_,_,_,_,_, val = reaper.get_action_context() -- receive mousewheel action
curEditor = reaper.MIDIEditor_GetActive() -- get current editor
take = reaper.MIDIEditor_GetTake(curEditor) -- get current take opened in editor
_, _, _ = reaper.BR_GetMouseCursorContext() -- initiate "get mouse cursor context"
_, _, noteRow, _, _, _ = reaper.BR_GetMouseCursorContext_MIDI() -- get note row under mouse cursor
mouse_time = reaper.BR_GetMouseCursorContext_Position() -- get mouse position in project time
mouse_ppq_pos = reaper.MIDI_GetPPQPosFromProjTime(take, mouse_time) -- convert project time to PPQ
notesCount, _, _ = reaper.MIDI_CountEvts(take) -- count notes in current take

-- are there selected notes?
for n = 0, notesCount - 1 do -- loop thru all notes
	_, selectedOut, _, _, _, _, _, _ = reaper.MIDI_GetNote(take, n) -- get note values
	if selectedOut == true then -- if at least one note is selected
		notes_selected = true -- set notes_selected to true
		break -- break the for loop, because at least one selected note was found
	end
end

-- change length of selected notes
if notes_selected == true then 
	for n = 0, notesCount - 1 do
		_, selectedOut, _, startppqposOut, endppqposOut, _, pitch, _ = reaper.MIDI_GetNote(take, n) -- get note selection status, start/end position and pitch
		if selectedOut == true then -- is current note selected?
			if val > 0 then -- if mousewheel up
				reaper.MIDI_SetNote(take, n, nil, nil, nil, endppqposOut+val, nil, nil, nil, true) -- increase note length by val
			else 			-- if mousewheel down
				reaper.MIDI_SetNote(take, n, nil, nil, nil, endppqposOut+val, nil, nil, nil, true) -- decrease note length by val
			end
		end
	end

-- if there are no selected notes, only change the length of the note under the mouse cursor
else 
	for n = 0, notesCount - 1 do
		_, _, _, startppqposOut, endppqposOut, _, pitch, _ = reaper.MIDI_GetNote(take, n) -- get note start/end position and pitch
		if startppqposOut < mouse_ppq_pos and endppqposOut > mouse_ppq_pos and noteRow == pitch then -- is current note the note under the cursor?
			if val > 0 then -- if mousewheel up
				reaper.MIDI_SetNote(take, n, nil, nil, nil, endppqposOut+val, nil, nil, nil, true) -- increase note length by val
			else 			-- if mousewheel down
				reaper.MIDI_SetNote(take, n, nil, nil, nil, endppqposOut+val, nil, nil, nil, true) -- decrease note length by val
			end
		end
	end
end

reaper.Undo_EndBlock("Change note length (mousewheel)", -1)

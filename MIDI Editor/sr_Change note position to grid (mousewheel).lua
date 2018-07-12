-- @description Change note position to grid (mousewheel)
-- @version 1.0
-- @author Stephan Römer
-- @about
--    # Description
--    - this script changes the note position (based on the grid, if snap in the MIDI editor is turned on) via mousewheel
--	  - if snap is turned off, it works the same as "Change note position (mousewheel)" script
--    - when there is no note selection, only the note under the mouse cursor is altered
--    - this script only works in the MIDI Editor
--
-- @link https://forums.cockos.com/showthread.php?p=1923923
--
-- @provides [main=midi_editor] .
-- @changelog
--     v1.0 (2018-07-12)
--     + Initial release

reaper.Undo_BeginBlock()

_,_,_,_,_,_, val = reaper.get_action_context() -- receive mousewheel action
take = reaper.MIDIEditor_GetTake(reaper.MIDIEditor_GetActive()) -- get current take opened in editor
_, _, _ = reaper.BR_GetMouseCursorContext() -- initiate "get mouse cursor context"
_, _, noteRow, _, _, _ = reaper.BR_GetMouseCursorContext_MIDI() -- get note row under mouse cursor
mouse_ppq_pos = reaper.MIDI_GetPPQPosFromProjTime(take, reaper.BR_GetMouseCursorContext_Position()) -- get mouse position in project time and convert to PPQ
notesCount, _, _ = reaper.MIDI_CountEvts(take) -- count notes in current take
snap =  reaper.GetToggleCommandStateEx(32060, 1014) -- get snap toggle state from MIDI editor, 32060 is the MIDI editor section_id

-- are there selected notes?
if reaper.MIDI_EnumSelNotes(take, -1) ~= -1 then -- check, if there are selected notes
	notesSelected = true -- set notesSelected to true
end

for n = 0, notesCount - 1 do
	_, selectedOut, _, startppqposOut, endppqposOut, _, pitch, _ = reaper.MIDI_GetNote(take, n) -- get note selection status, start/end position and pitch
	if snap == 1 then -- if snap is on
		if notesSelected == true then -- if there are selected notes
			if selectedOut == true then -- is current note selected?
				noteStart = reaper.MIDI_GetProjTimeFromPPQPos(take, startppqposOut) -- convert note start from PPQ to project time 
				if val > 0 then -- if mousewheel up
					nextGridPPQ = reaper.MIDI_GetPPQPosFromProjTime(take, reaper.BR_GetNextGridDivision(noteStart)) -- get next grid division in project time and convert next grid division back to PPQ
					reaper.MIDI_SetNote(take, n, nil, nil, nextGridPPQ, nextGridPPQ+endppqposOut-startppqposOut, nil, nil, nil, true) -- set new position, endposition = nextGridPPQ (offset) + endppqposOut-startppqposOut (length)
				else 			-- if mousewheel down
					prevGridPPQ = reaper.MIDI_GetPPQPosFromProjTime(take, reaper.BR_GetPrevGridDivision(noteStart)) -- get previous grid division in project time and convert previous grid division back to PPQ
					reaper.MIDI_SetNote(take, n, nil, nil, prevGridPPQ, prevGridPPQ+endppqposOut-startppqposOut, nil, nil, nil, true) -- set new position, endposition = prevGridPPQ (offset) + endppqposOut-startppqposOut (length)
				end
			end
		else -- if there are no selected notes, only change the position of the note under the mouse cursor
			if startppqposOut < mouse_ppq_pos and endppqposOut > mouse_ppq_pos and noteRow == pitch then -- is current note the note under the cursor?
				noteStart = reaper.MIDI_GetProjTimeFromPPQPos(take, startppqposOut) -- convert note start from PPQ to project time 
				if val > 0 then -- if mousewheel up
					nextGridPPQ = reaper.MIDI_GetPPQPosFromProjTime(take, reaper.BR_GetNextGridDivision(noteStart)) -- get next grid division in project time and convert next grid division back to PPQ
					reaper.MIDI_SetNote(take, n, nil, nil, nextGridPPQ, nextGridPPQ+endppqposOut-startppqposOut, nil, nil, nil, true) -- set new position, endposition = nextGridPPQ (offset) + endppqposOut-startppqposOut (length)
				else 			-- if mousewheel down
					prevGridPPQ = reaper.MIDI_GetPPQPosFromProjTime(take, reaper.BR_GetPrevGridDivision(noteStart)) -- get previous grid division in project time and convert previous grid division back to PPQ
					reaper.MIDI_SetNote(take, n, nil, nil, prevGridPPQ, prevGridPPQ+endppqposOut-startppqposOut, nil, nil, nil, true) -- set new position, endposition = prevGridPPQ (offset) + endppqposOut-startppqposOut (length)
				end
			end
		end
	else -- if snap is off
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
end

reaper.Undo_EndBlock("Change note position to grid (mousewheel)", -1)

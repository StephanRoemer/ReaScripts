-- @description Change note position to grid (mousewheel)
-- @version 1.21
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
--     v1.21 (2018-07-14)
--     + bugfix
--     v1.20 (2018-07-14)
--     + the script now reacts based on the grid set in the MIDI editor
--     v1.12 (2018-07-13)
--     + added undo text
--     v1.11 (2018-07-12)
--     + some code optimizations
--     v1.0 (2018-07-12)
--     + Initial release

_,_,_,_,_,_, val = reaper.get_action_context() -- receive mousewheel action
take = reaper.MIDIEditor_GetTake(reaper.MIDIEditor_GetActive()) -- get current take opened in editor
editorGrid, _, _ = reaper.MIDI_GetGrid(take) -- get MIDI Editor grid
editorGridProjTime = reaper.TimeMap2_QNToTime(0, editorGrid) -- convert grid (QN) to Project Time
_, _, _ = reaper.BR_GetMouseCursorContext() -- initiate "get mouse cursor context"
_, _, noteRow, _, _, _ = reaper.BR_GetMouseCursorContext_MIDI() -- get note row under mouse cursor
mouse_ppq_pos = reaper.MIDI_GetPPQPosFromProjTime(take, reaper.BR_GetMouseCursorContext_Position()) -- get mouse position in project time and convert to PPQ
notesCount, _, _ = reaper.MIDI_CountEvts(take) -- count notes in current take
snap = reaper.MIDIEditor_GetSetting_int(reaper.MIDIEditor_GetActive(), "snap_enabled" ) -- get snap toggle state from MIDI editor
allQuantized = true -- initialize variable, expect all notes quantized true, until proven otherwise. See below for explanation


-- are there selected notes?
if reaper.MIDI_EnumSelNotes(take, -1) ~= -1 then -- check, if there are selected notes
	notesSelected = true -- set notesSelected to true
end

-- are all selected notes quantized? This is needed when nudging a group of notes to the left. This ensures that all notes are moved (quantized) to the previous grid first, before moving them alltogether,
-- otherwise they will fall apart and loose "synch".
for n = 0, notesCount - 1 do -- loop through notes 
		_, selectedOut, _, startppqposOut, endppqposOut, _, _, _ = reaper.MIDI_GetNote(take, n) -- get note selection status and start/end position
		noteStartProjTime = reaper.MIDI_GetProjTimeFromPPQPos(take, startppqposOut) -- convert startppqposOut to Project Time
	if noteStartProjTime % editorGridProjTime ~= 0 and selectedOut == true then -- if modulo is not 0 (not all selected notes are on the grid)
		allQuantized = false -- set allQuantized false
	end
end

for n = 0, notesCount - 1 do -- loop through notes
	_, selectedOut, _, startppqposOut, endppqposOut, _, pitch, _ = reaper.MIDI_GetNote(take, n) -- get note selection status, start/end position and pitch
	if snap == 1 then -- if snap is on
		noteStartProjTime = reaper.MIDI_GetProjTimeFromPPQPos(take, startppqposOut) -- convert startppqposOut to Project Time 
		noteEndProjTime = reaper.MIDI_GetProjTimeFromPPQPos(take, endppqposOut)	-- convert endppqposOut to Project Time
		if notesSelected == true then -- if there are selected notes
			if selectedOut == true then -- is current note selected?
				if val > 0 then -- if mousewheel up
					if noteStartProjTime % editorGridProjTime == 0 then -- if modulo from noteStartProjTime and editorGridProjTime equals 0, note sits already on the grid
						reaper.MIDI_SetNote(take, n, nil, nil, reaper.MIDI_GetPPQPosFromProjTime(take, noteStartProjTime+editorGridProjTime), reaper.MIDI_GetPPQPosFromProjTime(take,noteEndProjTime+editorGridProjTime), nil, nil, nil, true) -- set new position = forward one grid position, convert values back to PPQ
					else -- note does not sit on the grid
						modulo = noteStartProjTime % editorGridProjTime -- get modulo rest
						newPosition = editorGridProjTime - modulo -- calculate new position (distance to editorGridProjTime)
						reaper.MIDI_SetNote(take, n, nil, nil, reaper.MIDI_GetPPQPosFromProjTime(take, noteStartProjTime+newPosition), reaper.MIDI_GetPPQPosFromProjTime(take, noteEndProjTime+newPosition), nil, nil, nil, true) -- set new position, noteStartProjTime+newPosition = on the grid
					end
				else -- if mousewheel down
					if allQuantized == false then -- this is a special case, for notes being nudged to the left. Not all notes are quantized. See the comment above (first for-loop). 
						modulo = noteStartProjTime % editorGridProjTime -- get modulo rest
						reaper.MIDI_SetNote(take, n, nil, nil, reaper.MIDI_GetPPQPosFromProjTime(take, noteStartProjTime-modulo), reaper.MIDI_GetPPQPosFromProjTime(take, noteEndProjTime-modulo), nil, nil, nil, true) -- quantize notes to the left grid, until all selected notes are quantized
					elseif noteStartProjTime % editorGridProjTime == 0 and allQuantized == true then -- if modulo from noteStartProjTime and editorGridProjTime equals 0, note sits already on the grid and if all selected notes are quantized
						reaper.MIDI_SetNote(take, n, nil, nil, reaper.MIDI_GetPPQPosFromProjTime(take, noteStartProjTime-editorGridProjTime), reaper.MIDI_GetPPQPosFromProjTime(take, noteEndProjTime-editorGridProjTime), nil, nil, nil, true) -- set new position, noteStartProjTime-editorGridProjTime = move left to the next grid position
					end
				end
			end
		else -- if there are no selected notes, only change the position of the note under the mouse cursor
			if startppqposOut < mouse_ppq_pos and endppqposOut > mouse_ppq_pos and noteRow == pitch then -- is current note the note under the cursor?
				if val > 0 then -- if mousewheel up
					if noteStartProjTime % editorGridProjTime == 0 then -- if modulo from noteStartProjTime and editorGridProjTime equals 0, note sits already on the grid
						reaper.MIDI_SetNote(take, n, nil, nil, reaper.MIDI_GetPPQPosFromProjTime(take, noteStartProjTime+editorGridProjTime), reaper.MIDI_GetPPQPosFromProjTime(take,noteEndProjTime+editorGridProjTime), nil, nil, nil, true) -- set new position = forward one grid position
					else -- note does not sit on the grid
						modulo = noteStartProjTime % editorGridProjTime -- get modulo rest
						newPosition = editorGridProjTime - modulo -- calculate new position (distance to editorGridProjTime)
						reaper.MIDI_SetNote(take, n, nil, nil, reaper.MIDI_GetPPQPosFromProjTime(take, noteStartProjTime+newPosition), reaper.MIDI_GetPPQPosFromProjTime(take, noteEndProjTime+newPosition), nil, nil, nil, true) -- set new position, noteStartProjTime+newPosition = on the grid
					end
				else -- if mousewheel down
					if noteStartProjTime % editorGridProjTime == 0 then -- if modulo from noteStartProjTime and editorGridProjTime equals 0, note sits already on the grid
						reaper.MIDI_SetNote(take, n, nil, nil, reaper.MIDI_GetPPQPosFromProjTime(take, noteStartProjTime-editorGridProjTime), reaper.MIDI_GetPPQPosFromProjTime(take, noteEndProjTime-editorGridProjTime), nil, nil, nil, true) -- set new position, startppqposOut+newPosition = on the grid
					else 
						modulo = noteStartProjTime % editorGridProjTime -- get modulo rest
						reaper.MIDI_SetNote(take, n, nil, nil, reaper.MIDI_GetPPQPosFromProjTime(take, noteStartProjTime-modulo), reaper.MIDI_GetPPQPosFromProjTime(take, noteEndProjTime-modulo), nil, nil, nil, true) -- set new position, noteStartProjTime-modulo = move left to the next grid position
					end
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
	reaper.MIDI_Sort(take)
	reaper.UpdateArrange()
end

reaper.Undo_OnStateChange2(proj, "Change note position to grid (mousewheel)")
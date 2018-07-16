-- @description Change note position by grid - quantize (mousewheel)
-- @version 1.0
-- @author Stephan Römer, Lokasenna
-- @about
--    # Description
--    - this script changes the note position (based on the grid, if snap in the MIDI editor is turned on) via mousewheel
--	  - before moving the notes in the grid, the script quantizes the notes according the grid setting in the MIDI Editor
--	  - if snap is turned off, it works the same as "Change note position (mousewheel)" script
--    - when there is no note selection, only the note under the mouse cursor is altered
--    - this script only works in the MIDI Editor
--
-- @link https://forums.cockos.com/showthread.php?p=1923923
--
-- @provides [main=midi_editor] .
-- @changelog
--     v1.0 (2018-07-16)
--     + Initial release

_,_,_,_,_,_, val = reaper.get_action_context() -- receive mousewheel action
take = reaper.MIDIEditor_GetTake(reaper.MIDIEditor_GetActive()) -- get current take opened in editor
editorGridQN = reaper.MIDI_GetGrid(take)
ticksPerBeat = reaper.SNM_GetIntConfigVar('miditicksperbeat', 0) -- get ticks per beat from Reaper project settings
grid = ticksPerBeat * editorGridQN -- calculate grid steps in ticks
_, _, _ = reaper.BR_GetMouseCursorContext() -- initiate "get mouse cursor context"
_, _, noteRow, _, _, _ = reaper.BR_GetMouseCursorContext_MIDI() -- get note row under mouse cursor
mouse_ppq_pos = reaper.MIDI_GetPPQPosFromProjTime(take, reaper.BR_GetMouseCursorContext_Position()) -- get mouse position in project time and convert to PPQ
notesCount, _, _ = reaper.MIDI_CountEvts(take) -- count notes in current take
snap = reaper.MIDIEditor_GetSetting_int(reaper.MIDIEditor_GetActive(), "snap_enabled" ) -- get snap toggle state from MIDI editor

-- are there selected notes?
if reaper.MIDI_EnumSelNotes(take, -1) ~= -1 then notesSelected = true end -- check, if there are selected notes and set notesSelected to true


for n = 0, notesCount - 1 do -- loop through notes
	_, selectedOut, _, startppqposOut, endppqposOut, _, pitch, _ = reaper.MIDI_GetNote(take, n) -- get note selection status, start/end position and pitch
	int, frac = math.modf(startppqposOut / grid) -- math.modf just gives the whole and decimal parts of a number. Many thanks to Lokasenna! https://forums.cockos.com/showthread.php?t=208915 
	editorClosestGrid = (math.floor( frac + 0.5 ) == 1 and int + 1 or int) * grid -- get closest grid. Simple rounding logic. If you can add 0.5 and it still rounds down (math.floor) to 0 then it should round down. If adding 0.5 causes it to round up to 1, then it was >= 0.5 and should round up. "int" is just the number of multiples of "grid" (snap) that we have, so we have to multiply snap back in.
	if snap == 1 then -- if snap is on
		if notesSelected == true then -- if there are selected notes
			if selectedOut == true then -- only include selected notes
				if val > 0 then-- if mousewheel up
					reaper.MIDI_SetNote(take, n, nil, nil, editorClosestGrid+grid, endppqposOut+grid, nil, nil, nil, true) -- set new position = quantize to the closest grid and forward one grid position
				else -- if mousewheel down
					reaper.MIDI_SetNote(take, n, nil, nil, editorClosestGrid-grid, endppqposOut-grid, nil, nil, nil, true) -- set new position = quantize to the closest grid and go one grid position backwards
				end
			end
		else -- if there are no selected notes, only change the position of the note under the mouse cursor
			if startppqposOut < mouse_ppq_pos and endppqposOut > mouse_ppq_pos and noteRow == pitch then -- is current note the note under the cursor?
				if val > 0 then -- if mousewheel up
					reaper.MIDI_SetNote(take, n, nil, nil, editorClosestGrid+grid, endppqposOut+grid, nil, nil, nil, true) -- set new position = quantize to the closest grid and forward one grid position
				else -- if mousewheel down
					reaper.MIDI_SetNote(take, n, nil, nil, editorClosestGrid-grid, endppqposOut-grid, nil, nil, nil, true) -- set new position = quantize to the closest grid and go one grid position backwards
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
				else -- if mousewheel down
					reaper.MIDI_SetNote(take, n, nil, nil, startppqposOut+val, endppqposOut+val, nil, nil, nil, true) -- decrease note position by val
				end
			end
		end
	end
	reaper.UpdateArrange()
end

reaper.Undo_OnStateChange2(proj, "Change note position to grid (mousewheel)")
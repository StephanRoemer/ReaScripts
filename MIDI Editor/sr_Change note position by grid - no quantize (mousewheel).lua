-- @description Change note position by grid - no quantize (mousewheel)
-- @version 1.2
-- @changelog
--   code tidying
-- @author Stephan Römer
-- @provides [main=midi_editor] .
-- @about
--    # Description
--    * This script changes the note position (based on the grid, if snap in the MIDI editor is turned on) via mousewheel
--	  * If snap is turned off, it works the same as "Change note position (mousewheel)" script
--    * When there is no note selection, only the note under the mouse cursor is altered
--    * This script only works in the MIDI Editor
-- @link https://forums.cockos.com/showthread.php?p=1923923

_,_,_,_,_,_, val = reaper.get_action_context() -- receive mousewheel action
take = reaper.MIDIEditor_GetTake(reaper.MIDIEditor_GetActive()) -- get current take opened in editor
editor_grid_qn = reaper.MIDI_GetGrid(take)
ticks_per_beat = reaper.SNM_GetIntConfigVar('miditicksperbeat', 0) -- get ticks per beat from Reaper project settings
grid = ticks_per_beat * editor_grid_qn -- calculate grid steps in ticks
_, _, _ = reaper.BR_GetMouseCursorContext() -- initiate "get mouse cursor context"
_, _, note_row, _, _, _ = reaper.BR_GetMouseCursorContext_MIDI() -- get note row under mouse cursor
mouse_ppq_pos = reaper.MIDI_GetPPQPosFromProjTime(take, reaper.BR_GetMouseCursorContext_Position()) -- get mouse position in project time and convert to PPQ
notes_count, _, _ = reaper.MIDI_CountEvts(take) -- count notes in current take
snap = reaper.MIDIEditor_GetSetting_int(reaper.MIDIEditor_GetActive(), "snap_enabled" ) -- get snap toggle state from MIDI editor

-- are there selected notes?
if reaper.MIDI_EnumSelNotes(take, -1) ~= -1 then -- check, if there are selected notes
	notes_selected = true -- set notes_selected to true
end

for n = 0, notes_count - 1 do -- loop through notes
	_, selected_out, _, startppqpos_out, endppqpos_out, _, pitch, _ = reaper.MIDI_GetNote(take, n) -- get note selection status, start/end position and pitch
	if snap == 1 then -- if snap is on
		if notes_selected == true then -- if there are selected notes
			if selected_out == true then -- is current note selected?
				if val > 0 then -- if mousewheel up
					reaper.MIDI_SetNote(take, n, nil, nil, startppqpos_out+grid, endppqpos_out+grid, nil, nil, nil, true) -- set new position = forward one grid position
				else -- if mousewheel down
					reaper.MIDI_SetNote(take, n, nil, nil, startppqpos_out-grid, endppqpos_out-grid, nil, nil, nil, true) -- set new position = go one grid position backwards
				end
			end
		else -- if there are no selected notes, only change the position of the note under the mouse cursor
			if startppqpos_out < mouse_ppq_pos and endppqpos_out > mouse_ppq_pos and note_row == pitch then -- is current note the note under the cursor?
				if val > 0 then -- if mousewheel up
					reaper.MIDI_SetNote(take, n, nil, nil, startppqpos_out+grid, endppqpos_out+grid, nil, nil, nil, true) -- set new position = forward one grid
				else -- if mousewheel down
					reaper.MIDI_SetNote(take, n, nil, nil, startppqpos_out-grid, endppqpos_out-grid, nil, nil, nil, true) -- quantize notes to the left grid, until all selected notes are quantized
				end
			end
		end
	else -- if snap is off
		if notes_selected == true then -- if there are selected notes
			if selected_out == true then -- is current note selected?
				if val > 0 then -- if mousewheel up
					reaper.MIDI_SetNote(take, n, nil, nil, startppqpos_out+val, endppqpos_out+val, nil, nil, nil, true) -- increase note position by val
				else 			-- if mousewheel down
					reaper.MIDI_SetNote(take, n, nil, nil, startppqpos_out+val, endppqpos_out+val, nil, nil, nil, true) -- decrease note position by val
				end
			end
		else -- if there are no selected notes, only change the position of the note under the mouse cursor
			if startppqpos_out < mouse_ppq_pos and endppqpos_out > mouse_ppq_pos and note_row == pitch then -- is current note the note under the cursor?
				if val > 0 then -- if mousewheel up
					reaper.MIDI_SetNote(take, n, nil, nil, startppqpos_out+val, endppqpos_out+val, nil, nil, nil, true) -- increase note position by val
				else -- if mousewheel down
					reaper.MIDI_SetNote(take, n, nil, nil, startppqpos_out+val, endppqpos_out+val, nil, nil, nil, true) -- decrease note position by val
				end
			end
		end
	end
	reaper.UpdateArrange()
end

reaper.Undo_OnStateChange2(proj, "Change note position to grid (mousewheel)")
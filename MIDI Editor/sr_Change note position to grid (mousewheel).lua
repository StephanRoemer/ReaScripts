-- @description Change note position to grid (mousewheel)
-- @version 1.30
-- @changelog
--   code tidying
-- @author Stephan Römer
-- @provides [main=midi_editor] .
-- @about
--    # Description
--    - this script changes the note position (based on the grid, if snap in the MIDI editor is turned on) via mousewheel
--	  - if snap is turned off, it works the same as "Change note position (mousewheel)" script
--    - when there is no note selection, only the note under the mouse cursor is altered
--    - this script only works in the MIDI Editor
-- @link https://forums.cockos.com/showthread.php?p=1923923

_,_,_,_,_,_, val = reaper.get_action_context() -- receive mousewheel action
take = reaper.MIDIEditor_GetTake(reaper.MIDIEditor_GetActive()) -- get current take opened in editor
editor_grid, _, _ = reaper.MIDI_GetGrid(take) -- get MIDI Editor grid
editor_grid_proj_time = reaper.TimeMap2_QNToTime(0, editor_grid) -- convert grid (QN) to Project Time
_, _, _ = reaper.BR_GetMouseCursorContext() -- initiate "get mouse cursor context"
_, _, note_row, _, _, _ = reaper.BR_GetMouseCursorContext_MIDI() -- get note row under mouse cursor
mouse_ppq_pos = reaper.MIDI_GetPPQPosFromProjTime(take, reaper.BR_GetMouseCursorContext_Position()) -- get mouse position in project time and convert to PPQ
notes_count, _, _ = reaper.MIDI_CountEvts(take) -- count notes in current take
snap = reaper.MIDIEditor_GetSetting_int(reaper.MIDIEditor_GetActive(), "snap_enabled" ) -- get snap toggle state from MIDI editor
all_quantized = true -- initialize variable, expect all notes quantized true, until proven otherwise. See below for explanation


-- are there selected notes?
if reaper.MIDI_EnumSelNotes(take, -1) ~= -1 then -- check, if there are selected notes
	notes_selected = true -- set notes_selected to true
end

-- are all selected notes quantized? This is needed when nudging a group of notes to the left. This ensures that all notes are moved (quantized) to the previous grid first, before moving them alltogether,
-- otherwise they will fall apart and loose "synch".
for n = 0, notes_count - 1 do -- loop through notes 
		_, selected_out, _, startppqpos_out, endppqpos_out, _, _, _ = reaper.MIDI_GetNote(take, n) -- get note selection status and start/end position
		note_start_proj_time = reaper.MIDI_GetProjTimeFromPPQPos(take, startppqpos_out) -- convert startppqpos_out to Project Time
	if note_start_proj_time % editor_grid_proj_time ~= 0 and selected_out == true then -- if modulo is not 0 (not all selected notes are on the grid)
		all_quantized = false -- set all_quantized false
	end
end

for n = 0, notes_count - 1 do -- loop through notes
	_, selected_out, _, startppqpos_out, endppqpos_out, _, pitch, _ = reaper.MIDI_GetNote(take, n) -- get note selection status, start/end position and pitch
	if snap == 1 then -- if snap is on
		note_start_proj_time = reaper.MIDI_GetProjTimeFromPPQPos(take, startppqpos_out) -- convert startppqpos_out to Project Time 
		note_end_proj_time = reaper.MIDI_GetProjTimeFromPPQPos(take, endppqpos_out)	-- convert endppqpos_out to Project Time
		if notes_selected == true then -- if there are selected notes
			if selected_out == true then -- is current note selected?
				if val > 0 then -- if mousewheel up
					if note_start_proj_time % editor_grid_proj_time == 0 then -- if modulo from note_start_proj_time and editor_grid_proj_time equals 0, note sits already on the grid
						reaper.MIDI_SetNote(take, n, nil, nil, reaper.MIDI_GetPPQPosFromProjTime(take, note_start_proj_time+editor_grid_proj_time), reaper.MIDI_GetPPQPosFromProjTime(take,note_end_proj_time+editor_grid_proj_time), nil, nil, nil, true) -- set new position = forward one grid position, convert values back to PPQ
					else -- note does not sit on the grid
						modulo = note_start_proj_time % editor_grid_proj_time -- get modulo rest
						new_position = editor_grid_proj_time - modulo -- calculate new position (distance to editor_grid_proj_time)
						reaper.MIDI_SetNote(take, n, nil, nil, reaper.MIDI_GetPPQPosFromProjTime(take, note_start_proj_time+new_position), reaper.MIDI_GetPPQPosFromProjTime(take, note_end_proj_time+new_position), nil, nil, nil, true) -- set new position, note_start_proj_time+new_position = on the grid
					end
				else -- if mousewheel down
					if all_quantized == false then -- this is a special case, for notes being nudged to the left. Not all notes are quantized. See the comment above (first for-loop). 
						modulo = note_start_proj_time % editor_grid_proj_time -- get modulo rest
						reaper.MIDI_SetNote(take, n, nil, nil, reaper.MIDI_GetPPQPosFromProjTime(take, note_start_proj_time-modulo), reaper.MIDI_GetPPQPosFromProjTime(take, note_end_proj_time-modulo), nil, nil, nil, true) -- quantize notes to the left grid, until all selected notes are quantized
					elseif note_start_proj_time % editor_grid_proj_time == 0 and all_quantized == true then -- if modulo from note_start_proj_time and editor_grid_proj_time equals 0, note sits already on the grid and if all selected notes are quantized
						reaper.MIDI_SetNote(take, n, nil, nil, reaper.MIDI_GetPPQPosFromProjTime(take, note_start_proj_time-editor_grid_proj_time), reaper.MIDI_GetPPQPosFromProjTime(take, note_end_proj_time-editor_grid_proj_time), nil, nil, nil, true) -- set new position, note_start_proj_time-editor_grid_proj_time = move left to the next grid position
					end
				end
			end
		else -- if there are no selected notes, only change the position of the note under the mouse cursor
			if startppqpos_out < mouse_ppq_pos and endppqpos_out > mouse_ppq_pos and note_row == pitch then -- is current note the note under the cursor?
				if val > 0 then -- if mousewheel up
					if note_start_proj_time % editor_grid_proj_time == 0 then -- if modulo from note_start_proj_time and editor_grid_proj_time equals 0, note sits already on the grid
						reaper.MIDI_SetNote(take, n, nil, nil, reaper.MIDI_GetPPQPosFromProjTime(take, note_start_proj_time+editor_grid_proj_time), reaper.MIDI_GetPPQPosFromProjTime(take,note_end_proj_time+editor_grid_proj_time), nil, nil, nil, true) -- set new position = forward one grid position
					else -- note does not sit on the grid
						modulo = note_start_proj_time % editor_grid_proj_time -- get modulo rest
						new_position = editor_grid_proj_time - modulo -- calculate new position (distance to editor_grid_proj_time)
						reaper.MIDI_SetNote(take, n, nil, nil, reaper.MIDI_GetPPQPosFromProjTime(take, note_start_proj_time+new_position), reaper.MIDI_GetPPQPosFromProjTime(take, note_end_proj_time+new_position), nil, nil, nil, true) -- set new position, note_start_proj_time+new_position = on the grid
					end
				else -- if mousewheel down
					if note_start_proj_time % editor_grid_proj_time == 0 then -- if modulo from note_start_proj_time and editor_grid_proj_time equals 0, note sits already on the grid
						reaper.MIDI_SetNote(take, n, nil, nil, reaper.MIDI_GetPPQPosFromProjTime(take, note_start_proj_time-editor_grid_proj_time), reaper.MIDI_GetPPQPosFromProjTime(take, note_end_proj_time-editor_grid_proj_time), nil, nil, nil, true) -- set new position, startppqpos_out+new_position = on the grid
					else 
						modulo = note_start_proj_time % editor_grid_proj_time -- get modulo rest
						reaper.MIDI_SetNote(take, n, nil, nil, reaper.MIDI_GetPPQPosFromProjTime(take, note_start_proj_time-modulo), reaper.MIDI_GetPPQPosFromProjTime(take, note_end_proj_time-modulo), nil, nil, nil, true) -- set new position, note_start_proj_time-modulo = move left to the next grid position
					end
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
				else 			-- if mousewheel down
					reaper.MIDI_SetNote(take, n, nil, nil, startppqpos_out+val, endppqpos_out+val, nil, nil, nil, true) -- decrease note position by val
				end
			end
		end
	end
	reaper.UpdateArrange()
end

reaper.Undo_OnStateChange2(proj, "Change note position to grid (mousewheel)")
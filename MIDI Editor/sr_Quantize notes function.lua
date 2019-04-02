--  @noindex

function Quantize()
	
	
	-- quantize take in MIDI/inline editor
	
	function Quantize_MIDI_Editor(take)
		
		local _, notes_count, _, _ = reaper.MIDI_CountEvts(take) -- count notes and save amount to notes_count
		
		if reaper.MIDI_EnumSelNotes(take, -1) ~= -1 then notes_selected = true end -- check, if there are selected notes, set notes_selected to true
		
		for n = 0, notes_count - 1 do -- loop through all notes
			local _, selected_out, _, startppqpos_out, endppqpos_out, _, _, _ = reaper.MIDI_GetNote(take, n) -- get selection status and pitch
			
			local note_start = reaper.MIDI_GetProjTimeFromPPQPos(take, startppqpos_out) -- convert note start to seconds
			local closest_grid = reaper.BR_GetClosestGridDivision(note_start) -- get closest grid for current note (return value in seconds)
			local closest_grid_ppq = reaper.MIDI_GetPPQPosFromProjTime(take, closest_grid) -- convert closest grid to PPQ
			
			if notes_selected == true then -- if there is a note selection
				if selected_out == true then -- filter out selected notes to quantize
					if closest_grid_ppq ~= startppqpos_out then -- if notes are not on the grid
						reaper.MIDI_SetNote(take, n, nil, nil, closest_grid_ppq, closest_grid_ppq+endppqpos_out-startppqpos_out, nil, nil, nil, true) -- quantize selected notes
					end
				end
			else -- if there is no note selection
				if closest_grid_ppq ~= startppqpos_out then
					reaper.MIDI_SetNote(take, n, nil, nil, closest_grid_ppq, closest_grid_ppq+endppqpos_out-startppqpos_out, nil, nil, nil, true) -- quantize all notes
				end
			end
		end
		reaper.MIDI_Sort(take)
	end
	

	-- quantize selected item(s) in arrangement
	
	function Quantize_Arrangement()
		
		if reaper.CountSelectedMediaItems(0) == 0 then
			reaper.ShowMessageBox("Please select at least one item", "Error", 0)
			return false
		else
			for i = 0, reaper.CountSelectedMediaItems(0)-1 do -- loop through all selected items
				local item = reaper.GetSelectedMediaItem(0, i) -- get current selected item
				local take = reaper.GetActiveTake(item)
			
					if reaper.TakeIsMIDI(take) then -- make sure, that take is MIDI
						_, notes_count, _, _ = reaper.MIDI_CountEvts(take) -- count notes and save amount to notes_count
		
						for n = 0, notes_count - 1 do -- loop through all notes
							local _, selected_out, _, startppqpos_out, endppqpos_out, _, _, _ = reaper.MIDI_GetNote(take, n) -- get selection status and pitch
				
							local note_start = reaper.MIDI_GetProjTimeFromPPQPos(take, startppqpos_out) -- convert note start to seconds
							local closest_grid = reaper.BR_GetClosestGridDivision(note_start) -- get closest grid for current note (return value in seconds)
							local closest_grid_ppq = reaper.MIDI_GetPPQPosFromProjTime(take, closest_grid) -- convert closest grid to PPQ

							if closest_grid_ppq ~= startppqpos_out then -- if notes are not on the grid
								reaper.MIDI_SetNote(take, n, nil, nil, closest_grid_ppq, closest_grid_ppq+endppqpos_out-startppqpos_out, nil, nil, nil, true) -- quantize all notes
							end
						end
						reaper.MIDI_Sort(take)
					else
						reaper.ShowMessageBox("The selected item #".. i+1 .." does not contain a MIDI take and won't be altered", "Error", 0)
					end
				end
			end
		end
	end


	-- check, where the user wants to quantize: inline editor, arrangement or MIDI editor

	local window, segment, details = reaper.BR_GetMouseCursorContext() -- initialize cursor context
	local _, inlineEditor, _, _, _, _ = reaper.BR_GetMouseCursorContext_MIDI() -- check if mouse hovers an inline editor
	
	if inlineEditor then
		local take = reaper.BR_GetMouseCursorContext_Take() -- get take from mouse
		Quantize_MIDI_Editor(take) -- execute function and pass over take
	
	else -- no inline editor hovered, check for MIDI editor
	
		if window ~= "midi_editor" then -- MIDI editor is not focused
			Quantize_Arrangement()

		else 
			local midi_editor = reaper.MIDIEditor_GetActive() -- get active MIDI editor 
        	local take = reaper.MIDIEditor_GetTake(midi_editor) -- get take from active MIDI editor
			Quantize_MIDI_Editor(take) -- execute function and pass over take
		end
	end
	
	reaper.UpdateArrange()
end
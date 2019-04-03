--  @noindex

function Add_Notes_Interval(interval)
	
	
	-- add notes interval in MIDI/inline editor

	function Add_Notes_Interval_MIDI_Editor(take)

		local _, notes_count, _, _ = reaper.MIDI_CountEvts(take) -- count notes and save amount to notes_count
		
		if reaper.MIDI_EnumSelNotes(take, -1) ~= -1 then notes_selected = true end -- check, if there are selected notes, set notes_selected to true
		
		gotAllOK, MIDIstring = reaper.MIDI_GetAllEvts(take, "") -- write MIDI events to MIDIstring, get all events okay
	
		if not gotAllOK then reaper.ShowMessageBox("Error while loading MIDI", "Error", 0) return(false) end -- if getting the MIDI data failed
		MIDIlen = #MIDIstring -- get string length
		tableEvents = {} -- initialize table, MIDI events will temporarily be stored in this table until they are concatenated into a string again
		stringPos = 1 -- position in MIDIstring while parsing through events 
				
		while stringPos < MIDIlen-12 do -- parse through all events in the MIDI string, one-by-one, excluding the final 12 bytes, which provides REAPER's All-notes-off end-of-take message
			offset, flags, msg, stringPos = string.unpack("i4Bs4", MIDIstring, stringPos) -- unpack MIDI-string on stringPos
			new_pitch = msg:byte(2) + interval -- get current pitch, add interval and write new value to pitch
			
			if #msg == 3 -- if msg consists of 3 bytes (= channel message)
			and ((msg:byte(1)>>4) == 9 or (msg:byte(1)>>4) == 8) -- Is note-on or note-off?
			and (flags&1 == 1 or not notes_selected) -- selected notes always move, unselected only move if no notes are selected
			then
				if new_pitch < 0 or new_pitch > 127 then -- if new notes are out of range
					reaper.ShowMessageBox("Added notes out of range","Error",0) -- error message
					return
				end
				
				table.insert(tableEvents, string.pack("i4Bs4", offset, flags, msg)) -- re-pack MIDI string and write original notes to table. Repack here already, so that offset = 0 has reference points
				msg_addNotes = msg:sub(1,1) .. string.char(new_pitch) .. msg:sub(3,3) -- if new notes are in range, concatenate msg with new pitch values
				table.insert(tableEvents, string.pack("i4Bs4", 0, flags, msg_addNotes)) -- re-pack MIDI string and write added notes to table
			else 
				table.insert(tableEvents, string.pack("i4Bs4", offset, flags, msg))
			end
		end
		reaper.MIDI_Sort(take)
		reaper.MIDI_SetAllEvts(take, table.concat(tableEvents) .. MIDIstring:sub(-12))
	end


	-- add notes interval in MIDI/inline editor

	function Add_Notes_Interval_Arrangement()

		if reaper.CountSelectedMediaItems(0) == 0 then
			reaper.ShowMessageBox("Please select at least one item", "Error", 0)
			return false
		else 
			for i = 0, reaper.CountSelectedMediaItems(0)-1 do -- loop through all selected items
				local item = reaper.GetSelectedMediaItem(0, i) -- get current selected item
				local take = reaper.GetActiveTake(item)
					
				if reaper.TakeIsMIDI(take) then -- make sure, that take is MIDI
					gotAllOK, MIDIstring = reaper.MIDI_GetAllEvts(take, "") -- write MIDI events to MIDIstring, get all events okay
				
					if not gotAllOK then reaper.ShowMessageBox("Error while loading MIDI", "Error", 0) return(false) end -- if getting the MIDI data failed
					MIDIlen = #MIDIstring -- get string length
					tableEvents = {} -- initialize table, MIDI events will temporarily be stored in this table until they are concatenated into a string again
					stringPos = 1 -- position in MIDIstring while parsing through events 
					
					while stringPos < MIDIlen-12 do -- parse through all events in the MIDI string, one-by-one, excluding the final 12 bytes, which provides REAPER's All-notes-off end-of-take message
						offset, flags, msg, stringPos = string.unpack("i4Bs4", MIDIstring, stringPos) -- unpack MIDI-string on stringPos
						new_pitch = msg:byte(2) + interval -- get current pitch, add interval and write new value to pitch
						
						if #msg == 3 -- if msg consists of 3 bytes (= channel message)
						and ((msg:byte(1)>>4) == 9 or (msg:byte(1)>>4) == 8) -- Is note-on or note-off?
						and (flags&1 == 1 or not notesSelected) -- selected notes always move, unselected only move if no notes are selected
						then
							if new_pitch < 0 or new_pitch > 127 then -- if new notes are out of range
								reaper.ShowMessageBox("Added notes out of range","Error",0) -- error message
								return
							end
							
							table.insert(tableEvents, string.pack("i4Bs4", offset, flags, msg)) -- re-pack MIDI string and write original notes to table. Repack here already, so that offset = 0 has reference points
							
							msg_addNotes = msg:sub(1,1) .. string.char(new_pitch) .. msg:sub(3,3) -- if new notes are in range, concatenate msg with new pitch values
							table.insert(tableEvents, string.pack("i4Bs4", 0, flags, msg_addNotes)) -- re-pack MIDI string and write added notes to table
						else 
							table.insert(tableEvents, string.pack("i4Bs4", offset, flags, msg))
						end
					end
					reaper.MIDI_Sort(take)
					reaper.MIDI_SetAllEvts(take, table.concat(tableEvents) .. MIDIstring:sub(-12))
				else
					reaper.ShowMessageBox("The selected item #".. i+1 .." does not contain a MIDI take and won't be altered", "Error", 0)
				end
			end
		end
	end


	-- check, where the user wants to transpose notes: inline editor, arrangement or MIDI editor

	local window, segment, details = reaper.BR_GetMouseCursorContext() -- initialize cursor context
	local _, inline_editor, _, _, _, _ = reaper.BR_GetMouseCursorContext_MIDI() -- check if mouse hovers an inline editor

	if inline_editor then
		local take = reaper.BR_GetMouseCursorContext_Take() -- get take from mouse
		Add_Notes_Interval_MIDI_Editor(take) -- execute function and pass over take

	else -- no inline editor hovered, check for MIDI editor

		if window ~= "midi_editor" then -- MIDI editor is not focused
			Add_Notes_Interval_Arrangement()

		else -- MIDI editor is focused
			local midi_editor = reaper.MIDIEditor_GetActive() -- get active MIDI editor 
			local take = reaper.MIDIEditor_GetTake(midi_editor) -- get take from active MIDI editor
			Add_Notes_Interval_MIDI_Editor(take) -- execute function and pass over take
		end
	end

	reaper.UpdateArrange()
end
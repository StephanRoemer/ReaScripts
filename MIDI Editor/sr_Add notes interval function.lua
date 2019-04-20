--  @noindex

function AddNotesInterval(interval)
	
	
	-- add notes interval in MIDI/inline editor (respect note selection)

	local function AddNotesIntervalMIDIEditor(take)

		if reaper.MIDI_EnumSelNotes(take, -1) ~= -1 then notes_selected = true end -- check, if there are selected notes, set notes_selected to true
		
		got_all_ok, midi_string = reaper.MIDI_GetAllEvts(take, "") -- write MIDI events to midi_string, get all events okay
		if not got_all_ok then reaper.ShowMessageBox("Error while loading MIDI", "Error", 0) return(false) end -- if getting the MIDI data failed

		midi_len = #midi_string -- get string length
		table_events = {} -- initialize table, MIDI events will temporarily be stored in this table until they are concatenated into a string again
		string_pos = 1 -- position in midi_string while parsing through events 
				
		while string_pos < midi_len-12 do -- parse through all events in the MIDI string, one-by-one, excluding the final 12 bytes, which provides REAPER's All-notes-off end-of-take message
			offset, flags, msg, string_pos = string.unpack("i4Bs4", midi_string, string_pos) -- unpack MIDI-string on string_pos
			new_pitch = msg:byte(2) + interval -- get current pitch, add interval and write new value to pitch
			
			if #msg == 3 -- if msg consists of 3 bytes (= channel message)
			and ((msg:byte(1)>>4) == 9 or (msg:byte(1)>>4) == 8) -- Is note-on or note-off?
			and (flags&1 == 1 or not notes_selected) -- selected notes always move, unselected only move if no notes are selected
			then
				if new_pitch < 0 or new_pitch > 127 then -- if new notes are out of range
					reaper.ShowMessageBox("Added notes are out of range","Error",0) -- error message
					return
				end
				
				table.insert(table_events, string.pack("i4Bs4", offset, flags, msg)) -- re-pack MIDI string and write original notes to table. Repack here already, so that offset = 0 has reference points
				msg_addNotes = msg:sub(1,1) .. string.char(new_pitch) .. msg:sub(3,3) -- if new notes are in range, concatenate msg with new pitch values
				table.insert(table_events, string.pack("i4Bs4", 0, flags, msg_addNotes)) -- re-pack MIDI string and write added notes to table
			else 
				table.insert(table_events, string.pack("i4Bs4", offset, flags, msg)) -- re-pack MIDI string and write unchanged events
			end
		end
		reaper.MIDI_Sort(take)
		reaper.MIDI_SetAllEvts(take, table.concat(table_events) .. midi_string:sub(-12))
	end


	-- add notes interval in arrange view (ignore note selection)

	local function AddNotesIntervalArrange(take)

		got_all_ok, midi_string = reaper.MIDI_GetAllEvts(take, "") -- write MIDI events to midi_string, get all events okay
		if not got_all_ok then reaper.ShowMessageBox("Error while loading MIDI", "Error", 0) return(false) end -- if getting the MIDI data failed

		midi_len = #midi_string -- get string length
		table_events = {} -- initialize table, MIDI events will temporarily be stored in this table until they are concatenated into a string again
		string_pos = 1 -- position in midi_string while parsing through events 
		
		while string_pos < midi_len-12 do -- parse through all events in the MIDI string, one-by-one, excluding the final 12 bytes, which provides REAPER's All-notes-off end-of-take message
			offset, flags, msg, string_pos = string.unpack("i4Bs4", midi_string, string_pos) -- unpack MIDI-string on string_pos
			new_pitch = msg:byte(2) + interval -- get current pitch, add interval and write new value to pitch
			
			if #msg == 3 -- if msg consists of 3 bytes (= channel message)
			and ((msg:byte(1)>>4) == 9 or (msg:byte(1)>>4) == 8) -- Is note-on or note-off?
			and (flags&1 == 1 or not notesSelected) -- selected notes always move, unselected only move if no notes are selected
			then
				if new_pitch < 0 or new_pitch > 127 then -- if new notes are out of range
					reaper.ShowMessageBox("Added notes are out of range","Error",0) -- error message
					return
				end
				
				table.insert(table_events, string.pack("i4Bs4", offset, flags, msg)) -- re-pack MIDI string and write original notes to table. Repack here already, so that offset = 0 has reference points
				
				msg_addNotes = msg:sub(1,1) .. string.char(new_pitch) .. msg:sub(3,3) -- if new notes are in range, concatenate msg with new pitch values
				table.insert(table_events, string.pack("i4Bs4", 0, flags, msg_addNotes)) -- re-pack MIDI string and write added notes to table
			else 
				table.insert(table_events, string.pack("i4Bs4", offset, flags, msg)) -- re-pack MIDI string and write unchanged events
			end
		end
		reaper.MIDI_Sort(take)
		reaper.MIDI_SetAllEvts(take, table.concat(table_events) .. midi_string:sub(-12))
	end


	-- check, where the user wants to change notes: MIDI editor, inline editor or anywhere else

	local take, item
	local window, _, _ = reaper.BR_GetMouseCursorContext() -- initialize cursor context
	local _, inline_editor, _, _, _, _ = reaper.BR_GetMouseCursorContext_MIDI() -- check if mouse hovers an inline editor
	
	if window == "midi_editor" then -- MIDI editor focused
		
		if not inline_editor then -- not hovering inline editor
			take = reaper.MIDIEditor_GetTake(reaper.MIDIEditor_GetActive()) -- get take from active MIDI editor
		
		else -- hovering inline editor (will ignore item selection and only change data in the hovered inline editor)
			take = reaper.BR_GetMouseCursorContext_Take() -- get take from mouse
		end

		AddNotesIntervalMIDIEditor(take) -- add notes interval
			
	else -- anywhere else (apply to selected items in arrane view)
		if reaper.CountSelectedMediaItems(0) ~= 0 then
			for i = 0, reaper.CountSelectedMediaItems(0)-1 do -- loop through all selected items
				item = reaper.GetSelectedMediaItem(0, i) -- get current selected item
				take = reaper.GetActiveTake(item)
				
				if reaper.TakeIsMIDI(take) then -- make sure, that take is MIDI

					AddNotesIntervalArrange(take) -- add notes interval
					
				else
					reaper.ShowMessageBox("The selected item #".. i+1 .." does not contain a MIDI take and won't be altered", "Error", 0)
				end
			end
		else
			reaper.ShowMessageBox("Please select at least one item", "Error", 0)
			return false
		end
	end
	reaper.UpdateArrange()
end
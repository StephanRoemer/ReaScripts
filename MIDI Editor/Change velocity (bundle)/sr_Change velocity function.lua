--  @noindex

function ChangeVelocity(new_velocity)

	
	-- change velocity of notes in the MIDI/inline editor (respect note selection)

	local function ChangeVelocityMIDIEditor(take)
		
		if reaper.MIDI_EnumSelNotes(take, -1) ~= -1 then notes_selected = true end -- check, if there are selected notes, set notes_selected to true
		
		got_all_ok, midi_string = reaper.MIDI_GetAllEvts(take, "") -- write MIDI events to midi_string, get all events okay
		if not got_all_ok then reaper.ShowMessageBox("Error while loading MIDI", "Error", 0) return(false) end -- if getting the MIDI data failed

		midi_len = #midi_string -- get string length
		table_events = {} -- initialize table, MIDI events will temporarily be stored in this table until they are concatenated into a string again
		string_pos = 1 -- position in midi_string while parsing through events 

		while string_pos < midi_len-12 do -- parse through all events in the MIDI string, one-by-one, excluding the final 12 bytes, which provides REAPER's All-notes-off end-of-take message
			offset, flags, msg, string_pos = string.unpack("i4Bs4", midi_string, string_pos) -- unpack MIDI-string on string_pos

			if #msg == 3 
			and (msg:byte(1)>>4) == 9 -- note-on?
			and (flags&1 == 1 or not notes_selected) -- selected notes always change velocity, unselected only chnange velocity if no notes are selected
			then
				msg_b3 = msg:byte(3) -- get velocity value

				if msg_b3 + new_velocity < 1 then 
					msg_b3 = 1 -- set velocity to 1, if current velocity + new velocity gets smaller than 1
				elseif msg_b3 + new_velocity > 127 then 
					msg_b3 = 127 -- set velocity to 127, if current velocity + new velocity gets bigger than 127
				else
					msg_b3 = msg_b3+new_velocity -- increase velocity by new_velocity
				end
				msg = msg:sub(1,1) .. msg:sub(2,2) .. string.char(msg_b3) -- convert velocity value to string, concatenate msg
			end    
			table.insert(table_events, string.pack("i4Bs4", offset, flags, msg)) -- re-pack MIDI string
		end
		reaper.MIDI_SetAllEvts(take, table.concat(table_events) .. midi_string:sub(-12))
		reaper.MIDI_Sort(take)
	end


	-- change velocity of notes in arrange view (ignore note selection)

	local function ChangeVelocityArrange(take)

		got_all_ok, midi_string = reaper.MIDI_GetAllEvts(take, "") -- write MIDI events to midi_string, get all events okay
		if not got_all_ok then reaper.ShowMessageBox("Error while loading MIDI", "Error", 0) return(false) end -- if getting the MIDI data failed

		midi_len = #midi_string -- get string length
		table_events = {} -- initialize table, MIDI events will temporarily be stored in this table until they are concatenated into a string again
		string_pos = 1 -- position in midi_string while parsing through events 

		while string_pos < midi_len-12 do -- parse through all events in the MIDI string, one-by-one, excluding the final 12 bytes, which provides REAPER's All-notes-off end-of-take message
			offset, flags, msg, string_pos = string.unpack("i4Bs4", midi_string, string_pos) -- unpack MIDI-string on string_pos

			if #msg == 3 
			and (msg:byte(1)>>4) == 9 -- note-on?
			then
				msg_b3 = msg:byte(3) -- get velocity value

				if msg_b3 + new_velocity < 1
					then msg_b3 = 1 -- set velocity to 1, if current velocity + new velocity gets smaller than 1
				elseif msg_b3 + new_velocity > 127
					then msg_b3 = 127 -- set velocity to 127, if current velocity + new velocity gets bigger than 127
				else
					msg_b3 = msg_b3+new_velocity -- increase velocity by new_velocity
				end
				msg = msg:sub(1,1) .. msg:sub(2,2) .. string.char(msg_b3) -- convert velocity value to string, concatenate msg
			end    
			table.insert(table_events, string.pack("i4Bs4", offset, flags, msg)) -- re-pack MIDI string
		end
		reaper.MIDI_SetAllEvts(take, table.concat(table_events) .. midi_string:sub(-12))
		reaper.MIDI_Sort(take)
	end


	-- check, where the user wants to change notes: MIDI editor, inline editor or anywhere else

	local take, item, new_velocity
	local window, _, _ = reaper.BR_GetMouseCursorContext() -- initialize cursor context
	local _, inline_editor, _, _, _, _ = reaper.BR_GetMouseCursorContext_MIDI() -- check if mouse hovers an inline editor

	if window == "midi_editor" then -- MIDI editor focused
		
		if 	not inline_editor then --  not hovering inline editor
			take = reaper.MIDIEditor_GetTake(reaper.MIDIEditor_GetActive()) -- get take from active MIDI editor
			item = reaper.GetMediaItemTake_Item(take) -- get item from take

		else -- hovering inline editor (will ignore item selection and only change data in the hovered inline editor)
			take = reaper.BR_GetMouseCursorContext_Take() -- get take from mouse
			item = reaper.GetMediaItemTake_Item(take) -- get item from take
		end
		
		ChangeVelocityMIDIEditor(take) -- change velocity

	else -- anywhere else (apply to selected items in arrane view)
		if reaper.CountSelectedMediaItems(0) ~= 0 then
			for i = 0, reaper.CountSelectedMediaItems(0)-1 do -- loop through all selected items
				item = reaper.GetSelectedMediaItem(0, i) -- get current selected item
				take = reaper.GetActiveTake(item) -- get take of item

				if reaper.TakeIsMIDI(take) then -- make sure, that take is MIDI
					
					ChangeVelocityArrange(take) -- change velocity
					
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
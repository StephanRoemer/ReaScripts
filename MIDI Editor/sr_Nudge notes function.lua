--  @noindex

function NudgeNotes(new_position)
	
	
	-- nudge notes in in MIDI/inline editor
	
	function NudgeNotes_MIDI_Editor(take)

		local _, notes_count, _, _ = reaper.MIDI_CountEvts(take) -- count notes and save amount to notes_count
		
		if reaper.MIDI_EnumSelNotes(take, -1) ~= -1 then notes_selected = true end -- check, if there are selected notes, set notes_selected to true
		
		gotAllOK, MIDIstring = reaper.MIDI_GetAllEvts(take, "") -- write MIDI events to MIDIstring, get all events okay

		if not gotAllOK then reaper.ShowMessageBox("Error while loading MIDI", "Error", 0) return(false) end -- if getting the MIDI data failed
		MIDIlen = #MIDIstring -- get string length
		tableEvents = {} -- initialize table, MIDI events will temporarily be stored in this table until they are concatenated into a string again
		stringPos = 1 -- position in MIDIstring while parsing through events 
		
		while stringPos < MIDIlen-12 do -- parse through all events in the MIDI string, one-by-one, excluding the final 12 bytes, which provides REAPER's All-notes-off end-of-take message
			offset, flags, msg, stringPos = string.unpack("i4Bs4", MIDIstring, stringPos) -- unpack MIDI-string on stringPos

			if #msg == 3 
			and ((msg:byte(1)>>4) == 9 or (msg:byte(1)>>4) == 8) -- Is note-on or note-off?
			and (flags&1 == 1 or not notes_selected) -- selected notes always move, unselected only move if no notes are selected
			then
				table.insert(tableEvents, string.pack("i4Bs4", offset+newPosition, flags, msg)) -- move the note on event by newPosition
				table.insert(tableEvents, string.pack("i4Bs4", -newPosition, 0, "")) -- put an empty event after the note on event, to maintain the distance
			else
				table.insert(tableEvents, string.pack("i4Bs4", offset, flags, msg))
			end
		end
		reaper.MIDI_SetAllEvts(take, table.concat(tableEvents) .. MIDIstring:sub(-12))
		reaper.MIDI_Sort(take)
	end


	-- nudge notes in selected item(s) in arrangement

	function NudgeNotes_Arrangement()

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
		
						if #msg == 3 
						and ((msg:byte(1)>>4) == 9 or (msg:byte(1)>>4) == 8) -- Is note-on or note-off?
						then
							table.insert(tableEvents, string.pack("i4Bs4", offset+newPosition, flags, msg)) -- move the note on event by newPosition
							table.insert(tableEvents, string.pack("i4Bs4", -newPosition, 0, "")) -- put an empty event after the note on event, to maintain the distance
						else
							table.insert(tableEvents, string.pack("i4Bs4", offset, flags, msg))
						end
					end
					reaper.MIDI_SetAllEvts(take, table.concat(tableEvents) .. MIDIstring:sub(-12))
					reaper.MIDI_Sort(take)
				else
					reaper.ShowMessageBox("The selected item #".. i+1 .." does not contain a MIDI take and won't be altered", "Error", 0)
				end
			end
		end
	end


	-- check, where the user wants to change velocity: inline editor, arrangement or MIDI editor

	local window, segment, details = reaper.BR_GetMouseCursorContext() -- initialize cursor context
	local _, inline_editor, _, _, _, _ = reaper.BR_GetMouseCursorContext_MIDI() -- check if mouse hovers an inline editor

	if inline_editor then
		local take = reaper.BR_GetMouseCursorContext_Take() -- get take from mouse
		NudgeNotes_MIDI_Editor(take) -- execute function and pass over take

	else -- no inline editor hovered, check for MIDI editor

		if window ~= "midi_editor" then -- MIDI editor is not focused
			NudgeNotes_Arrangement()

		else -- MIDI editor is focused
			local midi_editor = reaper.MIDIEditor_GetActive() -- get active MIDI editor 
			local take = reaper.MIDIEditor_GetTake(midi_editor) -- get take from active MIDI editor
			NudgeNotes_MIDI_Editor(take) -- execute function and pass over take
		end
	end

	reaper.UpdateArrange()
end
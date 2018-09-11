-- @noindex

function transpose(interval)

	for i = 0, reaper.CountSelectedMediaItems(0)-1 do -- loop through all selected items
		item = reaper.GetSelectedMediaItem(0, i) -- get current selected item
		
		for t = 0, reaper.CountTakes(item)-1 do -- loop through all takes within each selected item
			take = reaper.GetTake(item, t) -- get current take
			
			if reaper.TakeIsMIDI(take) then -- make sure, that take is MIDI
				gotAllOK, MIDIstring = reaper.MIDI_GetAllEvts(take, "") -- write MIDI events to MIDIstring, get all events okay
				
				if not gotAllOK then reaper.ShowMessageBox("Error while loading MIDI", "Error", 0) return(false) end -- if getting the MIDI data failed
				MIDIlen = #MIDIstring -- get string length
				tableEvents = {} -- initialize table, MIDI events will temporarily be stored in this table until they are concatenated into a string again
				stringPos = 1 -- position in MIDIstring while parsing through events 
				
				if reaper.MIDI_EnumSelNotes(take, -1) ~= -1 then -- check, if there are selected notes
					notesSelected = true -- set notesSelected to true
 				end
				
				 while stringPos < MIDIlen-12 do -- Now parse through all events in the MIDI string, one-by-one, excluding the final 12 bytes, which provides REAPER's All-notes-off end-of-take message
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
						
						msg = msg:sub(1,1) .. string.char(new_pitch) .. msg:sub(3,3) -- if transposition is in range, concatenate msg with new pitch values
      					table.insert(tableEvents, string.pack("i4Bs4", offset, flags, msg)) -- re-pack MIDI string with new_pitch and write to table
					else 
						table.insert(tableEvents, string.pack("i4Bs4", offset, flags, msg)) -- re-pack MIDI string and write untouched events to table
					end
        		end
			end
		end
	end
	reaper.MIDI_SetAllEvts(take, table.concat(tableEvents) .. MIDIstring:sub(-12))
	reaper.MIDI_Sort(take)
	reaper.UpdateArrange()
end
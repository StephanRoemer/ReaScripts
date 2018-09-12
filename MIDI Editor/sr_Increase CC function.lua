--  @noindex

function IncreaseCC(dest_cc, increase)
	
	for i = 0, reaper.CountSelectedMediaItems(0)-1 do -- loop through all selected items
		item = reaper.GetSelectedMediaItem(0, i) -- get current selected item
	
		for t = 0, reaper.CountTakes(item)-1 do -- loop through all takes within each selected item
			take = reaper.GetTake(item, t) -- get current take
	
			if reaper.TakeIsMIDI(take) then -- make sure, that take is MIDI
				
				gotAllOK, MIDIstring = reaper.MIDI_GetAllEvts(take, "") -- write MIDI events to MIDIstring, get all events okay
	
				if not gotAllOK then reaper.ShowMessageBox("Error while loading MIDI", "Error", 0) return(false) end -- if getting the MIDI data failed
				MIDIlen = #MIDIstring -- get string length
				stringPos = 1 -- position in MIDIstring while parsing through events 
				
				-- first iteration to check if dest_cc has selected events
				while stringPos < MIDIlen-12 do -- parse through all events in the MIDI string, one-by-one, excluding the final 12 bytes, which provides REAPER's All-notes-off end-of-take message
					offset, flags, msg, stringPos = string.unpack("i4Bs4", MIDIstring, stringPos) -- unpack MIDI-string on stringPos
	
					if #msg == 3 -- if msg consists of 3 bytes (= channel message)
					and (msg:byte(1)>>4) == 11 and msg:byte(2) == dest_cc 
					and (flags&1 == 1) -- if status byte is a CC, CC# equals dest_cc and event is selected
					then
						dest_cc_selected = 1 -- at least one selection was found
						break
					end
				end
				
				tableEvents = {} -- initialize table, MIDI events will temporarily be stored in this table until they are concatenated into a string again
				stringPos = 1 -- position in MIDIstring while parsing through events 
	
				-- second iteration to increase dest_cc based on selection or no selection
				while stringPos < MIDIlen-12 do -- parse through all events in the MIDI string, one-by-one, excluding the final 12 bytes, which provides REAPER's All-notes-off end-of-take message
					offset, flags, msg, stringPos = string.unpack("i4Bs4", MIDIstring, stringPos) -- unpack MIDI-string on stringPos
	
					if #msg == 3 -- if msg consists of 3 bytes (= channel message)
					and (msg:byte(1)>>4) == 11 and msg:byte(2) == dest_cc  -- if status byte is a CC, CC# equals dest_cc 
					and (flags&1 == 1 or not dest_cc_selected) -- and event or muted event is selected
					then
						msg_b3 = msg:byte(3) -- get CC value
						msg = msg:sub(1,1) .. msg:sub(2,2) .. string.char(math.min(127, (math.ceil(msg_b3*increase)))) -- increase CC value, convert CC value to string, concatenate msg
					end
       				table.insert(tableEvents, string.pack("i4Bs4", offset, flags, msg)) -- re-pack MIDI string and write to table
        		end
			end
		end
	end
	reaper.MIDI_SetAllEvts(take, table.concat(tableEvents) .. MIDIstring:sub(-12))
	reaper.MIDI_Sort(take)
	reaper.UpdateArrange()
end
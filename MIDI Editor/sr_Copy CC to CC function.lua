--  @noindex

function CopySrcCCToDestCC(src_cc, dest_cc)
    
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
				stringPos = 1 -- position in MIDIstring while parsing through events 
	
				-- first iteration to check if src_cc has selected events
                while stringPos < MIDIlen-12 do -- parse through all events in the MIDI string, one-by-one, excluding the final 12 bytes, which provides REAPER's All-notes-off end-of-take message
					offset, flags, msg, stringPos = string.unpack("i4Bs4", MIDIstring, stringPos) -- unpack MIDI-string on stringPos
    
                    if #msg == 3 -- if msg consists of 3 bytes (= channel message)
					and (msg:byte(1)>>4) == 11 and msg:byte(2) == src_cc 
					and (flags&1 == 1) -- if status byte is a CC, CC# equals dest_cc and event is selected
					then
						src_cc_selected = 1 -- at least one selection was found
						break
					end
				end
    
                -- second iteration to copy dest_cc based on selection or no selection
				tableEvents = {} -- initialize table, MIDI events will temporarily be stored in this table until they are concatenated into a string again
				stringPos = 1 -- position in MIDIstring while parsing through events 
    
                while stringPos < MIDIlen-12 do -- parse through all events in the MIDI string, one-by-one, excluding the final 12 bytes, which provides REAPER's All-notes-off end-of-take message
					offset, flags, msg, stringPos = string.unpack("i4Bs4", MIDIstring, stringPos) -- unpack MIDI-string on stringPos
    
                    if #msg == 3 -- if msg consists of 3 bytes (= channel message)
					and (msg:byte(1)>>4) == 11 and msg:byte(2) == src_cc  -- if status byte is a CC, CC# equals dest_cc and event is selected
					and (flags&1 == 1 or not src_cc_selected) 
					then
						table.insert(tableEvents, string.pack("i4Bs4", offset, flags, msg)) -- re-pack MIDI string and write untouched data
						msg = msg:sub(1,1) .. string.char(dest_cc) .. msg:sub(3,3) -- write msg chunk with dest CC
						table.insert(tableEvents, string.pack("i4Bs4", 0, flags, msg)) -- re-pack MIDI string and write copied CC events to dest_cc
					else -- if there are NO selected dest_cc events 
						table.insert(tableEvents, string.pack("i4Bs4", offset, flags, msg)) -- re-pack MIDI string and write untouched data
					end
				end
			end
			reaper.MIDI_SetAllEvts(take, table.concat(tableEvents) .. MIDIstring:sub(-12))
			reaper.MIDI_Sort(take)
		end
	end
	reaper.UpdateArrange()
end
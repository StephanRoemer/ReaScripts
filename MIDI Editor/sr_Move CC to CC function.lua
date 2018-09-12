--  @noindex

function MoveSrcCCToDestCC(src_cc, dest_cc)
    
    for i = 0, reaper.CountSelectedMediaItems(0)-1 do -- loop through all selected items
		item = reaper.GetSelectedMediaItem(0, i) -- get current selected item
    
        for t = 0, reaper.CountTakes(item)-1 do -- Loop through all takes within each selected item
			take = reaper.GetTake(item, t) -- get current take
    
            if reaper.TakeIsMIDI(take) then -- make sure, that take is MIDI
				-- first iteration to check if src_cc has selected events
				gotAllOK, MIDIstring = reaper.MIDI_GetAllEvts(take, "") -- write MIDI events to MIDIstring, get all events okay
    
                if not gotAllOK then reaper.ShowMessageBox("Error while loading MIDI", "Error", 0) return(false) end -- if getting the MIDI data failed
				MIDIlen = #MIDIstring -- get string length
				stringPos = 1 -- position in MIDIstring while parsing through events 
    
                while stringPos < MIDIlen-12 do -- parse through all events in the MIDI string, one-by-one, excluding the final 12 bytes, which provides REAPER's All-notes-off end-of-take message
					offset, flags, msg, stringPos = string.unpack("i4Bs4", MIDIstring, stringPos) -- unpack MIDI-string on stringPos
    
                    if #msg == 3 -- if msg consists of 3 bytes (= channel message)
					and (msg:byte(1)>>4) == 11 and msg:byte(2) == src_cc 
					and (flags&1 == 1) -- if status byte is a CC, CC# equals dest_cc and event is selected
					then
						srcCcSelected = 1 -- at least one selection was found
						break
					end
				end
    
                -- second iteration to increase dest_cc based on selection or no selection
				tableEvents = {} -- initialize table, MIDI events will temporarily be stored in this table until they are concatenated into a string again
				stringPos = 1 -- position in MIDIstring while parsing through events 
    
                while stringPos < MIDIlen-12 do -- parse through all events in the MIDI string, one-by-one, excluding the final 12 bytes, which provides REAPER's All-notes-off end-of-take message
					offset, flags, msg, stringPos = string.unpack("i4Bs4", MIDIstring, stringPos) -- unpack MIDI-string on stringPos
    
                    if #msg == 3 -- if msg consists of 3 bytes (= channel message)
					and (msg:byte(1)>>4) == 11 and msg:byte(2) == src_cc  -- if status byte is a CC, CC# equals dest_cc and event is selected
					and (flags&1 == 1 or not srcCcSelected) 
					then
						msg = msg:sub(1,1) .. string.char(dest_cc) .. msg:sub(3,3) -- write msg chunk with copied CC
						table.insert(tableEvents, string.pack("i4Bs4", offset, flags, msg)) -- re-pack MIDI string and write copied CC events to dest_cc
					else -- if there are NO selected dest_cc events 
						table.insert(tableEvents, string.pack("i4Bs4", offset, flags, msg)) -- re-pack MIDI string and write untouched data
					end
				end
			end
		end
	end
	reaper.MIDI_SetAllEvts(take, table.concat(tableEvents) .. MIDIstring:sub(-12))
	reaper.MIDI_Sort(take)
	reaper.UpdateArrange()
end
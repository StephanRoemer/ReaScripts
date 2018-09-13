--  @noindex

function NudgeNotes(new_position)
    
    if reaper.CountSelectedMediaItems(0) == 0 then
		reaper.ShowMessageBox("Please select at least one item", "Error", 0)
		return false
	else 
		for i = 0, reaper.CountSelectedMediaItems(0)-1 do -- loop through all selected items
			local item = reaper.GetSelectedMediaItem(0, i) -- get current selected item
			local take = reaper.GetActiveTake(item)
            
            if reaper.TakeIsMIDI(take) then -- make sure, that take is MIDI
				if reaper.MIDI_EnumSelNotes(take, -1) ~= -1 then -- check, if there are selected notes
					notesSelected = true -- set notesSelected to true
				end
				gotAllOK, MIDIstring = reaper.MIDI_GetAllEvts(take, "") -- write MIDI events to MIDIstring, get all events okay
    
                if not gotAllOK then reaper.ShowMessageBox("Error while loading MIDI", "Error", 0) return(false) end -- if getting the MIDI data failed
				MIDIlen = #MIDIstring -- get string length
				tableEvents = {} -- initialize table, MIDI events will temporarily be stored in this table until they are concatenated into a string again
				stringPos = 1 -- position in MIDIstring while parsing through events 
    
                while stringPos < MIDIlen-12 do -- parse through all events in the MIDI string, one-by-one, excluding the final 12 bytes, which provides REAPER's All-notes-off end-of-take message
					offset, flags, msg, stringPos = string.unpack("i4Bs4", MIDIstring, stringPos) -- unpack MIDI-string on stringPos
    
                    if #msg == 3 
					and ((msg:byte(1)>>4) == 9 or (msg:byte(1)>>4) == 8) -- Is note-on or note-off?
					and (flags&1 == 1 or not notesSelected) -- selected notes always move, unselected only move if no notes are selected
					then
    					table.insert(tableEvents, string.pack("i4Bs4", offset+newPosition, flags, msg)) -- move the note on event by newPosition
    					table.insert(tableEvents, string.pack("i4Bs4", -newPosition, 0, "")) -- put an empty event after the note on event, to maintain the distance
					else
    					table.insert(tableEvents, string.pack("i4Bs4", offset, flags, msg))
					end
				end
			end
			reaper.MIDI_SetAllEvts(take, table.concat(tableEvents) .. MIDIstring:sub(-12))
			reaper.MIDI_Sort(take)
		end
	end
	reaper.UpdateArrange()
end

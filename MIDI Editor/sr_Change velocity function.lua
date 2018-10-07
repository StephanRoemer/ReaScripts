--  @noindex

function ChangeVelocity(new_velocity)
    
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
					and (msg:byte(1)>>4) == 9 -- note-on?
					and (flags&1 == 1 or not notesSelected) -- selected notes always change velocity, unselected only chnange velocity if no notes are selected
                    then
                        local msg_b3 = msg:byte(3) -- get velocity value

                        if msg_b3 + new_velocity < 1
                            then msg_b3 = 1 -- set velocity to 1, if current velocity + new velocity gets smaller than 1
                        elseif msg_b3 + new_velocity > 127
                            then msg_b3 = 127 -- set velocity to 127, if current velocity + new velocity gets bigger than 127
                        else
                            msg_b3 = msg_b3+new_velocity
                        end

                        msg = msg:sub(1,1) .. msg:sub(2,2) .. string.char(msg_b3) -- convert velocity value to string, concatenate msg
                    end    
    				table.insert(tableEvents, string.pack("i4Bs4", offset, flags, msg))
				end
			end
			reaper.MIDI_SetAllEvts(take, table.concat(tableEvents) .. MIDIstring:sub(-12))
			reaper.MIDI_Sort(take)
		end
	end
	reaper.UpdateArrange()
end

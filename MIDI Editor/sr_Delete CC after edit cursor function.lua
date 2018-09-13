--  @noindex

function DeleteCCAfterEditCursor(dest_cc)
	
	local cursor_position = reaper.GetCursorPosition()  -- get edit cursor position 

	if reaper.CountSelectedMediaItems(0) == 0 then
		reaper.ShowMessageBox("Please select at least one item", "Error", 0)
		return false
	else 
		for i = 0, reaper.CountSelectedMediaItems(0)-1 do -- loop through all selected items
			local item = reaper.GetSelectedMediaItem(0, i) -- get current selected item
			local item_start = reaper.GetMediaItemInfo_Value(item, "D_POSITION")
			local take = reaper.GetActiveTake(item)
			local cursor_position_ppq = reaper.MIDI_GetPPQPosFromProjTime(take, cursor_position) -- convert cursor_position to PPQ
			local item_start_ppq = reaper.MIDI_GetPPQPosFromProjTime(take, item_start) -- convert item_start to PPQ
				
			if reaper.TakeIsMIDI(take) then
				gotAllOK, MIDIstring = reaper.MIDI_GetAllEvts(take, "") -- write MIDI events to MIDIstring, get all events okay

				if not gotAllOK then reaper.ShowMessageBox("Error while loading MIDI", "Error", 0) return(false) end -- if getting the MIDI data failed
				MIDIlen = #MIDIstring -- get string length
				tableEvents = {} -- initialize table, MIDI events will temporarily be stored in this table until they are concatenated into a string again
				local stringPos = 1 -- position in MIDIstring while parsing through events 
				local sum_offset = 0 -- initialize sum_offset (adds all offsets to get the position of every event in ticks)

				while stringPos < MIDIlen-12 do -- parse through all events in the MIDI string, one-by-one, excluding the final 12 bytes, which provides REAPER's All-notes-off end-of-take message
					offset, flags, msg, stringPos = string.unpack("i4Bs4", MIDIstring, stringPos) -- unpack MIDI-string on stringPos
					sum_offset = sum_offset+offset -- add all event offsets to get next start position of event on each iteration
					event_start = item_start_ppq+sum_offset -- calculate event start position based on item start position

					if #msg == 3 -- if msg consists of 3 bytes (= channel message)
					and (msg:byte(1)>>4) == 11	and msg:byte(2) == dest_cc -- if status byte is a CC and CC# equals dest_cc
					and event_start > cursor_position_ppq -- if events are before cursor position
					then
						msg ="" -- delete event (msg = "")
					end
					table.insert(tableEvents, string.pack("i4Bs4", offset, flags, msg)) -- re-pack MIDI string and write to table
				end
			end
			reaper.MIDI_SetAllEvts(take, table.concat(tableEvents) .. MIDIstring:sub(-12))
			reaper.MIDI_Sort(take)
		end
	end
	reaper.UpdateArrange()
end
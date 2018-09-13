-- @description Select all CCs
-- @version 1.30
-- @changelog
--   Switched to Get/SetAllEvts
-- @author Stephan Römer, Julian Sader
-- @provides [main=main,midi_editor,midi_inlineeditor] .
-- @about
--    # Description
--    * This script selects all CCs
--    * This script works in arrangement, MIDI Editor and Inline Editor
-- @link https://forums.cockos.com/showthread.php?p=1923923

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

				if #msg == 3 then -- if msg consists of 3 bytes (= channel message)
					msg_b1_nib1 = msg:byte(1)>>4 -- save 1st nibble of status byte to msg_b1_nib1, >>4 shifts the channel nibble into oblivion

					if msg_b1_nib1 == 11 then -- if status byte is a CC
						flags = flags|1 -- select muted or unmuted event
					end
				end
				table.insert(tableEvents, string.pack("i4Bs4", offset, flags, msg)) -- re-pack MIDI string and write all other events to table
			end
		end
		reaper.MIDI_SetAllEvts(take, table.concat(tableEvents) .. MIDIstring:sub(-12))
		reaper.MIDI_Sort(take)
	end
end
reaper.UpdateArrange()
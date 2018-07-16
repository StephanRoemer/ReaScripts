-- @description Delete all CCs before edit cursor
-- @version 1.2
-- @author Stephan Römer
-- @about
--    # Description
--    - this script deletes the data of all CC lanes before the edit cursor
--    - this script works in arrangement, MIDI Editor and Inline Editor
--
-- @link https://forums.cockos.com/showthread.php?p=1923923
--
-- @provides [main=main,midi_editor,midi_inlineeditor] .
-- @changelog
--     	v1.2 (2018-07-15)
-- 	   	+ switched to Get/SetAllEvnts (Julian Sader)
--     	v1.1 (2017-12-16)
--     	+ added undo state
--     	v1.0
--     	+ Initial release


cursorPosition = reaper.GetCursorPosition()  -- get edit cursor position 
sumOffset = 0 -- initialize sumOffset (adds all offsets to get the position of every event in ticks)
if reaper.CountSelectedMediaItems(0) > 1 then
	reaper.ShowMessageBox("Please select only one item", "Error" , 0) -- popup error message, if more than 1 item is selected
	return
elseif reaper.CountSelectedMediaItems(0) == 0 then 
	reaper.ShowMessageBox("Please select one item", "Error" , 0) -- popup error message, if no item is selected
	return
elseif reaper.CountSelectedMediaItems(0) == 1 then
	for i = 0, reaper.CountSelectedMediaItems(0)-1 do -- loop through all selected items
		item = reaper.GetSelectedMediaItem(0, i) -- get current selected item
		itemStart = reaper.GetMediaItemInfo_Value(item, "D_POSITION") -- get start of item
		for t = 0, reaper.CountTakes(item)-1 do -- loop through all takes within each selected item
			take = reaper.GetTake(item, t) -- get current take
			cursorPositionPPQ = reaper.MIDI_GetPPQPosFromProjTime(take, cursorPosition) -- convert cursorPosition to PPQ
			itemStartPPQ = reaper.MIDI_GetPPQPosFromProjTime(take, itemStart) -- convert itemStart to PPQ
			if reaper.TakeIsMIDI(take) then -- make sure, that take is MIDI
				gotAllOK, MIDIstring = reaper.MIDI_GetAllEvts(take, "") -- write MIDI events to MIDIstring, get all events okay
					if not gotAllOK then reaper.ShowMessageBox("Error while loading MIDI", "Error", 0) return(false) end -- if getting the MIDI data failed
				MIDIlen = MIDIstring:len() -- get string length
				tableEvents = {} -- initialize table, MIDI events will temporarily be stored in this table until they are concatenated into a string again
				stringPos = 1 -- position in MIDIstring while parsing through events 
				while stringPos < MIDIlen-12 do -- parse through all events in the MIDI string, one-by-one, excluding the final 12 bytes, which provides REAPER's All-notes-off end-of-take message
					offset, flags, msg, stringPos = string.unpack("i4Bs4", MIDIstring, stringPos) -- unpack MIDI-string on stringPos
					sumOffset = sumOffset+offset -- add all event offsets to get next start position of event on each iteration
					eventStart = itemStartPPQ+sumOffset -- calculate event start position based on item start position
					if msg:len() == 3 then -- if msg consists of 3 bytes (= channel message)
						msg_b1_nib1 = msg:byte(1)>>4 -- save 1st nibble of status byte (contains info about the data type) to msg_b1_nib1, >>4 shifts the channel nibble into oblivion
						if msg_b1_nib1 == 9 and eventStart <= cursorPositionPPQ then -- if status byte is a note on and events are after cursor position
							msg ="" -- delete event (msg = "")
						end
					end
					table.insert(tableEvents, string.pack("i4Bs4", offset, flags, msg)) -- re-pack MIDI string and write to table
				end
			end
		end
	end
end

reaper.MIDI_SetAllEvts(take, table.concat(tableEvents) .. MIDIstring:sub(-12))
reaper.MIDI_Sort(take)
reaper.UpdateArrange()

reaper.Undo_OnStateChange2(proj, "Delete all CCs before edit cursor")



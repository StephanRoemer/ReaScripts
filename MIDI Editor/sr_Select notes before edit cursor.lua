-- @description Select notes before edit cursor
-- @version 1.3
-- @changelog
--   switched to Get/SetAllEvts
-- @author Stephan Römer, with a lot of help from FnA and Julian Sader
-- @provides [main=main,midi_editor,midi_inlineeditor] .
-- @about
--    # Description
--    * Select all notes, that are located before the edit cursor position
--    * This script works in arrangement, MIDI Editor and Inline Editor
-- @link https://forums.cockos.com/showthread.php?p=1923923

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

			local c, m

			-- create table for note-ons
			note_on_selection = {}
			for c = 0, 15 do -- channel table
				note_on_selection[c] = {}
				for m = 0, 2, 2 do -- mute table
					note_on_selection[c][m] = {}
				end
			end

			gotAllOK, MIDIstring = reaper.MIDI_GetAllEvts(take, "") -- write MIDI events to MIDIstring, get all events okay
			if not gotAllOK then reaper.ShowMessageBox("Error while loading MIDI", "Error", 0) return(false) end -- if getting the MIDI data failed
			MIDIlen = #MIDIstring -- get string length
			tableEvents = {} -- initialize table, MIDI events will temporarily be stored in this table until they are concatenated into a string again
			local stringPos = 1 -- position in MIDIstring while parsing through events 
			local sum_offset = 0 -- initialize sum_offset (adds all offsets to get the position of every event in ticks)

			while stringPos < MIDIlen-12 do -- parse through all events in the MIDI string, one-by-one, excluding the final 12 bytes, which provides REAPER's All-notes-off end-of-take message
				offset, flags, msg, stringPos = string.unpack("i4Bs4", MIDIstring, stringPos) -- unpack MIDI-string on stringPos
				sum_offset = sum_offset+offset -- add all event offsets to get next start position of event on each iteration
				local event_start = item_start_ppq+sum_offset -- calculate event start position based on item start position
				local event_type = msg:byte(1)>>4 -- save 1st nibble of status byte (contains info about the data type) to event_type, >>4 shifts the channel nibble into oblivion
				
				if event_type == 9 and msg:byte(3) ~= 0 then -- if note-on and velocity is not 0
					local channel = msg:byte(1)&0x0F
					local pitch = msg:byte(2)
					
					if note_on_selection[channel][flags&2][pitch] then
						reaper.ShowMessageBox("Can't select, because overlapping notes in selected item #" .. i+1 .. " were found", "Error", 0)
						return false

					-- note-on before cursor position? select	
					elseif event_start <= cursor_position_ppq then
						flags = flags|1 -- select
						note_on_selection[channel][flags&2][pitch] = 1 -- tag note-on for selection

					-- note-on after cursor position? unselect 
					elseif event_start > cursor_position_ppq then 
						flags = flags&~1 -- unselect
						note_on_selection[channel][flags&2][pitch] = 0 -- untag note-on
					end
				
				elseif event_type == 8 or (event_type == 9 and msg:byte(3) == 0) then -- if note-off
						
					local channel = msg:byte(1)&0x0F
					local pitch = msg:byte(2)

					-- note-off anywhere and note-on before cursor? select
					if note_on_selection[channel][flags&2][pitch] == 1 then -- matching note-on tagged for selection?
						flags = flags|1 -- select
						note_on_selection[channel][flags&2][pitch] = nil -- clear note-on

					-- note-off and note-on after cursor? unselect
					elseif note_on_selection[channel][flags&2][pitch] == 0 then
						flags = flags&~1 -- unselect
						note_on_selection[channel][flags&2][pitch] = nil -- clear note-on
					end
				end
				table.insert(tableEvents, string.pack("i4Bs4", offset, flags, msg)) -- re-pack MIDI string and write to table
			end
		end
		reaper.MIDI_SetAllEvts(take, table.concat(tableEvents) .. MIDIstring:sub(-12))
		reaper.MIDI_Sort(take)
	end
end
reaper.UpdateArrange()
reaper.Undo_OnStateChange2(proj, "Select all notes before edit cursor")
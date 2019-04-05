-- @description Delete notes after edit cursor (in selected item(s) or MIDI editor)
-- @version 1.3
-- @changelog
--  * switched to Get/SetAllEvts method for faster MIDI processing
--  * better differentiation if user is in arrangement or MIDI editor
--  * changed the script name to something more descriptive
-- @author Stephan Römer, with a lot of help from FnA and Julian Sader
-- @provides [main=main,midi_editor,midi_inlineeditor] .
-- @about
--    # Description
--    * This script selects all notes after the edit cursor in currently selected items or in the currently opened take in the MIDI editor.
--    * Assign the script in the main action list, as well. That way, the inline editor will be opened automatically, when you select notes in the arrangement.
--    * This script works in the MIDI editor and inline editor and in the arrangement
-- @link https://forums.cockos.com/showthread.php?p=1923923



function Delete_Notes(take, item, cursor_position)

	local item_start = reaper.GetMediaItemInfo_Value(item, "D_POSITION") -- get start of item
	local item_start_ppq = reaper.MIDI_GetPPQPosFromProjTime(take, item_start) -- convert item_start to PPQ
	local cursor_position_ppq = reaper.MIDI_GetPPQPosFromProjTime(take, cursor_position) -- convert to PPQ
	
	local sum_offset = 0 -- initialize sum_offset (adds all offsets to get the position of every event in ticks)
	gotAllOK, MIDIstring = reaper.MIDI_GetAllEvts(take, "") -- write MIDI events to MIDIstring, get all events okay
	
	if not gotAllOK then reaper.ShowMessageBox("Error while loading MIDI", "Error", 0) return(false) end -- if getting the MIDI data failed
	
	MIDIlen = MIDIstring:len() -- get string length
	tableEvents = {} -- initialize table, MIDI events will temporarily be stored in this table until they are concatenated into a string again
	stringPos = 1 -- position in MIDIstring while parsing through events 
	
	while stringPos < MIDIlen-12 do -- parse through all events in the MIDI string, one-by-one, excluding the final 12 bytes, which provides REAPER's All-notes-off end-of-take message
		offset, flags, msg, stringPos = string.unpack("i4Bs4", MIDIstring, stringPos) -- unpack MIDI-string on stringPos
		sum_offset = sum_offset+offset -- add all event offsets to get next start position of event on each iteration
		event_start = item_start_ppq+sum_offset -- calculate event start position based on item start position
	
		if #msg == 3 -- if msg consists of 3 bytes (= channel message)
		and (msg:byte(1)>>4) == 9 and event_start >= cursor_position_ppq 
		or (msg:byte(1)>>4) == 8 and event_start-offset > cursor_position_ppq
		then
			msg = 0 -- delete note
		end
		table.insert(tableEvents, string.pack("i4Bs4", offset, flags, msg)) -- re-pack MIDI string and write to table
	end
	reaper.MIDI_SetAllEvts(take, table.concat(tableEvents) .. MIDIstring:sub(-12))
	reaper.MIDI_Sort(take)
end


-- check, where the user wants to select notes

local window, _, details = reaper.BR_GetMouseCursorContext() -- initialize cursor context
local _, inline_editor, _, _, _, _ = reaper.BR_GetMouseCursorContext_MIDI() -- check if mouse hovers an inline editor

local cursor_position = reaper.GetCursorPosition()  -- get edit cursor position 

if window == "midi_editor" and not inline_editor then -- MIDI editor focused and not hovering inline editor
	local midi_editor = reaper.MIDIEditor_GetActive() -- get active MIDI editor
	local take = reaper.MIDIEditor_GetTake(midi_editor) -- get take from active MIDI editor
	local item = reaper.GetMediaItemTake_Item(take) -- get item from take
	Delete_Notes(take, item, cursor_position) -- execute function	

elseif window == "arrange" or inline_editor then -- if user is in the arrangement or hovering the inline editor
	if reaper.CountSelectedMediaItems(0) == 0 then
		reaper.ShowMessageBox("Please select at least one item", "Error", 0)
		return false

	else 
		for i = 0, reaper.CountSelectedMediaItems(0)-1 do -- loop through all selected items
			local item = reaper.GetSelectedMediaItem(0, i) -- get current selected item
			local take = reaper.GetActiveTake(item)
			if reaper.TakeIsMIDI(take) then
				Delete_Notes(take, item, cursor_position) -- execute function
			else
				reaper.ShowMessageBox("Selected item #".. i+1 .. " does not contain a MIDI take and won't be altered", "Error", 0)	
			end	
		end
	end
end

reaper.UpdateArrange()
reaper.Undo_OnStateChange2(proj, "Delete notes after edit cursor (in selected item(s) or MIDI editor)")
-- @description Increase events in CC lane under mouse cursor
-- @version 1.0
-- @changelog
--   initial release
-- @author Stephan Römer
-- @provides [main=midi_editor] .
-- @about
--    # Description
--    * This script increases all or selected CC events in the lane under the mouse cursor
--    * This script works only in the MIDI Editor
-- @link https://forums.cockos.com/showthread.php?p=1923923


function CheckForSelectedEvents(cc_lane) -- check if cc_lane has selected events
	
	stringPos = 1 -- position in MIDIstring while parsing through events
	local selected_events = 0
	
	while stringPos < MIDIlen-12 do -- parse through all events in the MIDI string, one-by-one, excluding the final 12 bytes, which provides REAPER's All-notes-off end-of-take message
		offset, flags, msg, stringPos = string.unpack("i4Bs4", MIDIstring, stringPos) -- unpack MIDI-string on stringPos

		if #msg == 3 -- if msg consists of 3 bytes (= channel message)
		and (msg:byte(1)>>4) == 11 and msg:byte(2) == cc_lane -- if status byte is a CC, CC# equals cc_lane
		and (flags&1 == 1) -- and event is selected
		then
			selected_events = 1
			return selected_events -- at least one selection was found
		end
	end
end


function IncreaseCC(take, cc_lane, selected_events, increase)
	
	stringPos = 1 -- position in MIDIstring while parsing through events			
	tableEvents = {} -- initialize table, MIDI events will temporarily be stored in this table until they are concatenated into a string again

	while stringPos < MIDIlen-12 do -- parse through all events in the MIDI string, one-by-one, excluding the final 12 bytes, which provides REAPER's All-notes-off end-of-take message
		offset, flags, msg, stringPos = string.unpack("i4Bs4", MIDIstring, stringPos) -- unpack MIDI-string on stringPos

		if #msg == 3 -- if msg consists of 3 bytes (= channel message)
		and (msg:byte(1)>>4) == 11 and msg:byte(2) == cc_lane  -- if status byte is a CC, CC# equals cc_lane 
		and (flags&1 == 1 or not selected_events) -- and event or muted event is selected
		then
			msg_b3 = msg:byte(3) -- get CC value
			msg = msg:sub(1,1) .. msg:sub(2,2) .. string.char(math.min(127, (math.ceil(msg_b3*increase)))) -- increase CC value, convert CC value to string, concatenate msg
		end
		table.insert(tableEvents, string.pack("i4Bs4", offset, flags, msg)) -- re-pack MIDI string and write to table
	end
	reaper.MIDI_SetAllEvts(take, table.concat(tableEvents) .. MIDIstring:sub(-12))
	reaper.MIDI_Sort(take)
end


local cc_lane -- CC lane under mouse
local increase = 1.1 -- value to increase the CC event
_, _, _ = reaper.BR_GetMouseCursorContext() -- initiate "get mouse cursor context"
_, _, _, cc_lane, _, _ = reaper.BR_GetMouseCursorContext_MIDI() -- get CC lane
local take = reaper.MIDIEditor_GetTake(reaper.MIDIEditor_GetActive()) -- get active take in MIDI editor


if reaper.TakeIsMIDI(take) then -- make sure, that take is MIDI
    gotAllOK, MIDIstring = reaper.MIDI_GetAllEvts(take, "") -- write MIDI events to MIDIstring, get all events okay
    if not gotAllOK then reaper.ShowMessageBox("Error while loading MIDI", "Error", 0) return(false) end -- if getting the MIDI data failed
	
	MIDIlen = #MIDIstring -- get string length
	local selected_events = CheckForSelectedEvents(cc_lane) -- check for selected events
	IncreaseCC(take, cc_lane, selected_events, increase) -- increase CC events
end

reaper.UpdateArrange()
reaper.Undo_OnStateChange2(proj, "Increase events in CC"..cc_lane.." lane under mouse cursor")
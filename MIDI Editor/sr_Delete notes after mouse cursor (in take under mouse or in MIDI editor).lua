-- @description Delete notes after mouse cursor (in take under mouse or in MIDI editor)
-- @version 1.0
-- @changelog
--  * initial release
-- @author Stephan Römer, with a lot of help from FnA and Julian Sader
-- @provides [main=main,midi_editor,midi_inlineeditor] .
-- @about
--    # Description
--    * This script deletes all notes after the mouse cursor in the take that the mouse is currently hovering (arrangement and inline editor) or in the focused MIDI editor
--    * This script works in the arrangement, MIDI editor and Inline editor
-- @link https://forums.cockos.com/showthread.php?p=1923923


function Delete_Notes(take, item, mouse_pos)

	local item_start = reaper.GetMediaItemInfo_Value(item, "D_POSITION") -- get start of item
	local item_start_ppq = reaper.MIDI_GetPPQPosFromProjTime(take, item_start) -- convert item_start to PPQ
	local mouse_position_ppq = reaper.MIDI_GetPPQPosFromProjTime(take, mouse_pos) -- convert to PPQ
	
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
		and (msg:byte(1)>>4) == 9 and event_start >= mouse_position_ppq 
		or (msg:byte(1)>>4) == 8 and event_start-offset > mouse_position_ppq
		then -- if status byte is a note on and offset is before cursor position
			msg = 0 -- delete note
		end
		table.insert(tableEvents, string.pack("i4Bs4", offset, flags, msg)) -- re-pack MIDI string and write to table
	end
	reaper.MIDI_SetAllEvts(take, table.concat(tableEvents) .. MIDIstring:sub(-12))
	reaper.MIDI_Sort(take)
end


-- check, where the user wants to delete notes: arrangement, inline editor or MIDI editor

local window, _, details = reaper.BR_GetMouseCursorContext() -- initialize cursor context
local _, inline_editor, _, _, _, _ = reaper.BR_GetMouseCursorContext_MIDI() -- check if mouse hovers an inline editor

local mouse_pos = reaper.BR_GetMouseCursorContext_Position() -- get mouse position

if window == "midi_editor" and not inline_editor then -- MIDI editor focused and not hovering inline editor
    local midi_editor = reaper.MIDIEditor_GetActive() -- get active MIDI editor
    local take = reaper.MIDIEditor_GetTake(midi_editor) -- get take from active MIDI editor
    local item = reaper.GetMediaItemTake_Item(take) -- get item from take
    Delete_Notes(take, item, mouse_pos) -- execute function

elseif details == "item" or inline_editor then -- hovering item in arrange or inline editor
    local take = reaper.BR_GetMouseCursorContext_Take() -- get take under mouse
    if reaper.TakeIsMIDI(take) then -- is take MIDI?
        local item = reaper.BR_GetMouseCursorContext_Item() -- get item under mouse
        Delete_Notes(take, item, mouse_pos) -- execute function
    else -- if take is not MIDI
        reaper.ShowMessageBox("No MIDI take found. Please hover a MIDI take", "Error", 0)
        return false
    end
else -- no item is hovered
    reaper.ShowMessageBox("No MIDI take found. Please hover a MIDI take", "Error", 0)
    return false
end

reaper.UpdateArrange()
reaper.Undo_OnStateChange2(proj, "Delete notes after mouse (in take under mouse or in MIDI editor)")
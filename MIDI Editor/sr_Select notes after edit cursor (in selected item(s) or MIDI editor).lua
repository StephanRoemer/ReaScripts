-- @description Select notes after edit cursor (in selected item(s) or MIDI editor)
-- @version 1.3
-- @changelog
--  * switched to Get/SetAllEvts method for faster MIDI processing
--  * better differentiation if user is in arrangement or MIDI editor
--  * changed the script name to something more descriptive
-- @author Stephan Römer, with a lot of help from FnA and Julian Sader
-- @provides [main=main,midi_editor,midi_inlineeditor] .
-- @about
--    # Description
--    * This script selects all notes after the edit cursor in the currently focused MIDI editor or inline editor.
--    * Assign the script in the main action list, as well. That way, the inline editor will be opened automatically 
--    when hovering MIDI takes in the arrangement.
--    * This script works in the MIDI editor and inline editor and partly in the arrangement, as stated above
-- @link https://forums.cockos.com/showthread.php?p=1923923


function Select_Notes(take, item, cursor_position)
	
    -- create table for note-ons
	
    local c, m
    
    note_on_selection = {}
    for c = 0, 15 do -- channel table
        note_on_selection[c] = {}
        for f = 0, 2, 2 do -- flag table
            note_on_selection[c][f] = {}
        end
    end
	
	local item_start = reaper.GetMediaItemInfo_Value(item, "D_POSITION")
	local item_start_ppq = reaper.MIDI_GetPPQPosFromProjTime(take, item_start) -- convert item_start to PPQ
	local cursor_position_ppq = reaper.MIDI_GetPPQPosFromProjTime(take, cursor_position) -- convert cursor_position to PPQ
				
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
			
			-- check if current note-on is already tagged = overlapping note-ons!
			if note_on_selection[channel][flags&2][pitch] then
				reaper.ShowMessageBox("Can't select, because overlapping notes were found", "Error", 0)
				return false

			-- note-on after cursor position? select	
			elseif event_start > cursor_position_ppq then
				flags = flags|1 -- select
				note_on_selection[channel][flags&2][pitch] = true -- tag note-on for selection

			-- note-on before cursor position? unselect 
			elseif event_start <= cursor_position_ppq then 
				flags = flags &~ 1 -- unselect
				note_on_selection[channel][flags&2][pitch] = nil -- tag note-on for non-selection
			end
		
		elseif event_type == 8 or (event_type == 9 and msg:byte(3) == 0) then -- if note-off
				
			local channel = msg:byte(1)&0x0F
			local pitch = msg:byte(2)

			-- note-off anywhere and note-on after cursor? select
			if note_on_selection[channel][flags&2][pitch] then -- matching note-on tagged for selection?
				flags = flags|1 -- select
				note_on_selection[channel][flags&2][pitch] = nil -- reset tag
			
			-- note-off and note-on before cursor? unselect
			else
				flags = flags &~ 1 -- unselect
			end
		end
		table.insert(tableEvents, string.pack("i4Bs4", offset, flags, msg)) -- re-pack MIDI string and write to table
	end

	reaper.MIDI_SetAllEvts(take, table.concat(tableEvents) .. MIDIstring:sub(-12))
	reaper.MIDI_Sort(take)
end


-- check, where the user wants to select notes

local window, _, _ = reaper.BR_GetMouseCursorContext() -- initialize cursor context
local _, inline_editor, _, _, _, _ = reaper.BR_GetMouseCursorContext_MIDI() -- check if mouse hovers an inline editor

local cursor_position = reaper.GetCursorPosition()  -- get edit cursor position 

if window == "midi_editor" and not inline_editor then -- MIDI editor focused and not hovering inline editor
	local midi_editor = reaper.MIDIEditor_GetActive() -- get active MIDI editor
	local take = reaper.MIDIEditor_GetTake(midi_editor) -- get take from active MIDI editor
	local item = reaper.GetMediaItemTake_Item(take) -- get item from take
	Select_Notes(take, item, cursor_position) -- execute function	

elseif window == "arrange" or inline_editor then -- if user is in the arrangement or hovering the inline editor
	if reaper.CountSelectedMediaItems(0) == 0 then
		reaper.ShowMessageBox("Please select at least one item", "Error", 0)
		return false

	else 
		for i = 0, reaper.CountSelectedMediaItems(0)-1 do -- loop through all selected items
			local item = reaper.GetSelectedMediaItem(0, i) -- get current selected item
			local take = reaper.GetActiveTake(item)
			if reaper.TakeIsMIDI(take) then
				if not reaper.BR_IsMidiOpenInInlineEditor(take) then
					reaper.Main_OnCommand(40847, 0) -- open inline editor on selected item
				end
				Select_Notes(take, item, cursor_position) -- execute function
			else
				reaper.ShowMessageBox("Selected item #".. i+1 .. " does not contain a MIDI take and won't be altered", "Error", 0)	
			end	
		end
	end
end

reaper.UpdateArrange()
reaper.Undo_OnStateChange2(proj, "Select notes after edit cursor (in selected item(s) or MIDI editor)")
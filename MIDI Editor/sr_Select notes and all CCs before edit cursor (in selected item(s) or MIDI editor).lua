-- @description Select notes and all CCs before edit cursor (in selected item(s) or MIDI editor)
-- @version 1.0
-- @changelog
--  + initial release
-- @author Stephan Römer, with a lot of help from FnA and Julian Sader
-- @provides [main=main,midi_editor,midi_inlineeditor] .
-- @about
--    # Description
--    * This script selects all notes and CCs before the edit cursor in currently selected items or in the currently opened take in the MIDI editor.
--    * Assign the script in the main action list, as well. That way, the inline editor will be opened automatically, 
--    and you can see your selection in the arrange view.
--    * When hovering an inline editor, only the take under the mouse cursor will be affected, regardles of the item selection.
--    * You can easily customize the values in the scripts.
--    * The scripts work in the MIDI editor, inline editor and arrange view.
-- @link Forum Thread https://forums.cockos.com/showthread.php?p=1923923


local function SelectNotesAndCCsBeforeCursor(take, item, cursor_position_ppq)
	
    -- create table for note-ons
	
    note_on_tagging = {}
    for c = 0, 15 do -- channel table
        note_on_tagging[c] = {}
        for f = 0, 2, 2 do -- flag table
            note_on_tagging[c][f] = {}
        end
    end
	
	item_start = reaper.GetMediaItemInfo_Value(item, "D_POSITION")
	item_start_ppq = reaper.MIDI_GetPPQPosFromProjTime(take, item_start) -- convert item_start to PPQ
				
	got_all_ok, midi_string = reaper.MIDI_GetAllEvts(take, "") -- write MIDI events to midi_string, get all events okay
	if not got_all_ok then reaper.ShowMessageBox("Error while loading MIDI", "Error", 0) return(false) end -- if getting the MIDI data failed
	
	midi_len = #midi_string -- get string length
	table_events = {} -- initialize table, MIDI events will temporarily be stored in this table until they are concatenated into a string again
	string_pos = 1 -- position in midi_string while parsing through events 
	sum_offset = 0 -- initialize sum_offset (adds all offsets to get the position of every event in ticks)

	while string_pos < midi_len-12 do -- parse through all events in the MIDI string, one-by-one, excluding the final 12 bytes, which provides REAPER's All-notes-off end-of-take message
		offset, flags, msg, string_pos = string.unpack("i4Bs4", midi_string, string_pos) -- unpack MIDI-string on string_pos
		sum_offset = sum_offset+offset -- add all event offsets to get next start position of event on each iteration
		event_start = item_start_ppq+sum_offset -- calculate event start position based on item start position
		event_type = msg:byte(1)>>4 -- save 1st nibble of status byte (contains info about the data type) to event_type, >>4 shifts the channel nibble into oblivion
		
		if event_type == 9 and msg:byte(3) ~= 0 then -- if note-on and velocity is not 0
			channel = msg:byte(1)&0x0F
			pitch = msg:byte(2)
					
			-- check if current note-on is already tagged = overlapping note-ons!
			if note_on_tagging[channel][flags&2][pitch] then
				reaper.ShowMessageBox("Can't select, because overlapping notes were found", "Error", 0)
				return false

			-- note-on before cursor position? select	
			elseif event_start < cursor_position_ppq then
				flags = flags|1 -- select
				note_on_tagging[channel][flags&2][pitch] = 1 -- tag note-on for selection

			-- note-on after cursor position? unselect 
			elseif event_start >= cursor_position_ppq then 
				flags = flags&~1 -- unselect
				note_on_tagging[channel][flags&2][pitch] = 0 -- tag note-on for non-selection
			end
				
		elseif event_type == 8 or (event_type == 9 and msg:byte(3) == 0) then -- if note-off or velocity 0
			channel = msg:byte(1)&0x0F
			pitch = msg:byte(2)

			-- note-off anywhere and note-on before cursor? select
			if note_on_tagging[channel][flags&2][pitch] == 1 then -- matching note-on tagged for selection?
				flags = flags|1 -- select
				note_on_tagging[channel][flags&2][pitch] = nil -- reset tag

			-- note-off and note-on after cursor? unselect
			elseif note_on_tagging[channel][flags&2][pitch] == 0 then -- matching note-on tagged for non-selection?
				flags = flags&~1 -- unselect
				note_on_tagging[channel][flags&2][pitch] = nil -- reset tag
			end

		-- select all CCs before edit cursor
		elseif #msg == 3 and event_type == 11 then -- if msg consists of 3 bytes (= channel message) and status byte is a CC
			if event_start < cursor_position_ppq then -- events are before cursor position
				flags = flags|1 -- select muted or unmuted event
			else 
				flags = flags&0 -- unselect CC events after cursor
			end
		end
		table.insert(table_events, string.pack("i4Bs4", offset, flags, msg)) -- re-pack MIDI string and write to table
	end

	reaper.MIDI_SetAllEvts(take, table.concat(table_events) .. midi_string:sub(-12))
	reaper.MIDI_Sort(take)
end


-- check, where the user wants to change notes and CCs: MIDI editor, inline editor or arrange view (item)

local take, item, cursor_position_ppq
local window, _, _ = reaper.BR_GetMouseCursorContext() -- initialize cursor context
local _, inline_editor, _, _, _, _ = reaper.BR_GetMouseCursorContext_MIDI() -- check if mouse hovers an inline editor

if window == "midi_editor" then -- MIDI editor focused

	if not inline_editor then -- not hovering inline editor
		take = reaper.MIDIEditor_GetTake(reaper.MIDIEditor_GetActive()) -- get take from active MIDI editor
		item = reaper.GetMediaItemTake_Item(take) -- get item from take
	
	else -- hovering inline editor (will ignore item selection and only change data in the hovered inline editor)
		take = reaper.BR_GetMouseCursorContext_Take() -- get take from mouse
		item = reaper.GetMediaItemTake_Item(take) -- get item from take
	end
	
	cursor_position_ppq = reaper.MIDI_GetPPQPosFromProjTime(take, reaper.GetCursorPosition()) -- get edit cursor position and convert PPQ
	SelectNotesAndCCsBeforeCursor(take, item, cursor_position_ppq) -- select notes and all CCs	

else -- anywhere else (apply to selected items in arrane view)
	
	if reaper.CountSelectedMediaItems(0) ~= 0 then
		for i = 0, reaper.CountSelectedMediaItems(0)-1 do -- loop through all selected items
			item = reaper.GetSelectedMediaItem(0, i) -- get current selected item
			take = reaper.GetActiveTake(item)
			
			if reaper.TakeIsMIDI(take) then
				cursor_position_ppq = reaper.MIDI_GetPPQPosFromProjTime(take, reaper.GetCursorPosition()) -- get edit cursor position and convert PPQ

				if not reaper.BR_IsMidiOpenInInlineEditor(take) then -- is inline editor open?
					reaper.Main_OnCommand(40847, 0) -- open inline editor on selected item(s)
				end

				SelectNotesAndCCsBeforeCursor(take, item, cursor_position_ppq) -- select notes and all CCs
				
			else 
				reaper.ShowMessageBox("The selected item #".. i+1 .." does not contain a MIDI take and won't be altered", "Error", 0)
			end
		end

	else 
		reaper.ShowMessageBox("Please select at least one item", "Error", 0)
		return false
	end
end
reaper.UpdateArrange()
reaper.Undo_OnStateChange2(proj, "Select notes and all CCs before edit cursor (in selected item(s) or MIDI editor)")
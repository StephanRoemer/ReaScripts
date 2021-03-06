-- @noindex

local function ToggleSelectAllCCs(take)

	got_all_ok, midi_string = reaper.MIDI_GetAllEvts(take, "") -- write MIDI events to midi_string, get all events okay
	if not got_all_ok then reaper.ShowMessageBox("Error while loading MIDI", "Error", 0) return(false) end -- if getting the MIDI data failed
	
	midi_len = #midi_string -- get string length
	table_events = {} -- initialize table, MIDI events will temporarily be stored in this table until they are concatenated into a string again
	string_pos = 1 -- position in midi_string while parsing through events 

	while string_pos < midi_len-12 do -- parse through all events in the MIDI string, one-by-one, excluding the final 12 bytes, which provides REAPER's All-notes-off end-of-take message
		offset, flags, msg, string_pos = string.unpack("i4Bs4", midi_string, string_pos) -- unpack MIDI-string on string_pos

		if #msg == 3 -- if msg consists of 3 bytes (= channel message)
		and (msg:byte(1)>>4) == 11 -- if status byte is a CC
		then
			flags = flags == flags|1 and flags&2 or flags|1 -- toggle select muted or unmuted event
		end
		table.insert(table_events, string.pack("i4Bs4", offset, flags, msg)) -- re-pack MIDI string and write to table
	end
	reaper.MIDI_SetAllEvts(take, table.concat(table_events) .. midi_string:sub(-12))
	reaper.MIDI_Sort(take)
end


-- check, where the user wants to change CCs: MIDI editor, inline editor or arrange view (item)

local take, item
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

	ToggleSelectAllCCs(take) -- select all CCs

else -- anywhere else (apply to selected items in arrane view)

	if reaper.CountSelectedMediaItems(0) ~= 0 then
		for i = 0, reaper.CountSelectedMediaItems(0)-1 do -- loop through all selected items
			item = reaper.GetSelectedMediaItem(0, i) -- get current selected item
			take = reaper.GetActiveTake(item)
			
			if reaper.TakeIsMIDI(take) then
				
				if not reaper.BR_IsMidiOpenInInlineEditor(take) then
					reaper.Main_OnCommand(40847, 0) -- open inline editor on selected item
				end
				
				ToggleSelectAllCCs(take) -- execute function
		
			else 
				reaper.ShowMessageBox("The selected item #".. i+1 .." does not contain a MIDI take and won't be altered", "Error", 0)
			end
		end

	else 
		reaper.ShowMessageBox("Please select at least one item", "Error", 0)
		return false
	end
end
reaper.Undo_OnStateChange2(proj, "Toggle select all CCs")
reaper.UpdateArrange()
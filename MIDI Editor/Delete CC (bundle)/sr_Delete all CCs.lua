-- @noindex

local function DeleteAllCCs(take)

	got_all_ok, midi_string = reaper.MIDI_GetAllEvts(take, "") -- write MIDI events to midi_string, get all events okay
	if not got_all_ok then reaper.ShowMessageBox("Error while loading MIDI", "Error", 0) return(false) end -- if getting the MIDI data failed
	
	midi_len = #midi_string -- get string length
	table_events = {} -- initialize table, MIDI events will temporarily be stored in this table until they are concatenated into a string again
	string_pos = 1 -- position in midi_string while parsing through events 

	while string_pos < midi_len-12 do -- parse through all events in the MIDI string, one-by-one, excluding the final 12 bytes, which provides REAPER's All-notes-off end-of-take message
		offset, flags, msg, string_pos = string.unpack("i4Bs4", midi_string, string_pos) -- unpack MIDI-string on string_pos

		if #msg == 3 then -- if msg consists of 3 bytes (= channel message)
			msg_b1_nib1 = msg:byte(1)>>4 -- save 1st nibble of status byte to msg_b1_nib1, >>4 shifts the channel nibble into oblivion

			if msg_b1_nib1 == 11 then -- if status byte is a CC
				msg = "" -- delete event (msg = "")
			end
		end
		table.insert(table_events, string.pack("i4Bs4", offset, flags, msg)) -- re-pack MIDI string and write all other events to table
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
	
	DeleteDestCC(take) -- delete all CCs

else -- anywhere else (apply to selected items in arrane view)
	
	if reaper.CountSelectedMediaItems(0) ~= 0 then
		for i = 0, reaper.CountSelectedMediaItems(0)-1 do -- loop through all selected items
			local item = reaper.GetSelectedMediaItem(0, i) -- get current selected item
			local take = reaper.GetActiveTake(item)

			if reaper.TakeIsMIDI(take) then -- make sure, that take is MIDI

				DeleteDestCC(take) -- delete all CCs
				
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
reaper.Undo_OnStateChange2(proj, "Delete all CCs")



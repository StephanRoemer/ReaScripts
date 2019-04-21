--  @noindex

local function GetNoteBoundaries(take)
	
	if reaper.MIDI_EnumSelNotes(take, -1) ~= -1 then -- check, if there are selected notes
	
		_, note_count, cc_count, _ = reaper.MIDI_CountEvts(take) -- count notes and CCs

		
		-- check for first selected note, count forward

		for n = 0, note_count - 1 do -- loop through all notes
			_, note_selected, _, note_start_pos_ppq, _, _, _, _ = reaper.MIDI_GetNote(take, n) -- get note start position from selected note

			if note_selected then
				break
			end
		end
		
		
		-- check for last selected note, count backwards
		
		for n = note_count, 1, -1 do -- loop through all notes
			_, note_selected, _, _, note_end_pos_ppq, _, _, _ = reaper.MIDI_GetNote(take, n) -- get note end position from selected note
			
			if note_selected then
				break
			end
		end
		
		return note_start_pos_ppq, note_end_pos_ppq
	else
		reaper.ShowMessageBox("Please select at least one note", "Error", 0)
		return false
	end
end


local function SelectCC(take, item, selection_start, selection_end)

	item_start = reaper.GetMediaItemInfo_Value(item, 'D_POSITION')
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

		if #msg == 3 -- if msg consists of 3 bytes (= channel message)
		and (msg:byte(1)>>4) == 11 -- if status byte is a CC
		then	
			if event_start >= selection_start -- and events are after selection_start
			and event_start < selection_end -- but before selection_end
			then
				flags = flags|1 -- select muted and unmuted CC events
			else
				flags = flags&0 -- unselect muted and unmuted CC events
			end
		end
	table.insert(table_events, string.pack("i4Bs4", offset, flags, msg)) -- re-pack MIDI string and write to table
	end

	reaper.MIDI_SetAllEvts(take, table.concat(table_events) .. midi_string:sub(-12))
	reaper.MIDI_Sort(take)
end


-- check, where the user wants to change notes: MIDI editor or inline editor

local take, item, selection_start, selection_end
local window, _, details = reaper.BR_GetMouseCursorContext() -- initialize cursor context
local _, inline_editor, _, _, _, _ = reaper.BR_GetMouseCursorContext_MIDI() -- check if mouse hovers an inline editor

if window == "midi_editor" then -- MIDI editor focused
	
	if not inline_editor then -- not hovering inline editor
		take = reaper.MIDIEditor_GetTake(reaper.MIDIEditor_GetActive()) -- get take from active MIDI editor
	
	else -- hovering inline editor 
		take = reaper.BR_GetMouseCursorContext_Take() -- get take from mouse
	end
	
	selection_start, selection_end = GetNoteBoundaries(take) -- get note selection boundaries

	if selection_start ~= false then -- check if there is a note selection
		item = reaper.GetMediaItemTake_Item(take) -- get item from take
		SelectCC(take, item, selection_start, selection_end) -- select CCs according note selection boundaries
	end
end
reaper.UpdateArrange()
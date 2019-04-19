--  @noindex

function NudgeNotes(new_position)
	
	
	-- nudge notes in MIDI/inline editor (respect event selection)
	
	local function NudgeNotesMIDIEditor(take)

		if reaper.MIDI_EnumSelNotes(take, -1) ~= -1 then notes_selected = true end -- check, if there are selected notes, set notes_selected to true
		
		got_all_ok, midi_string = reaper.MIDI_GetAllEvts(take, "") -- write MIDI events to midi_string, get all events okay
		if not got_all_ok then reaper.ShowMessageBox("Error while loading MIDI", "Error", 0) return(false) end -- if getting the MIDI data failed

		midi_len = #midi_string -- get string length
		table_events = {} -- initialize table, MIDI events will temporarily be stored in this table until they are concatenated into a string again
		string_pos = 1 -- position in midi_string while parsing through events 
		
		while string_pos < midi_len-12 do -- parse through all events in the MIDI string, one-by-one, excluding the final 12 bytes, which provides REAPER's All-notes-off end-of-take message
			offset, flags, msg, string_pos = string.unpack("i4Bs4", midi_string, string_pos) -- unpack MIDI-string on string_pos

			if #msg == 3 
			and ((msg:byte(1)>>4) == 9 or (msg:byte(1)>>4) == 8) -- Is note-on or note-off?
			and (flags&1 == 1 or not notes_selected) -- selected notes always move, unselected only move if no notes are selected
			then
				table.insert(table_events, string.pack("i4Bs4", offset+new_position, flags, msg)) -- move the note on event by new_position
				table.insert(table_events, string.pack("i4Bs4", -new_position, 0, "")) -- put an empty event after the note on event, to maintain the distance
			else
				table.insert(table_events, string.pack("i4Bs4", offset, flags, msg)) -- re-pack MIDI string and write unchanged events
			end
		end
		reaper.MIDI_SetAllEvts(take, table.concat(table_events) .. midi_string:sub(-12))
		reaper.MIDI_Sort(take)
	end


	-- nudge notes in arrange view (ignore event selection)

	local function NudgeNotesArrange(take)

		got_all_ok, midi_string = reaper.MIDI_GetAllEvts(take, "") -- write MIDI events to midi_string, get all events okay
		if not got_all_ok then reaper.ShowMessageBox("Error while loading MIDI", "Error", 0) return(false) end -- if getting the MIDI data failed
		
		midi_len = #midi_string -- get string length
		table_events = {} -- initialize table, MIDI events will temporarily be stored in this table until they are concatenated into a string again
		string_pos = 1 -- position in midi_string while parsing through events 
		sum_offset = 0 -- initialize sum_offset (adds all offsets to get the position of every event in ticks)
		
		while string_pos < midi_len-12 do -- parse through all events in the MIDI string, one-by-one, excluding the final 12 bytes, which provides REAPER's All-notes-off end-of-take message
			offset, flags, msg, string_pos = string.unpack("i4Bs4", midi_string, string_pos) -- unpack MIDI-string on string_pos
			sum_offset = sum_offset+offset -- add all event offsets to get next start position of event on each iteration

			if #msg == 3 
			and ((msg:byte(1)>>4) == 9 or (msg:byte(1)>>4) == 8) -- Is note-on or note-off?
			then
				table.insert(table_events, string.pack("i4Bs4", offset+new_position, flags, msg)) -- move the note on event by new_position
				table.insert(table_events, string.pack("i4Bs4", -new_position, 0, "")) -- put an empty event after the note on event, to maintain the distance
			else
				table.insert(table_events, string.pack("i4Bs4", offset, flags, msg)) -- re-pack MIDI string and write unchanged events
			end
		end
		reaper.MIDI_SetAllEvts(take, table.concat(table_events) .. midi_string:sub(-12))
		reaper.MIDI_Sort(take)
	end

	
	-- extend item, if notes will exceed take boundaries with next nudge

	local function ExtendItem(item, take)
		looped = reaper.GetMediaItemInfo_Value(item, "B_LOOPSRC") -- get loop status for item
		_, num_notes, _, _ = reaper.MIDI_CountEvts(take) -- get number of notes
		_, _, _, first_note_start_pos_ppq, last_note_end_pos_ppq, _, _, _ = reaper.MIDI_GetNote(take, 0) -- get start and end position of first note in take as reference value

		for n = 1, num_notes-1 do -- get closest notes to item boundaries, skip n = 0, because it's already the reference
			_, _, _, cur_note_start_pos_ppq, cur_note_end_pos_ppq, _, _, _ = reaper.MIDI_GetNote(take, n) -- iterate thru note positions
			
			if cur_note_end_pos_ppq > last_note_end_pos_ppq then -- if current note end is closer to item end than previous note end
				last_note_end_pos_ppq = cur_note_end_pos_ppq -- overwrite previous note end with current note end
			
			elseif cur_note_start_pos_ppq < first_note_start_pos_ppq then -- if current note start is closer to item start than previous note start
				first_note_start_pos_ppq = cur_note_start_pos_ppq -- overwrite previous note start with current note start
			end
		end

		item_start_pos = reaper.GetMediaItemInfo_Value(item, "D_POSITION") -- get item position
		item_end_pos = item_start_pos + reaper.GetMediaItemInfo_Value(item, "D_LENGTH") -- calculate item end position
		item_end_pos_ppq = reaper.MIDI_GetPPQPosFromProjTime(take, item_end_pos) -- convert item end position to ppq
		item_start_pos_ppq = reaper.MIDI_GetPPQPosFromProjTime(take, item_start_pos) -- convert item start position to ppq

		if last_note_end_pos_ppq + new_position > item_end_pos_ppq then -- if last note exceeds item, extend item end
			if looped == 0 then -- only extend item, if item is NOT looped
				last_note_end_pos_pt = reaper.MIDI_GetProjTimeFromPPQPos(take, last_note_end_pos_ppq) -- convert closest note end to project time
				next_grid_pos = reaper.BR_GetNextGridDivision(last_note_end_pos_pt) -- get next grid of last note (better than grid of item end, because notes could be covered = all notes off chaos)
				reaper.MIDI_SetItemExtents(item, reaper.TimeMap2_timeToQN(0, item_start_pos), reaper.TimeMap2_timeToQN(0, next_grid_pos)) -- extend item to next grid position
			else
				reaper.ShowMessageBox("Notes cannot be moved beyond item boundaries, because source is looped", "Error", 0)
			end
		elseif first_note_start_pos_ppq + new_position < item_start_pos_ppq then -- if first note exceeds item start, extend item start
			if looped == 0 then -- only extend item, if item is NOT looped
				first_note_start_pt = reaper.MIDI_GetProjTimeFromPPQPos(take, first_note_start_pos_ppq) -- convert closest note start to project time
				prev_grid_pos = reaper.BR_GetPrevGridDivision(first_note_start_pt) -- get previous grid from first note (better than grid of item start, because notes could be covered = all notes off chaos)
				reaper.MIDI_SetItemExtents(item, reaper.TimeMap2_timeToQN(0, prev_grid_pos), reaper.TimeMap2_timeToQN(0, item_end_pos)) -- extend item to previous grid position
			else
				reaper.ShowMessageBox("Notes cannot be moved beyond item boundaries, because source is looped", "Error", 0)
			end
		end
	end


	-- check, where the user wants to change notes: MIDI editor, inline editor or anywhere else

	local take, item, new_position
	local window, _, _ = reaper.BR_GetMouseCursorContext() -- initialize cursor context
	local _, inline_editor, _, _, _, _ = reaper.BR_GetMouseCursorContext_MIDI() -- check if mouse hovers an inline editor

	if window == "midi_editor" then -- MIDI editor focused

		if 	not inline_editor then --  not hovering inline editor
			take = reaper.MIDIEditor_GetTake(reaper.MIDIEditor_GetActive()) -- get take from active MIDI editor
			item = reaper.GetMediaItemTake_Item(take) -- get item from take

		else -- hovering inline editor (will ignore item selection and only change data in the hovered inline editor)
			take = reaper.BR_GetMouseCursorContext_Take() -- get take from mouse
			item = reaper.GetMediaItemTake_Item(take) -- get item from take
		end
		
		ExtendItem(item, take) -- extend item, if notes exceed boundaries
		NudgeNotesMIDIEditor(take) -- nudge notes

	else -- anywhere else (apply to selected items in arrane view)

		if reaper.CountSelectedMediaItems(0) ~= 0 then
			for i = 0, reaper.CountSelectedMediaItems(0)-1 do -- loop through all selected items
				item = reaper.GetSelectedMediaItem(0, i) -- get current selected item
				take = reaper.GetActiveTake(item) -- get take of item

				if reaper.TakeIsMIDI(take) then -- make sure, that take is MIDI
		
					ExtendItem(item, take) -- extend item, if notes exceed boundaries
					NudgeNotesArrange(take) -- nudge notes
		
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
end
--  @noindex

function NudgeNotes(new_position)

	-- ================================================================================================================== --
	--                                                  Helper Functions                                                  --
	-- ================================================================================================================== --


	-- --------------------- Check if item can be modified (= is neither looped, locked or not MIDI) -------------------- --

	local function ModifyItem(item, take)

		-- Get loop status for item
		local looped = reaper.GetMediaItemInfo_Value(item, "B_LOOPSRC")
		local locked = reaper.GetMediaItemInfo_Value(item, "C_LOCK")
		local midi = reaper.TakeIsMIDI(take)

		if looped == 1.0 or locked == 1.0 or midi == false then
			return false
		else
			return true
		end
	end


	-- -------------------------------------------- Correct overlapping notes ------------------------------------------- --

	-- This function only works for notes where the note off overlaps next note on (same pitch)
	-- and not with a note off that crosses another note off (same pitch).

	local function CorrectOverlappingNotes(take)

		local _, notecnt, _, _ = reaper.MIDI_CountEvts(take) 

		for i = notecnt-1, 0, -1 do -- outter note loop

			for j = i-1, 0, -1 do -- inner note loop

				local _, _, _, i_start_pos, _, _, i_pitch, _ = reaper.MIDI_GetNote(take, i) -- get "stationary" note
				local _, _, _, j_start_pos, j_end_pos, _, j_pitch, _ = reaper.MIDI_GetNote(take, j) -- get "moving" note


				-- If notes have the same pitch

				if i_pitch == j_pitch then

					-- If note end of previous note is not overlapping, break loop (go to next note)
					if j_end_pos < i_start_pos then
						break

					-- If start pos of both notes is the same
					elseif i_start_pos == j_start_pos then 
						reaper.MIDI_DeleteNote(take, j) -- delete latter note
						break 

					-- If end pos of previous note exceeds start of next note
					elseif j_end_pos > i_start_pos then 
						reaper.MIDI_SetNote(take, j, nil, nil, nil, i_start_pos, nil, nil, nil, nil) -- shorten overlapping note
						break 
					end
				end
			end
		end
	end



	-- --------------------------------- Check for selected notes in multiple items ------------------------------- --

	-- This function is needed in order to decide if selected or all notes of multiple items should be affected. 

	local function CheckItemsForSelectedNotes(item_cnt)

		local sel_item_cnt = 0

		for i = 0, item_cnt - 1 do -- loop through all selected items
			local item = reaper.GetSelectedMediaItem(0, i) -- get current selected item
			local take = reaper.GetActiveTake(item)

			if reaper.MIDI_EnumSelNotes(take, -1) ~= -1 then
				sel_item_cnt = sel_item_cnt + 1
			end
		end
		return sel_item_cnt
	end



	-- ------------------------ Get note boundaries: considers all or selected notes -------------------------- --
	
	local function GetNoteBoundaries(take, notes_selected)
		local note_start, note_end, cur_note_end, selected, _
		local _, num_notes, _, _ = reaper.MIDI_CountEvts(take) -- get number of notes
		
		if new_position < 0 then -- if notes move left, get left boundary (leftmost note start)

			-- Find first note
			if notes_selected == -1 then 
				_, _, _, note_start, _, _, _, _ = reaper.MIDI_GetNote(take, 0) 

			-- Find first selected note
			else
				for n = 0, num_notes-1 do
					_, selected, _, note_start, _, _, _, _ = reaper.MIDI_GetNote(take, n)
					if selected then -- first selected note found
						break
					end
				end
			end
			return note_start 

		else -- If notes move right, get right boundary (rightmost note end)
			-- note: the right boundary is not necessarily the last note, the first note could be as long as the whole item

			_, _, _, _, note_end, _, _, _ = reaper.MIDI_GetNote(take, 0) -- get start value for comparison 

			-- Find note that is closest to the item end
			if notes_selected == -1 then
				for n = 0, num_notes-1 do
					_, _, _, _, cur_note_end, _, _, _ = reaper.MIDI_GetNote(take, n) -- iterate thru note ends
					if cur_note_end > note_end then -- if current note end is closer to item end than previous note end
						note_end = cur_note_end -- overwrite previous note end with current note end
					end
				end

			-- Find selected note that is closest to the item end
			else  
				for n = 0, num_notes-1 do
					_, selected, _, _, cur_note_end, _, _, _ = reaper.MIDI_GetNote(take, n) -- iterate thru note ends
					
					if selected == true then
						if cur_note_end > note_end then -- if current selected note end is closer to item end than previous note end
							note_end = cur_note_end -- overwrite previous note end with current note end
						end		
					end
				end
			end
			return note_end
		end		
	end

	
	-- --------------------------------------------------- Extend item -------------------------------------------------- --

	-- Extend item, if (all or selected!) notes will exceed take boundaries with next nudge

	local function ExtendItem(item, take, notes_selected)

		-- Get note boundary, in order to check if an item extension is necessary on next note nudge
		local note_boundary = GetNoteBoundaries(take, notes_selected)

		-- Get item boundaries in ppq
		local item_start = reaper.GetMediaItemInfo_Value(item, "D_POSITION") -- get item position
		local item_end = item_start + reaper.GetMediaItemInfo_Value(item, "D_LENGTH") -- calculate item end position
		local item_end_ppq = reaper.MIDI_GetPPQPosFromProjTime(take, item_end) -- convert item end position to ppq
		local item_start_ppq = reaper.MIDI_GetPPQPosFromProjTime(take, item_start) -- convert item start position to ppq

		if new_position < 0 then -- Notes move left
			if note_boundary + new_position < item_start_ppq then -- if first note exceeds item start, extend item start

				local first_note_start_pt = reaper.MIDI_GetProjTimeFromPPQPos(take, note_boundary) -- convert closest note start to project time
				local prev_grid_pos = reaper.BR_GetPrevGridDivision(first_note_start_pt) -- get previous grid from first note (better than grid of item start, because notes could be covered = all notes off chaos)
				reaper.MIDI_SetItemExtents(item, reaper.TimeMap2_timeToQN(0, prev_grid_pos), reaper.TimeMap2_timeToQN(0, item_end)) -- extend item to previous grid position
			end

		else -- Notes move right
			if note_boundary + new_position > item_end_ppq then -- if note  that is closest to item end exceeds item, extend item end

				local last_note_end_pt = reaper.MIDI_GetProjTimeFromPPQPos(take, note_boundary) -- convert closest note end to project time
				local next_grid_pos = reaper.BR_GetNextGridDivision(last_note_end_pt)  -- get next grid of last note (better than grid of item end, because notes could be covered = all notes off chaos)
				reaper.MIDI_SetItemExtents(item, reaper.TimeMap2_timeToQN(0, item_start), reaper.TimeMap2_timeToQN(0, next_grid_pos)) -- extend item to next grid position
			end
		end
	end


	-- ================================================================================================================== --
	--                                                Nudge Notes Functions                                               --
	-- ================================================================================================================== --

	local function NudgeNotes(take, notes_selected)
		local got_all_ok, midi_string = reaper.MIDI_GetAllEvts(take, "") -- write MIDI events to midi_string, get all events okay
		if not got_all_ok then reaper.ShowMessageBox("Error while loading MIDI", "Error", 0) return(false) end -- if getting the MIDI data failed
		
		local table_events = {} -- initialize table, MIDI events will temporarily be stored in this table until they are concatenated into a string again
		local midi_len = #midi_string -- get string length
		local string_pos = 1 -- position in midi_string while parsing through events 
		local offset, flags, msg
		

		-- No selection: only move notes
		if notes_selected == -1 then 

			while string_pos < midi_len-12 do -- parse through all events in the MIDI string, one-by-one, excluding the final 12 bytes, which provides REAPER's All-notes-off end-of-take message
				offset, flags, msg, string_pos = string.unpack("i4Bs4", midi_string, string_pos) -- unpack MIDI-string on string_pos
				local status_byte = msg:byte(1)>>4 -- writing to a variable speeds up the comparison in the next if statement

				if #msg == 3
				and (status_byte == 9 or status_byte == 8) -- note-on or note-off?
				then
					table.insert(table_events, string.pack("i4Bs4", offset+new_position, flags, msg)) -- move the note on event by new_position
					table.insert(table_events, string.pack("i4Bs4", -new_position, 0, "")) -- put an empty event after the note on event, to maintain the distance
				else
					table.insert(table_events, string.pack("i4Bs4", offset, flags, msg)) -- re-pack MIDI string and write unchanged events
				end
			end
			reaper.MIDI_SetAllEvts(take, table.concat(table_events) .. midi_string:sub(-12))
			reaper.MIDI_Sort(take)
		

		-- Note selection: move notes and other MIDI events, if selected
		else
			while string_pos < midi_len-12 do -- parse through all events in the MIDI string, one-by-one, excluding the final 12 bytes, which provides REAPER's All-notes-off end-of-take message
				
				offset, flags, msg, string_pos = string.unpack("i4Bs4", midi_string, string_pos) -- unpack MIDI-string on string_pos
				local status_byte = msg:byte(1)>>4 -- writing to a variable speeds up the comparison in the next if statement

				if flags&1 == 1 then -- consider all selected events 
					table.insert(table_events, string.pack("i4Bs4", offset+new_position, flags, msg)) -- move all selected events by new_position
					table.insert(table_events, string.pack("i4Bs4", -new_position, 0, "")) -- put an empty event, to maintain the distance
				else
					table.insert(table_events, string.pack("i4Bs4", offset, flags, msg)) -- re-pack MIDI string and write unchanged events
				end
			end
			reaper.MIDI_SetAllEvts(take, table.concat(table_events) .. midi_string:sub(-12))
			CorrectOverlappingNotes(take) -- fixing overlapping notes only makes sense when moving selected notes
			reaper.MIDI_Sort(take)
		end
	end


-- ================================================================================================================== --
--                                                        Main                                                        --
-- ================================================================================================================== --

	local function Main()

		local take, item, selnotes_items, item_cnt, new_position, notes_selected
		local window, _, _ = reaper.BR_GetMouseCursorContext() -- initialize cursor context
		local _, inline_editor, _, _, _, _ = reaper.BR_GetMouseCursorContext_MIDI() -- check if mouse hovers an inline editor

		item_cnt = reaper.CountSelectedMediaItems(0)
		
		-- ----------------------------------------------- MIDI editor focused ---------------------------------------------- --
			
		if window == "midi_editor" then 

			if not inline_editor then -- MIDI editor focused				

				-- 1 Item selected

				if item_cnt == 1 then
					item = reaper.GetSelectedMediaItem(0, 0)
					take = reaper.GetActiveTake(item) -- get take from selected item
					notes_selected = reaper.MIDI_EnumSelNotes(take, -1)

					if ModifyItem(item, take) then -- check if item is neither looped, locked or no MIDI
						ExtendItem(item, take, notes_selected)
						NudgeNotes(take, notes_selected)
					end


				-- Multiple items selected

				elseif item_cnt >= 1 then

					selnotes_items = CheckItemsForSelectedNotes(item_cnt) -- how many items have selected notes?

					for i = 0, item_cnt - 1 do -- loop through all selected items
						item = reaper.GetSelectedMediaItem(0, i)
						take = reaper.GetActiveTake(item)
						notes_selected = reaper.MIDI_EnumSelNotes(take, -1) 

						-- Nudge notes in either all items (no selected notes) or only items with selected notes 
						if selnotes_items == 0 or notes_selected ~= -1 then
							if ModifyItem(item, take) then
								ExtendItem(item, take, notes_selected)
								NudgeNotes(take, notes_selected)
							end
						end
					end
				end


			-- ---------------------------------------------- Inline Editor focused --------------------------------------------- --

			else

				take = reaper.BR_GetMouseCursorContext_Take() -- get take from mouse
				item = reaper.GetMediaItemTake_Item(take) -- get item from take
				notes_selected = reaper.MIDI_EnumSelNotes(take, -1)

				if ModifyItem(item, take) then -- check if item is neither looped, locked or not MIDI
					ExtendItem(item, take, notes_selected)
					NudgeNotes(take, notes_selected)
				end
			end

		-- -------------------------------------------- Item Selection ------------------------------------------------------ --

		else 

			if item_cnt then
				for i = 0, item_cnt-1 do -- loop through all selected items
					item = reaper.GetSelectedMediaItem(0, i) -- get current selected item
					take = reaper.GetActiveTake(item) -- get take of item

					-- Ignore note selection by using "-1"	
					if ModifyItem(item, take) then
						ExtendItem(item, take, -1) -- extend item, if notes exceed boundaries
						NudgeNotes(take, -1) -- nudge notes
					end
				end
			else
				reaper.ShowMessageBox("Please select at least one item", "Error", 0)
				return false
			end
		end
		reaper.UpdateArrange()
	end

	Main()
end

--  @noindex

function ChangeNoteLength(new_length)
	
-- ================================================================================================================== --
--                                                  Helper Functions                                                  --
-- ================================================================================================================== --


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



-- --------------------------------------- Check for existing razor selection --------------------------------------- --

local function CheckForRazorSelection()

	for t = 0, reaper.CountTracks(0)-1 do
		local track = reaper.GetTrack(0, t)
		local razor_ok, razor_str = reaper.GetSetMediaTrackInfo_String(track, "P_RAZOREDITS", "", false)
		if #razor_str ~= 0 then
			return true
		end
	end
end



-- --------------------------- Store all items that cross the razor selections in a table --------------------------- --

local function GetRazorEditItems()
	
	local items_table = {}


	-- go thru all tracks and save razor edits into a table

	for t = 0, reaper.CountTracks(0)-1 do
		local track = reaper.GetTrack(0, t)
		local razor_ok, razor_str = reaper.GetSetMediaTrackInfo_String(track, "P_RAZOREDITS", "", false)
		if razor_ok and #razor_str ~= 0 then
			-- parse string for razor edits
			for razor_left, razor_right, env_guid in razor_str:gmatch([[([%d%.]+) ([%d%.]+) "([^"]*)"]]) do
				if env_guid == "" then -- ignore envelope razor selection
					local razor_left, razor_right = tonumber(razor_left), tonumber(razor_right)
					
					-- go thru all items on current track and check if they overlap with razor boundaries

					for i = 0, reaper.CountTrackMediaItems(track)-1 do
						local item = reaper.GetTrackMediaItem(track, i)
						local item_start = reaper.GetMediaItemInfo_Value(item, "D_POSITION")
						local item_end = item_start + reaper.GetMediaItemInfo_Value(item, "D_LENGTH")
						if item_start < razor_right 
						and item_end > razor_left then
							table.insert(items_table, {item = item, razor_left = razor_left, razor_right =  razor_right})
						end
					end
				end
			end
		end
	end
	return items_table
end



-- -------------------------------------------- Correct overlapping notes ------------------------------------------- --
		
-- This function only works for notes where the note off overlaps next note on (same pitch)
-- and not with a note off that crosses another note off (same pitch).
-- It is only needed for the arrange, because in the MIDI editor there is a dedicated action

local function CorrectOverlappingNotes(take, notecnt)
	
	for i = notecnt-1, 0, -1 do -- outter note loop
		
		for j = i-1, 0, -1 do -- inner note loop
		
			local _, _, _, i_start_pos, _, _, i_pitch, _ = reaper.MIDI_GetNote(take, i) -- get "stationary" note
			local _, _, _, j_start_pos, j_end_pos, _, j_pitch, _ = reaper.MIDI_GetNote(take, j) -- get "moving" note


			-- if notes have the same pitch
			
			if i_pitch == j_pitch then
			
				-- if note end of previous note is not overlapping, break loop (go to next note)
				if j_end_pos < i_start_pos then
					break
				
					-- if start pos of both notes is the same
				elseif i_start_pos == j_start_pos then 
					reaper.MIDI_DeleteNote(take, j) -- delete latter note
					break -- 
					
					-- if end pos of previous note exceeds start of next note
				elseif j_end_pos > i_start_pos then 
					reaper.MIDI_SetNote(take, j, nil, nil, nil, i_start_pos, nil, nil, nil, nil) -- shorten overlapping note
					break 
				end
			end
		end
	end
end



-- ================================================================================================================== --
--                                            Change Note Length Functions                                            --
-- ================================================================================================================== --
	

-- ------------------------------------ Change note length in MIDI/inline editor ------------------------------------ --
	
	local function ChangeNoteLengthMIDIEditor(take)

		if reaper.TakeIsMIDI(take) then -- make sure, that take is MIDI
			local notes_selected

			local _, notecnt, _, _ = reaper.MIDI_CountEvts(take) -- count notes and save amount to notecnt
			
			if reaper.MIDI_EnumSelNotes(take, -1) ~= -1 then notes_selected = true end -- check, if there are selected notes, set notes_selected to true

			reaper.MIDI_DisableSort(take)

			for n = 0, notecnt do
				local _, selected, _, _, note_end, _, _, _ = reaper.MIDI_GetNote(take, n)

				if (selected or not notes_selected) then -- selected notes always change, unselected only change if no notes are selected
					reaper.MIDI_SetNote(take, n, nil, nil, nil, note_end+new_length, nil, nil, nil, nil)
				end
			end

			CorrectOverlappingNotes(take, notecnt)
			reaper.MIDI_Sort(take)
			reaper.MIDIEditor_OnCommand(midi_editor, 40659) -- correct overlapping notes
		end
	end


-- --------------------------- Change note length in selected item(s) in the arrange view --------------------------- --

	local function ChangeNoteLengthArrange(take)

		if reaper.TakeIsMIDI(take) then -- make sure, that take is MIDI
			local _, notecnt, _, _ = reaper.MIDI_CountEvts(take) -- count notes and save amount to notecnt

			reaper.MIDI_DisableSort(take)

			for n = 0, notecnt do
				local _, _, _, _, note_end, _, _, _ = reaper.MIDI_GetNote(take, n)
				reaper.MIDI_SetNote(take, n, nil, nil, nil, note_end+new_length, nil, nil, nil, nil)
			end

			CorrectOverlappingNotes(take, notecnt) -- correct overlapping notes
			reaper.MIDI_Sort(take)
		end
	end



-- ------------------------------------ Change note length within razor selection ----------------------------------- --

	local function ChangeNoteLengthSelection(items_table)

		if reaper.TakeIsMIDI(take) then -- make sure, that take is MIDI
			for index, value in pairs(items_table) do
				local item, razor_left, razor_right = value.item, value.razor_left, value.razor_right -- get razor item values from table
				
				local take = reaper.GetActiveTake(item)
				
				if reaper.TakeIsMIDI(take) then -- make sure, that take is MIDI
					local razor_left_ppq = reaper.MIDI_GetPPQPosFromProjTime(take, razor_left) -- convert left razor to PPQ
					local razor_right_ppq = reaper.MIDI_GetPPQPosFromProjTime(take, razor_right) -- convert left razor to PPQ

					local _, notecnt, _, _ = reaper.MIDI_CountEvts(take) -- count notes and save amount to notecnt

					reaper.MIDI_DisableSort(take) -- disabling sorting improves execution speed

					for n = 0, notecnt do
						local _, _, _, note_start_ppq, note_end_ppq, _, _, _ = reaper.MIDI_GetNote(take, n)
						
						if note_start_ppq >= razor_left_ppq 
						and note_start_ppq < razor_right_ppq then
							reaper.MIDI_SetNote(take, n, nil, nil, nil, note_end_ppq+new_length, nil, nil, nil, nil)
						end
					end
					CorrectOverlappingNotes(take, notecnt)
					reaper.MIDI_Sort(take)
				end
			end
		end
	end


-- ================================================================================================================== --
--                                                        Main                                                        --
-- ================================================================================================================== --

	local function Main()

		reaper.PreventUIRefresh(1)

		local take, item, item_cnt, selnotes_items
		local window, _, _ = reaper.BR_GetMouseCursorContext() -- initialize cursor context
		local _, inline_editor, _, _, _, _ = reaper.BR_GetMouseCursorContext_MIDI() -- check if mouse hovers an inline editor
		
		item_cnt = reaper.CountSelectedMediaItems(0)

		-- ----------------------------------------------- MIDI editor focused ---------------------------------------------- --

		if window == "midi_editor" then -- MIDI editor focused

			if not inline_editor then

				-- 1 Item selected

				if item_cnt == 1 then
					take = reaper.GetActiveTake(reaper.GetSelectedMediaItem(0, 0)) -- get take from selected item
					ChangeNoteLengthMIDIEditor(take) -- change note length
	

				-- Multiple items selected

				elseif item_cnt >= 1 then

					selnotes_items = CheckItemsForSelectedNotes(item_cnt)

					for i = 0, item_cnt - 1 do -- loop through all selected items
						take = reaper.GetActiveTake(reaper.GetSelectedMediaItem(0, i))

						-- Change note lengths in either all items (no selected notes) or only items with selected notes 
						if selnotes_items == 0 or reaper.MIDI_EnumSelNotes(take, -1) ~= -1 then
							ChangeNoteLengthMIDIEditor(take) -- change note length
						end
					end
				end

			-- ---------------------------------------------- Inline Editor focused --------------------------------------------- --
				
			else
				take = reaper.BR_GetMouseCursorContext_Take() -- get take from mouse
				ChangeNoteLengthMIDIEditor(take) -- add notes interval
			end
			
			
			
			
	-- -------------------------------------------- No MIDI editor is focused ------------------------------------------- --

	else	

			-- --------------------------------------------- Razor selection exists --------------------------------------------- --

			if CheckForRazorSelection() then
				local items_table = GetRazorEditItems()
				ChangeNoteLengthSelection(items_table)


			
			-- ---------------------------------- Item selection and NO razor selection exists ---------------------------------- --
			
			else
				if item_cnt ~= 0 then
					for i = 0, item_cnt - 1 do -- loop through all selected items
						take = reaper.GetActiveTake(reaper.GetSelectedMediaItem(0, i)) -- get take of selected item
						ChangeNoteLengthArrange(take) -- add notes interval
					end
				else
					reaper.ShowMessageBox("Please select at least one item or create a razor selection", "Error", 0)
					return false
				end
			end
			reaper.PreventUIRefresh(-1)
			reaper.UpdateArrange()
		end
	end

	Main()
end

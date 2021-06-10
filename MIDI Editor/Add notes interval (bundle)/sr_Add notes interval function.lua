--  @noindex

function AddNotesInterval(interval)
	
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



-- ================================================================================================================== --
--                                            Add Notes Interval Functions                                            --
-- ================================================================================================================== --


-- ------------------------ Add notes interval in MIDI/inline editor (respect note selection) ----------------------- --

	local function AddNotesIntervalMIDIEditor(take)

		if reaper.TakeIsMIDI(take) then -- make sure, that take is MIDI

			local notes_selected
			local _, notecnt, _, _ = reaper.MIDI_CountEvts(take)
			local notes_tbl = {}
			local notes_tbl_idx = {}

			if reaper.MIDI_EnumSelNotes(take, -1) ~= -1 then notes_selected = true end -- check, if there are selected notes, set notes_selected to true


			-- Store all notes into table (assign destination pitch AND original pitch)
			for n = 0, notecnt-1 do

				local _, selected, muted, note_start, note_end, chan, pitch, vel = reaper.MIDI_GetNote(take, n)

				notes_tbl[n+1] = {
					selected = selected,
					muted = muted,
					note_start = note_start,
					note_end = note_end,
					chan = chan,
					pitch_orig = pitch,
					pitch = pitch+interval, -- destination pitch!
					vel = vel
				}

				-- While iterating, also write unique note identifier (idx) to notes_tbl_idx.
				-- The variable idx concatenates all needed variables into one in order to compare it in the loop below.
				-- This procedure enables us to find a note (table element) by directly pointing at the idx
				-- instead of using an inner loop to iterate thru the notes.

				local idx = note_start..chan..pitch
				notes_tbl_idx[idx] = n+1
			end


			-- Insert notes from table

			reaper.MIDI_DisableSort(take)

			-- Iterate thru all notes and insert new note only if note with same parameters doesn't exist = duplicate notes check
			for n = 1, notecnt do

				local note = notes_tbl[n] -- assign table element to variable for readabilty
				local selected, muted, note_start, note_end, chan, pitch, vel = note.selected, note.muted, note.note_start, note.note_end, note.chan, note.pitch_orig, note.vel

				-- This is where the magic happens (thanks LBX for this ingenious piece of code).
				-- A pointer with the attributes of the current note is created.
				-- By using it as an index with the notes_tbl, we can check if the destination note
				-- already exists.

				local idx = note_start..chan..note.pitch
				if not notes_tbl_idx[idx] then

					if (note.selected or not notes_selected) -- either affect selected or ALL notes
					and note.pitch > 1 and note.pitch < 127 then -- make sure pitch is between 1 and 127, otherwise don't insert
						reaper.MIDI_InsertNote(take, false, note.muted, note.note_start, note.note_end, note.chan, note.pitch, note.vel, false)
					end
				end
			end
			reaper.MIDI_Sort(take)
		end
	end


-- --------------------------- Add notes interval in arrange view (ignore note selection) --------------------------- --

	local function AddNotesIntervalArrange(take)

		if reaper.TakeIsMIDI(take) then -- make sure, that take is MIDI
			local _, notecnt, _, _ = reaper.MIDI_CountEvts(take)
			local notes_tbl = {}
			local notes_tbl_idx = {}

			-- Store all notes into table (assign destination pitch AND original pitch)
			for n = 0, notecnt-1 do

				local _, selected, muted, note_start, note_end, chan, pitch, vel = reaper.MIDI_GetNote(take, n)

				notes_tbl[n+1] = {
					selected = selected,
					muted = muted,
					note_start = note_start,
					note_end = note_end,
					chan = chan,
					pitch_orig = pitch,
					pitch = pitch+interval, -- destination pitch!
					vel = vel
				}

				-- While iterating, also write unique note identifier (idx) to notes_tbl_idx.
				-- The variable idx concatenates all needed variables into one in order to compare it in the loop below.
				-- This procedure enables us to find a note (table element) by directly pointing at the idx
				-- instead of using an inner loop to iterate thru the notes.

				local idx = note_start..chan..pitch
				notes_tbl_idx[idx] = n+1
			end


			-- Insert notes from table

			reaper.MIDI_DisableSort(take)

			-- Iterate thru all notes and insert new note only if note with same parameters doesn't exist = duplicate notes check
			for n = 1, notecnt do

				local note = notes_tbl[n] -- assign table element to variable for readabilty
				local selected, muted, note_start, note_end, chan, pitch, vel = note.selected, note.muted, note.note_start, note.note_end, note.chan, note.pitch_orig, note.vel

				-- This is where the magic happens (thanks LBX for this ingenious piece of code).
				-- A pointer with the attributes of the current note is created.
				-- By using it as an index with the notes_tbl, we can check if the destination note
				-- already exists.

				local idx = note_start..chan..note.pitch
				if not notes_tbl_idx[idx] then

					if note.pitch > 1 and note.pitch < 127 then -- make sure pitch is between 1 and 127, otherwise don't insert
						reaper.MIDI_InsertNote(take, note.selected, note.muted, note.note_start, note.note_end, note.chan, note.pitch, note.vel, false)
					end
				end
			end
			reaper.MIDI_Sort(take)
		end
	end

	-- Add note intervals within razor selections in arrange view (ignore note selection)

	local function AddNotesIntervalRazorSelection(items_table)

		if reaper.TakeIsMIDI(take) then -- make sure, that take is MIDI

			for index, value in pairs(items_table) do
				local item, razor_left, razor_right = value.item, value.razor_left, value.razor_right -- get razor item values from table

				local take = reaper.GetActiveTake(item)

				if reaper.TakeIsMIDI(take) then -- make sure, that take is MIDI

					local razor_left_ppq = reaper.MIDI_GetPPQPosFromProjTime(take, razor_left) -- convert left razor to PPQ
					local razor_right_ppq = reaper.MIDI_GetPPQPosFromProjTime(take, razor_right) -- convert left razor to PPQ
					local _, notecnt, _, _ = reaper.MIDI_CountEvts(take)
					local notes_tbl = {}
					local notes_tbl_idx = {}
					local notes_counter = 0 -- because n will not be equal to the notes within the razor selection, we need another counter

					-- Store all notes into table (assign destination pitch AND original pitch)
					for n = 0, notecnt-1 do

						local _, selected, muted, note_start, note_end, chan, pitch, vel = reaper.MIDI_GetNote(take, n)

						-- Only store notes that lie in between razor selection
						if note_start >= razor_left_ppq and note_start < razor_right_ppq then

							-- Move to next table element before writing data (will also reflect the table length)
							notes_counter = notes_counter + 1

							notes_tbl[notes_counter] = {
								selected = selected,
								muted = muted,
								note_start = note_start,
								note_end = note_end,
								chan = chan,
								pitch_orig = pitch,
								pitch = pitch+interval, -- destination pitch!
								vel = vel
							}

							-- While iterating, also write unique note identifier (idx) to notes_tbl_idx.
							-- The variable idx concatenates all needed variables into one in order to compare it in the loop below.
							-- This procedure enables us to find a note (table element) by directly pointing at the idx
							-- instead of using an inner loop to iterate thru the notes.

							local idx = note_start..chan..pitch
							notes_tbl_idx[idx] = notes_counter
						end
					end

					-- Insert notes from table

					reaper.MIDI_DisableSort(take)

					-- Iterate thru all notes and insert new note only if note with same parameters doesn't exist = duplicate notes check
					for n = 1, notes_counter do

						local note = notes_tbl[n] -- assign table element to variable for readabilty
						local selected, muted, note_start, note_end, chan, pitch, vel = note.selected, note.muted, note.note_start, note.note_end, note.chan, note.pitch_orig, note.vel

						-- This is where the magic happens (thanks LBX for this ingenious piece of code).
						-- A pointer with the attributes of the current note is created.
						-- By using it as an index with the notes_tbl, we can check if the destination note
						-- already exists.

						local idx = note_start..chan..note.pitch

						if not notes_tbl_idx[idx] then

							if note.pitch > 1 and note.pitch < 127 then -- make sure pitch is between 1 and 127, otherwise don't insert
								reaper.MIDI_InsertNote(take, note.selected, note.muted, note.note_start, note.note_end, note.chan, note.pitch, note.vel, false)
							end
						end

					end
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

			if not inline_editor then -- MIDI editor focused
			
				-- 1 Item selected

				if item_cnt == 1 then
					take = reaper.GetActiveTake(reaper.GetSelectedMediaItem(0, 0)) -- get take from selected item
					AddNotesIntervalMIDIEditor(take) -- add notes interval
	

				-- Multiple items selected

				elseif item_cnt >= 1 then

					selnotes_items = CheckItemsForSelectedNotes(item_cnt)

					for i = 0, item_cnt - 1 do -- loop through all selected items
						take = reaper.GetActiveTake(reaper.GetSelectedMediaItem(0, i))

						-- Add notes interval to either all items (no selected notes) or only items with selected notes 
						if selnotes_items == 0 or reaper.MIDI_EnumSelNotes(take, -1) ~= -1 then
							AddNotesIntervalMIDIEditor(take) -- add notes interval
						end
					end
				end


			-- ---------------------------------------------- Inline Editor focused --------------------------------------------- --

			else
				take = reaper.BR_GetMouseCursorContext_Take() -- get take from mouse
				AddNotesIntervalMIDIEditor(take) -- add notes interval
			end



		-- -------------------------------------------- No MIDI editor is focused ------------------------------------------- --

		else 

			-- --------------------------------------------- Razor selection exists --------------------------------------------- --

			if CheckForRazorSelection() then
				local items_table = GetRazorEditItems()
				AddNotesIntervalRazorSelection(items_table)



			-- ---------------------------------- Item selection and NO razor selection exists ---------------------------------- --

			else
				if item_cnt ~= 0 then
					for i = 0, item_cnt - 1 do -- loop through all selected items
						take = reaper.GetActiveTake(reaper.GetSelectedMediaItem(0, i)) -- get take of selected item
						AddNotesIntervalArrange(take) -- add notes interval
					end
				else
					reaper.ShowMessageBox("Please select at least one item or create a razor selection", "Error", 0)
					return false
				end
			end
		end
		reaper.PreventUIRefresh(-1)
		reaper.UpdateArrange()
	end

	Main()
end

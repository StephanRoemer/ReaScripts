--  @noindex

function Quantize(grid, swing, swing_amt, strength)
	
-- ================================================================================================================== --
--                                                  Helper Functions                                                  --
-- ================================================================================================================== --



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


-- --------------------- Set / backup grid settings (necessary for SnapToGrid() to work) --------------------- --

	local function SetGridAndBackup()
		local grid_linked, grid_minimum, grid_min_changed

		
		-- backup arrange grid settings
		local _, arr_grid, arr_swing, arr_swing_amt = reaper.GetSetProjectGrid(proj, false) 
		
		-- set new grid settings, provided by aux script
		reaper.GetSetProjectGrid(proj, true, grid, swing, swing_amt) 
		
		-- if snap doesn't follow grid visiblity, enable it
		if reaper.GetToggleCommandState(reaper.NamedCommandLookup("_BR_OPTIONS_SNAP_FOLLOW_GRID_VIS")) == 0 then
			reaper.Main_OnCommand(reaper.NamedCommandLookup("_BR_OPTIONS_SNAP_FOLLOW_GRID_VIS"))
			grid_linked = true
		end


		-- get grid minimum, if value is higher than 0, then project zoom will define the visible grid
		grid_minimum = reaper.SNM_GetIntConfigVar('projgridmin', 0) 
		if grid_minimum > 0 then 
			reaper.SNM_SetIntConfigVar('projgridmin', 0) -- set minimum to 0 so that the project zoom doesn't affect SnapToGrid()
			grid_min_changed = true
		end
		
		return arr_grid, arr_swing, arr_swing_amt, grid_linked, grid_minimum, grid_min_changed
	end


-- -------------------------------------- Restore altered arange grid settings -------------------------------------- --

	local function GridRestore(arr_grid, arr_swing, arr_swing_amt, grid_linked, grid_minimum, grid_min_changed)
		
		if grid_min_changed == true then
			reaper.SNM_SetIntConfigVar('projgridmin', grid_minimum)
		end
		
		-- toggle off "snap follows grid visiblity"
		if grid_linked == true then
			reaper.Main_OnCommand(reaper.NamedCommandLookup("_BR_OPTIONS_SNAP_FOLLOW_GRID_VIS"))
		end
		
		-- restore saved arrange grid settings
		reaper.GetSetProjectGrid(proj, true, arr_grid, arr_swing, arr_swing_amt) 
	end


-- ------------------------------- Backup MIDI Editor grid and then sync with arrange ------------------------------- --

-- In order to apply swing to the MIDI Editor, it is necessary to temporarily sync the ME grid with the arrange, because there is no
-- API to set the swing amount. 

-- This function won't apply to the Inline Editor, because retrieving the toggle state will return -1, which is good,
-- since the Inline Editor uses the arrange grid.
-- MIDIGridRestore() won't be called either from QuantizeMIDIEditor(), because grid_sync is a condition and will be nil.
-- Also, if the user has enabled grid sync, it won't be changed.

	local function MIDIGridBackup(take, midi_editor)
		
		local midi_swing, grid_sync
		
		-- if MIDI Editor and arrange grid aren't synced, temporarily sync it
		if reaper.GetToggleCommandStateEx(32060, 41022) == 0 then
			
			--  backup MIDI grid setting
			local midi_grid, midi_swing_amt, _ = reaper.MIDI_GetGrid(take)
			
			-- MIDI_GetGrid() has no setting for swing on/off, instead: if swing amount is bigger than 0, then swing is turned on
			if midi_swing_amt > 0 then midi_swing = 1 else midi_swing = 0 end
		
			reaper.MIDIEditor_OnCommand(midi_editor, 41022) -- toggle on: use same grid settings for MIDI Editor and arrange
			
			grid_sync = true -- indicate that grid sync was necessary, in order to restore it later
			
			return grid_sync, midi_grid/4, midi_swing, midi_swing_amt
		end 
	end


-- -------------------------------- Restore MIDI Editor grid and unsync from arrange -------------------------------- --

	local function MIDIGridRestore(midi_editor, midi_grid, midi_swing, midi_swing_amt)
		
		-- restore MIDI Editor grid setting
		reaper.GetSetProjectGrid(proj, true, midi_grid, midi_swing, midi_swing_amt)
		
		-- then, turn off use same grid settings for MIDI Editor and arrange
		reaper.MIDIEditor_OnCommand(midi_editor, 41022) 

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
--                                                 Quantize Functions                                                 --
-- ================================================================================================================== --



-- -------------------------- Quantize take in MIDI/inline editor (respect note selection) -------------------------- --

	local function QuantizeMIDIEditor(take, midi_editor)
			
		
		-- --------------------------------------------------- Grid Backup -------------------------------------------------- --

		-- backup MIDI Editor grid settings, will be restored at the end of this function BEFORE grid sync is disabled again
		local grid_sync, midi_grid, midi_swing, midi_swing_amt = MIDIGridBackup(take, midi_editor)
		
		-- set grid, after grid sync has been enabled, also backup previous arrange grid setting
		local arr_grid, arr_swing, arr_swing_amt, grid_linked, grid_minimum, grid_min_changed = SetGridAndBackup()
		

		
		-- ---------------------------------------------------- Quantize ---------------------------------------------------- --

		local notes_selected
		
		local _, notecnt, _, _ = reaper.MIDI_CountEvts(take) -- count notes and save amount to notecnt
		
		if reaper.MIDI_EnumSelNotes(take, -1) ~= -1 then notes_selected = true end -- check, if there are selected notes, set notes_selected to true
		
		reaper.MIDI_DisableSort(take) -- disabling sorting improves execution speed
		
		for n = 0, notecnt - 1 do -- loop through all notes
			local _, selected, _, note_start_ppq, note_end_ppq, _, _, _ = reaper.MIDI_GetNote(take, n) -- get selection status and positions
		
			local note_start = reaper.MIDI_GetProjTimeFromPPQPos(take, note_start_ppq) -- convert note start to seconds
			local closest_grid = reaper.SnapToGrid(0, note_start) -- get closest grid (this function relies on visible grid)
			local closest_grid_ppq = reaper.MIDI_GetPPQPosFromProjTime(take, closest_grid) -- convert closest grid to PPQ
		
			if selected or not notes_selected then -- selected notes always move, unselected only move if no notes are selected
				if closest_grid_ppq ~= note_start_ppq then -- if notes are not on the grid
					reaper.MIDI_SetNote(take, n, nil, nil, note_start_ppq+(closest_grid_ppq-note_start_ppq)*strength/100, note_start_ppq+(closest_grid_ppq-note_start_ppq)*strength/100+note_end_ppq-note_start_ppq, nil, nil, nil, nil) -- quantize notes
				end
			end
		end
		
		reaper.MIDI_Sort(take)
		reaper.MIDIEditor_OnCommand(midi_editor, 40659) -- correct overlapping notes
		
		
		
		-- -------------------------------------------------- Grid Restore -------------------------------------------------- --
		
		-- restore ME grid settings (if user had grid sync enabled OR was using Inline Editor, grid_sync would be nil)
		if grid_sync ~= nil then
			MIDIGridRestore(midi_editor, midi_grid, midi_swing, midi_swing_amt)
		end

		-- restore grid minimum user value, if necessary
		GridRestore(arr_grid, arr_swing, arr_swing_amt, grid_linked, grid_minimum, grid_min_changed)
	end


-- ------------------------ Quantize selected item(s) in arrange view (ignore note selection) ----------------------- --

	local function QuantizeArrange(take)


		-- --------------------------------------------------- Grid Backup -------------------------------------------------- --

		-- set grid, after grid sync has been enabled, also backup previous arrange grid setting
		local arr_grid, arr_swing, arr_swing_amt, grid_linked, grid_minimum, grid_min_changed = SetGridAndBackup()


		-- ---------------------------------------------------- Quantize ---------------------------------------------------- --

		local _, notecnt, _, _ = reaper.MIDI_CountEvts(take) -- count notes and save amount to notecnt

		reaper.MIDI_DisableSort(take) -- disabling sorting improves execution speed

		for n = 0, notecnt - 1 do -- loop through all notes
			local _, _, _, note_start_ppq, note_end_ppq, _, _, _ = reaper.MIDI_GetNote(take, n) -- get selection status and positions

			local note_start = reaper.MIDI_GetProjTimeFromPPQPos(take, note_start_ppq) -- convert note start to seconds
			local closest_grid = reaper.SnapToGrid(0, note_start) -- get closest grid (this function relies on visible grid)
			local closest_grid_ppq = reaper.MIDI_GetPPQPosFromProjTime(take, closest_grid) -- convert closest grid to PPQ

			if closest_grid_ppq ~= note_start_ppq then -- if notes are not on the grid
				reaper.MIDI_SetNote(take, n, nil, nil, note_start_ppq+(closest_grid_ppq-note_start_ppq)*strength/100, note_start_ppq+(closest_grid_ppq-note_start_ppq)*strength/100+note_end_ppq-note_start_ppq, nil, nil, nil, nil) -- quantize all notes
			end
		end

		CorrectOverlappingNotes(take, notecnt)
		reaper.MIDI_Sort(take)


		-- -------------------------------------------------- Grid Restore -------------------------------------------------- --
		
		-- restore grid minimum user value, if necessary
		GridRestore(arr_grid, arr_swing, arr_swing_amt, grid_linked, grid_minimum, grid_min_changed)
	end


-- --------------- Quantize all notes within razor selections in arrange view (ignore note selection) --------------- --

	local function QuantizeRazorSelection(items_table)

		
		-- --------------------------------------------------- Grid Backup -------------------------------------------------- --

		-- set grid, after grid sync has been enabled, also backup previous arrange grid setting
		local arr_grid, arr_swing, arr_swing_amt, grid_linked, grid_minimum, grid_min_changed = SetGridAndBackup()


		-- ---------------------------------------------------- Quantize ---------------------------------------------------- --


		for index, value in pairs(items_table) do
			local item, razor_left, razor_right = value.item, value.razor_left, value.razor_right -- get razor item values from table
			
			local take = reaper.GetActiveTake(item)
			
			if reaper.TakeIsMIDI(take) then -- make sure, that take is MIDI
				local razor_left_ppq = reaper.MIDI_GetPPQPosFromProjTime(take, razor_left) -- convert left razor to PPQ
				local razor_right_ppq = reaper.MIDI_GetPPQPosFromProjTime(take, razor_right) -- convert left razor to PPQ

				local _, notecnt, _, _ = reaper.MIDI_CountEvts(take) -- count notes and save amount to notecnt

				reaper.MIDI_DisableSort(take) -- disabling sorting improves execution speed

				for n = 0, notecnt - 1 do -- loop through all notes
					local _, _, _, note_start_ppq, note_end_ppq, _, _, _ = reaper.MIDI_GetNote(take, n) -- get note positions

					local note_start = reaper.MIDI_GetProjTimeFromPPQPos(take, note_start_ppq) -- convert note start to seconds
					local closest_grid = reaper.SnapToGrid(0, note_start) -- get closest grid (this function relies on visible grid)
					local closest_grid_ppq = reaper.MIDI_GetPPQPosFromProjTime(take, closest_grid) -- convert closest grid to PPQ

					-- if notes are not on the grid and in between the razor selection
					if note_start_ppq >= razor_left_ppq 
					and note_start_ppq < razor_right_ppq 
					and closest_grid_ppq ~= note_start_ppq then 
						reaper.MIDI_SetNote(take, n, nil, nil, note_start_ppq+(closest_grid_ppq-note_start_ppq)*strength/100, note_start_ppq+(closest_grid_ppq-note_start_ppq)*strength/100+note_end_ppq-note_start_ppq, nil, nil, nil, nil) -- quantize all notes
					end
				end

				CorrectOverlappingNotes(take, notecnt)
				reaper.MIDI_Sort(take)
			end
		end
		
		-- -------------------------------------------------- Grid Restore -------------------------------------------------- --
		
		-- restore grid minimum user value, if necessary
		GridRestore(arr_grid, arr_swing, arr_swing_amt, grid_linked, grid_minimum, grid_min_changed)
	end



-- ================================================================================================================== --
--                                                        Main                                                        --
-- ================================================================================================================== --


	local function Main()
			
		reaper.PreventUIRefresh(1)

		local take, item, midi_editor
		local window, _, _ = reaper.BR_GetMouseCursorContext() -- initialize cursor context
		local _, inline_editor, _, _, _, _ = reaper.BR_GetMouseCursorContext_MIDI() -- check if mouse hovers an inline editor
		
		
		-- ----------------------------------------------- MIDI editor focused ---------------------------------------------- --

		if window == "midi_editor" then

			midi_editor = reaper.MIDIEditor_GetActive()

			if not inline_editor then
				take = reaper.MIDIEditor_GetTake(midi_editor) -- get take from active MIDI editor
				
			

			-- ---------------------------------------------- Inline Editor focused --------------------------------------------- --

			else
				take = reaper.BR_GetMouseCursorContext_Take() -- get take from mouse
			end
			
			QuantizeMIDIEditor(take, midi_editor) -- quantize notes

		
		
		-- -------------------------------------------- No MIDI editor is focused ------------------------------------------- --

		else

			
			-- --------------------------------------------- Razor selection exists --------------------------------------------- --

			if CheckForRazorSelection() then
				local items_table = GetRazorEditItems()
				QuantizeRazorSelection(items_table)



			-- ---------------------------------- Item selection and NO razor selection exists ---------------------------------- --

			else
				if reaper.CountSelectedMediaItems(0) ~= 0 then
					for i = 0, reaper.CountSelectedMediaItems(0)-1 do -- loop through all selected items
						item = reaper.GetSelectedMediaItem(0, i) -- get current selected item
						take = reaper.GetActiveTake(item)
						
						if reaper.TakeIsMIDI(take) then -- make sure, that take is MIDI
							QuantizeArrange(take) -- quantize notes
						end
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
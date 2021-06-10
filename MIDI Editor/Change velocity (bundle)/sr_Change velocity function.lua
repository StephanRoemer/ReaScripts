--  @noindex

function ChangeVelocity(velocity_val)

	
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
--                                              Change Velocity Functions                                             --
-- ================================================================================================================== --


-- ------------------- Change velocity of notes in the MIDI/inline editor (respect note selection) ------------------ --

	local function ChangeVelocityMIDIEditor(take)

		if reaper.TakeIsMIDI(take) then -- make sure, that take is MIDI
			local notes_selected, got_all_ok, midi_string, midi_len, table_events, string_pos, offset, flags, msg, msg_b3

			if reaper.MIDI_EnumSelNotes(take, -1) ~= -1 then notes_selected = true end -- check, if there are selected notes, set notes_selected to true

			got_all_ok, midi_string = reaper.MIDI_GetAllEvts(take, "") -- write MIDI events to midi_string, get all events okay
			if not got_all_ok then reaper.ShowMessageBox("Error while loading MIDI", "Error", 0) return(false) end -- if getting the MIDI data failed

			midi_len = #midi_string -- get string length
			table_events = {} -- initialize table, MIDI events will temporarily be stored in this table until they are concatenated into a string again
			string_pos = 1 -- position in midi_string while parsing through events 

			while string_pos < midi_len-12 do -- parse through all events in the MIDI string, one-by-one, excluding the final 12 bytes, which provides REAPER's All-notes-off end-of-take message
				offset, flags, msg, string_pos = string.unpack("i4Bs4", midi_string, string_pos) -- unpack MIDI-string on string_pos

				if #msg == 3 
				and (msg:byte(1)>>4) == 9 -- note-on?
				and (flags&1 == 1 or not notes_selected) then -- selected notes always change velocity, unselected only chnange velocity if no notes are selected

					msg_b3 = msg:byte(3) -- get velocity value

					if msg_b3 + velocity_val < 1 then 
						msg_b3 = 1 -- set velocity to 1, if current velocity + new velocity gets smaller than 1
					elseif msg_b3 + velocity_val > 127 then 
						msg_b3 = 127 -- set velocity to 127, if current velocity + new velocity gets bigger than 127
					else
						msg_b3 = msg_b3+velocity_val -- increase velocity by velocity_val
					end
					msg = msg:sub(1,1) .. msg:sub(2,2) .. string.char(msg_b3) -- convert velocity value to string, concatenate msg
				end    
				table.insert(table_events, string.pack("i4Bs4", offset, flags, msg)) -- re-pack MIDI string
			end
			reaper.MIDI_SetAllEvts(take, table.concat(table_events) .. midi_string:sub(-12))
			reaper.MIDI_Sort(take)
		end
	end


-- ------------------------ Change velocity of notes in arrange view (ignore note selection) ------------------------ --

	local function ChangeVelocityArrange(take)
		
		if reaper.TakeIsMIDI(take) then -- make sure, that take is MIDI
			local notes_selected, got_all_ok, midi_string, midi_len, table_events, string_pos, offset, flags, msg, msg_b3
			
			got_all_ok, midi_string = reaper.MIDI_GetAllEvts(take, "") -- write MIDI events to midi_string, get all events okay
			if not got_all_ok then reaper.ShowMessageBox("Error while loading MIDI", "Error", 0) return(false) end -- if getting the MIDI data failed

			midi_len = #midi_string -- get string length
			table_events = {} -- initialize table, MIDI events will temporarily be stored in this table until they are concatenated into a string again
			string_pos = 1 -- position in midi_string while parsing through events 

			while string_pos < midi_len-12 do -- parse through all events in the MIDI string, one-by-one, excluding the final 12 bytes, which provides REAPER's All-notes-off end-of-take message
				offset, flags, msg, string_pos = string.unpack("i4Bs4", midi_string, string_pos) -- unpack MIDI-string on string_pos

				if #msg == 3 
				and (msg:byte(1)>>4) == 9 -- note-on?
				then
					msg_b3 = msg:byte(3) -- get velocity value

					if msg_b3 + velocity_val < 1
						then msg_b3 = 1 -- set velocity to 1, if current velocity + new velocity gets smaller than 1
					elseif msg_b3 + velocity_val > 127
						then msg_b3 = 127 -- set velocity to 127, if current velocity + new velocity gets bigger than 127
					else
						msg_b3 = msg_b3+velocity_val -- increase velocity by velocity_val
					end
					msg = msg:sub(1,1) .. msg:sub(2,2) .. string.char(msg_b3) -- convert velocity value to string, concatenate msg
				end    
				table.insert(table_events, string.pack("i4Bs4", offset, flags, msg)) -- re-pack MIDI string
			end
			reaper.MIDI_SetAllEvts(take, table.concat(table_events) .. midi_string:sub(-12))
			reaper.MIDI_Sort(take)
		end
	end


-- ------------ Change velocity of notes within razor selections in arrange view (ignore note selection) ------------ --

	local function ChangeVelocityRazorSelection(items_table)	
			
		if reaper.TakeIsMIDI(take) then -- make sure, that take is MIDI
			for index, value in pairs(items_table) do
				local item, razor_left, razor_right = value.item, value.razor_left, value.razor_right -- get razor item values from table
				
				local take = reaper.GetActiveTake(item)

				if reaper.TakeIsMIDI(take) then -- make sure, that take is MIDI
					local razor_left_ppq = reaper.MIDI_GetPPQPosFromProjTime(take, razor_left) -- convert left razor to PPQ
					local razor_right_ppq = reaper.MIDI_GetPPQPosFromProjTime(take, razor_right) -- convert left razor to PPQ

					local _, notecnt, _, _ = reaper.MIDI_CountEvts(take) -- count notes and save amount to notes_count

					reaper.MIDI_DisableSort(take) -- disabling sorting improves execution speed

					for n = 0, notecnt do
						local _, _, _, note_start_ppq, _, _, _, velocity = reaper.MIDI_GetNote(take, n)
						local new_velocity = velocity + velocity_val

						
						-- if notes lie within razor selection and do not exceed the note range
						if note_start_ppq >= razor_left_ppq 
						and note_start_ppq < razor_right_ppq then

							if new_velocity < 1 then -- set velocity to 1, if current velocity + new velocity gets smaller than 1
								reaper.MIDI_SetNote(take, n, nil, nil, nil, nil, nil, nil, 1, true)
							elseif new_velocity > 127 then	-- set velocity to 127, if current velocity + new velocity gets bigger than 127
								reaper.MIDI_SetNote(take, n, nil, nil, nil, nil, nil, nil, 127, true)
							else  -- increase velocity by velocity_val
								reaper.MIDI_SetNote(take, n, nil, nil, nil, nil, nil, nil, new_velocity, true)
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
					ChangeVelocityMIDIEditor(take) -- change velocity


				-- Multiple items selected

				elseif item_cnt >= 1 then

					selnotes_items = CheckItemsForSelectedNotes(item_cnt)

					for i = 0, item_cnt - 1 do -- loop through all selected items
						take = reaper.GetActiveTake(reaper.GetSelectedMediaItem(0, i))

						-- Change velocity in either all items (no selected notes) or only items with selected notes 
						if selnotes_items == 0 or reaper.MIDI_EnumSelNotes(take, -1) ~= -1 then
							ChangeVelocityMIDIEditor(take) -- change velocity
						end
					end
				end
			

			-- ---------------------------------------------- Inline Editor focused --------------------------------------------- --

			else
				take = reaper.BR_GetMouseCursorContext_Take() -- get take from mouse
				ChangeVelocityMIDIEditor(take) -- change velocity
			end
			



			-- -------------------------------------------- No MIDI editor is focused ------------------------------------------- --

		else
				
			-- --------------------------------------------- Razor selection exists --------------------------------------------- --

			if CheckForRazorSelection() then
				local items_table = GetRazorEditItems()
				ChangeVelocityRazorSelection(items_table)  -- transpose notes		





			-- ---------------------------------- Item selection and NO razor selection exists ---------------------------------- --

			else
				if reaper.CountSelectedMediaItems(0) ~= 0 then
					for i = 0, reaper.CountSelectedMediaItems(0)-1 do -- loop through all selected items
						take = reaper.GetActiveTake(reaper.GetSelectedMediaItem(0, i))  -- get take of selected item
						ChangeVelocityArrange(take) -- change velocity
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

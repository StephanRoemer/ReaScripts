-- @nomain
-- @description MIDI functions
-- @version 1.1
-- @author Stephan Römer
-- @about
--    # Description
--    - this is a collection of MIDI functions, that are used by various scripts that I created.
--
-- @link https://forums.cockos.com/showthread.php?p=1923923
--
-- @changelog
--     v1.1 (2017-12-16)
--     + fixed changes not being visually reflected in the arrangement (thanks Julian Sader!)
--     v1.0
--     + Initial release


function quantize()
	for i = 0, reaper.CountSelectedMediaItems(0)-1 do -- loop through all selected items
		item = reaper.GetSelectedMediaItem(0, i)
		for t = 0, reaper.CountTakes(item)-1 do -- Loop through all takes within each selected item
			take = reaper.GetTake(item, t)
			if reaper.TakeIsMIDI(take) then -- make sure, that take is MIDI
				notes = reaper.MIDI_CountEvts(take) -- count notes and save amount to notes
				for n = 0, notes - 1 do -- loop thru all notes
					if reaper.MIDI_EnumSelNotes(take, n) > 0 then -- if at least one note is selected
						notes_selected = true -- set notes_selected to true
						break -- break the for loop, because at least one selected note was found
					end
				end
				for n = 0, notes - 1 do -- loop thru all notes
					_, selectedOut, _, startppqposOut, endppqposOut, chanOut, pitchOut, velOut = reaper.MIDI_GetNote(take, n) -- get selection status and pitch
					noteStart = reaper.MIDI_GetProjTimeFromPPQPos(take, startppqposOut) -- convert note start to seconds
					closestGrid = reaper.SnapToGrid(0, noteStart) -- get closest grid for current note (return value in seconds)
					closestGridPPQ = reaper.MIDI_GetPPQPosFromProjTime(take, closestGrid) -- convert closest grid to PPQ
					if notes_selected == true then -- if there is a note selection
						if selectedOut == true then -- filter out selected notes to add notes
							if closestGridPPQ ~= startppqposOut then
								reaper.MIDI_SetNote(take, n, true, false, closestGridPPQ, closestGridPPQ+endppqposOut-startppqposOut, chanOut, pitchOut, velOut, true) -- add notes by interval to all notes
							end
						end
					else
						if closestGridPPQ ~= startppqposOut then
							reaper.MIDI_SetNote(take, n, false, false, closestGridPPQ, closestGridPPQ+endppqposOut-startppqposOut, chanOut, pitchOut, velOut, true) -- add notes by interval to all notes
						end
					end
				end
				reaper.MIDI_Sort(take)
			end
		end
	end
end


function human_quantize(humanize)
	for i = 0, reaper.CountSelectedMediaItems(0)-1 do -- loop through all selected items
		item = reaper.GetSelectedMediaItem(0, i)
		for t = 0, reaper.CountTakes(item)-1 do -- Loop through all takes within each selected item
			take = reaper.GetTake(item, t)
			if reaper.TakeIsMIDI(take) then -- make sure, that take is MIDI
				notes = reaper.MIDI_CountEvts(take) -- count notes and save amount to notes
				for n = 0, notes - 1 do -- loop thru all notes
					if reaper.MIDI_EnumSelNotes(take, n) > 0 then -- if at least one note is selected
						notes_selected = true -- set notes_selected to true
						break -- break the for loop, because at least one selected note was found
					end
				end
				for n = 0, notes - 1 do -- loop thru all notes
					_, selectedOut, _, startppqposOut, endppqposOut, chanOut, pitchOut, velOut = reaper.MIDI_GetNote(take, n) -- get note values
					noteStart = reaper.MIDI_GetProjTimeFromPPQPos(take, startppqposOut) -- convert note start to seconds
					closestGrid = reaper.SnapToGrid(0, noteStart) -- get closest grid for current note (return value in seconds)
					closestGridPPQ = reaper.MIDI_GetPPQPosFromProjTime(take, closestGrid) -- convert closest grid to PPQ
					if notes_selected == true then -- if there is a note selection
						if selectedOut == true then -- filter out selected notes to quantize
							if closestGridPPQ ~= startppqposOut then -- if note is not on grid
								reaper.MIDI_SetNote(take, n, true, false, startppqposOut - humanize / 100 * (startppqposOut-closestGridPPQ), startppqposOut - humanize / 100 * (startppqposOut-closestGridPPQ)+endppqposOut-startppqposOut, chanOut, pitchOut, velOut, true) -- quantize selected notes by humanize value
								
							end
						end
					else
						if closestGridPPQ ~= startppqposOut then
							reaper.MIDI_SetNote(take, n, false, false, startppqposOut - humanize / 100 * (startppqposOut-closestGridPPQ), startppqposOut - humanize / 100 * (startppqposOut-closestGridPPQ)+endppqposOut-startppqposOut, chanOut, pitchOut, velOut, true) -- add notes by interval to all notes
						end
					end
				end
			end
		end
	end
end


function add_notes(interval)
	for i = 0, reaper.CountSelectedMediaItems(0)-1 do -- loop through all selected items
		item = reaper.GetSelectedMediaItem(0, i)
		for t = 0, reaper.CountTakes(item)-1 do -- Loop through all takes within each selected item
			take = reaper.GetTake(item, t)
			if reaper.TakeIsMIDI(take) then -- make sure, that take is MIDI
				notes = reaper.MIDI_CountEvts(take) -- count notes and save amount to notes
				for n = 0, notes - 1 do -- loop thru all notes
					if reaper.MIDI_EnumSelNotes(take, n) > 0 then -- if at least one note is selected
						notes_selected = true -- set notes_selected to true
						break -- break the for loop, because at least one selected note was found
					end
				end
				for n = 0, notes - 1 do -- loop thru all notes
					_, selectedOut, _, startppqposOut, endppqposOut, chanOut, pitchOut, velOut = reaper.MIDI_GetNote(take, n) -- get selection status and pitch
					if notes_selected == true then -- if there is a note selection
						if selectedOut == true then -- filter out selected notes to add notes
							reaper.MIDI_InsertNote(take, false, false, startppqposOut, endppqposOut, chanOut, pitchOut+interval, velOut, true) -- add notes by interval to selected notes
						end
					else
						reaper.MIDI_InsertNote(take, false, false, startppqposOut, endppqposOut, chanOut, pitchOut+interval, velOut, true) -- add notes by interval to all notes
					end
				end
				reaper.MIDI_Sort(take)
			end
		end
	end
end


function transpose(interval)
	for i = 0, reaper.CountSelectedMediaItems(0)-1 do -- loop through all selected items
		item = reaper.GetSelectedMediaItem(0, i)
		for t = 0, reaper.CountTakes(item)-1 do -- Loop through all takes within each selected item
			take = reaper.GetTake(item, t)
			if reaper.TakeIsMIDI(take) then -- make sure, that take is MIDI
				notes = reaper.MIDI_CountEvts(take) -- count notes and save amount to notes
				for n = 0, notes - 1 do -- loop thru all notes
					if reaper.MIDI_EnumSelNotes(take, n) > 0 then -- if at least one note is selected
						notes_selected = true -- set notes_selected to true
						break -- break the for loop, because at least one selected note was found
					end
				end
			
				for n = 0, notes - 1 do -- loop thru all notes
					_, selectedOut, _, _, _, _, pitchOut, _ = reaper.MIDI_GetNote(take, n) -- get selection status and pitch
					if notes_selected == true then -- if there is a note selection
						if selectedOut == true then -- filter out selected notes to apply transpose
							reaper.MIDI_SetNote(take, n, true, nil, nil, nil, nil, pitchOut+interval, nil, true) -- transpose selected notes by interval
						end
					else
						reaper.MIDI_SetNote(take, n, nil, nil, nil, nil, nil, pitchOut+interval, nil, true) -- transpose all notes by interval
					end
				reaper.MIDI_Sort(take)
				end
			end
		end
	end
end


function select_CC(destCC)
	for i = 0, reaper.CountSelectedMediaItems(0)-1 do -- loop through all selected items
		item = reaper.GetSelectedMediaItem(0, i)
		for t = 0, reaper.CountTakes(item)-1 do -- Loop through all takes within each selected item
			take = reaper.GetTake(item, t)
			if reaper.TakeIsMIDI(take) then -- make sure, that take is MIDI
				_, _, ccCount, _ = reaper.MIDI_CountEvts(take) -- count CCs and save amount to ccCount
				for c = 0, ccCount - 1 do -- loop thru all CCs
					_, _, _, _, _, _, cc, _ = reaper.MIDI_GetCC(take, c) -- get values from CCs
					if cc == destCC then -- if CC is destCC
						reaper.MIDI_SetCC(take, c, true, nil, nil, nil, nil, nil, nil, true) -- select CC
					end
				end
			end
		end
	end
end


function select_CC_before_edit_cursor(destCC)
	for i = 0, reaper.CountSelectedMediaItems(0)-1 do -- loop through all selected items
		item = reaper.GetSelectedMediaItem(0, i)
		for t = 0, reaper.CountTakes(item)-1 do -- Loop through all takes within each selected item
			take = reaper.GetTake(item, t)
			if reaper.TakeIsMIDI(take) then -- make sure, that take is MIDI
				cursor_position = reaper.GetCursorPosition()  -- get edit cursor position 
				cursor_position_ppq = reaper.MIDI_GetPPQPosFromProjTime(take, cursor_position) -- convert to PPQ
				_, _, ccCount, _ = reaper.MIDI_CountEvts(take) -- count CCs and save amount to ccCount
				for c = 0, ccCount - 1 do -- loop thru all CCs
					_, _, _, ppqposOut, _, _, cc, _ = reaper.MIDI_GetCC(take, c) -- get values from CCs
					if cc == destCC and ppqposOut < cursor_position_ppq then -- if CC is destCC
						reaper.MIDI_SetCC(take, c, true, nil, nil, nil, nil, nil, nil, true) -- select destCC
					elseif cc == destCC then -- if destCC is after edit cursor
						reaper.MIDI_SetCC(take, c, false, nil, nil, nil, nil, nil, nil, true) -- unselect destCC
					end
				end
			end
		end
	end
end


function select_CC_after_edit_cursor(destCC)
	for i = 0, reaper.CountSelectedMediaItems(0)-1 do -- loop through all selected items
		item = reaper.GetSelectedMediaItem(0, i)
		for t = 0, reaper.CountTakes(item)-1 do -- Loop through all takes within each selected item
			take = reaper.GetTake(item, t)
			if reaper.TakeIsMIDI(take) then -- make sure, that take is MIDI
				cursor_position = reaper.GetCursorPosition()  -- get edit cursor position 
				cursor_position_ppq = reaper.MIDI_GetPPQPosFromProjTime(take, cursor_position) -- convert to PPQ
				_, _, ccCount, _ = reaper.MIDI_CountEvts(take) -- count CCs and save amount to ccCount
				for c = 0, ccCount - 1 do -- loop thru all CCs
					_, _, _, ppqposOut, _, _, cc, _ = reaper.MIDI_GetCC(take, c) -- get values from CCs
					if cc == destCC and ppqposOut >= cursor_position_ppq then -- if CC is destCC
						reaper.MIDI_SetCC(take, c, true, nil, nil, nil, nil, nil, nil, true) -- select destCC
					elseif cc == destCC then -- if destCC is before edit cursor 
						reaper.MIDI_SetCC(take, c, false, nil, nil, nil, nil, nil, nil, true) -- unselect destCC
					end
				end
			end
		end
	end
end

function delete_CC (destCC)
	for i = 0, reaper.CountSelectedMediaItems(0)-1 do -- loop through all selected items
		item = reaper.GetSelectedMediaItem(0, i)
		for t = 0, reaper.CountTakes(item)-1 do -- Loop through all takes within each selected item
			take = reaper.GetTake(item, t)
			if reaper.TakeIsMIDI(take) then -- make sure, that take is MIDI
				_, _, ccCount, _ = reaper.MIDI_CountEvts(take) -- count CCs and save amount to ccCount
				for c = ccCount - 1, 0, -1 do -- loop thru all CCs, back to forth
					_, _, _, _, _, _, cc, _ = reaper.MIDI_GetCC(take, c) -- get values from CCs
					if cc == destCC then -- if CC is destCC
						reaper.MIDI_DeleteCC(take, c) -- delete destCC
					end
				end
			end
		end
	end
end


function delete_CC_after_edit_cursor(destCC)
	for i = 0, reaper.CountSelectedMediaItems(0)-1 do -- loop through all selected items
		item = reaper.GetSelectedMediaItem(0, i)
		for t = 0, reaper.CountTakes(item)-1 do -- Loop through all takes within each selected item
			take = reaper.GetTake(item, t)
			if reaper.TakeIsMIDI(take) then -- make sure, that take is MIDI
				cursor_position = reaper.GetCursorPosition()  -- get edit cursor position 
				cursor_position_ppq = reaper.MIDI_GetPPQPosFromProjTime(take, cursor_position) -- convert to PPQ
				_, _, ccCount, _ = reaper.MIDI_CountEvts(take) -- count CCs and save amount to ccCount
				for c = ccCount - 1, 0, -1 do -- loop thru all CCs, back to forth
					_, _, _, ppqposOut, _, _, cc, _ = reaper.MIDI_GetCC(take, c) -- get values from CCs
					if cc == destCC and ppqposOut >= cursor_position_ppq then -- if CC is destCC and CC position is after edit cursor
						reaper.MIDI_DeleteCC(take, c) -- delete CC
					end
				end
			end
		end
	end
end

	
function delete_CC_before_edit_cursor(destCC)
	for i = 0, reaper.CountSelectedMediaItems(0)-1 do -- loop through all selected items
		item = reaper.GetSelectedMediaItem(0, i)
		for t = 0, reaper.CountTakes(item)-1 do -- Loop through all takes within each selected item
			take = reaper.GetTake(item, t)
			if reaper.TakeIsMIDI(take) then -- make sure, that take is MIDI
				cursor_position = reaper.GetCursorPosition()  -- get edit cursor position 
				cursor_position_ppq = reaper.MIDI_GetPPQPosFromProjTime(take, cursor_position) -- convert to PPQ
				_, _, ccCount, _ = reaper.MIDI_CountEvts(take) -- count CCs and save amount to ccCount
				for c = ccCount - 1, 0, -1 do -- loop thru all CCs, back to forth
					_, _, _, ppqposOut, _, _, cc, _ = reaper.MIDI_GetCC(take, c) -- get values from CCs
					if cc == destCC and ppqposOut < cursor_position_ppq then -- if CC is destCC
						reaper.MIDI_DeleteCC(take, c) -- delete destCC
					end
				end
			end
		end
	end
end


function move_srcCC_to_destCC(srcCC, destCC)
	for i = 0, reaper.CountSelectedMediaItems(0)-1 do -- loop through all selected items
		item = reaper.GetSelectedMediaItem(0, i)
		for t = 0, reaper.CountTakes(item)-1 do -- Loop through all takes within each selected item
			take = reaper.GetTake(item, t)
			if reaper.TakeIsMIDI(take) then -- make sure, that take is MIDI
				_, _, ccCount, _ = reaper.MIDI_CountEvts(take) -- count CCs and save amount to ccCount
				for c = 0, ccCount - 1 do -- loop thru all CCs
					_, _, _, ppqposOut, chanmsgOut, chanOut, cc, ccValue = reaper.MIDI_GetCC(take, c) -- get values from CCs
					if cc == srcCC then -- if CC is srcCC
						reaper.MIDI_InsertCC(take, false, false, ppqposOut, chanmsgOut, chanOut, destCC, ccValue) -- insert srcCC values into destCC lane
						reaper.MIDI_DeleteCC(take, c) -- after copying srcCC to destCC, delete srcCC (=move)
					end
				end
			end
			reaper.MIDI_Sort(take)
		end
	end
end

	
function increase_CC(destCC, increase)
	for i = 0, reaper.CountSelectedMediaItems(0)-1 do -- loop through all selected items
		item = reaper.GetSelectedMediaItem(0, i)
		for t = 0, reaper.CountTakes(item)-1 do -- Loop through all takes within each selected item
			take = reaper.GetTake(item, t)
			if reaper.TakeIsMIDI(take) then -- make sure, that take is MIDI
				_, _, ccCount, _ = reaper.MIDI_CountEvts(take) -- count CCs and save amount to ccCount
				for c = 0, ccCount - 1 do -- loop thru all CCs
					if reaper.MIDI_EnumSelCC(take, c) > 0 then -- if at least one CC event is selected
						selectionExists = true -- set selectionExists to true
						break
					end
				end
				for c = 0, ccCount - 1 do -- loop thru all CCs
					_, ccSelected, _, _, _, _, cc, ccValue = reaper.MIDI_GetCC(take, c) -- get values from CCs
					if selectionExists == true then -- if there is a CC selection
						if cc == destCC and ccSelected == true then -- if CC is destCC and is selected
							reaper.MIDI_SetCC(take, c, nil, nil, nil, nil, nil, nil, math.min(127, (math.ceil(ccValue*increase))), true) -- multiply ccValue with increase, convert to integer and limit highest value to 127
						end
					else
						if cc == destCC then -- if CC is destCC
							reaper.MIDI_SetCC(take, c, nil, nil, nil, nil, nil, nil, math.min(127, (math.ceil(ccValue*increase))), true) -- multiply ccValue with increase, convert to integer and limit highest value to 127
						end
					end
				end
				reaper.MIDI_Sort(take)
			end
		end
	end
end


function decrease_CC(destCC, decrease)
	for i = 0, reaper.CountSelectedMediaItems(0)-1 do -- loop through all selected items
		item = reaper.GetSelectedMediaItem(0, i)
		for t = 0, reaper.CountTakes(item)-1 do -- Loop through all takes within each selected item
			take = reaper.GetTake(item, t)
			if reaper.TakeIsMIDI(take) then -- make sure, that take is MIDI
				_, _, ccCount, _ = reaper.MIDI_CountEvts(take) -- count CCs and save amount to ccCount
				for c = 0, ccCount - 1 do -- loop thru all CCs
					if reaper.MIDI_EnumSelCC(take, c) > 0 then -- if at least one CC event is selected
						selectionExists = true -- set selectionExists to true
						break
					end
				end
				for c = 0, ccCount - 1 do -- loop thru all CCs
					_, ccSelected, _, _, _, _, cc, ccValue = reaper.MIDI_GetCC(take, c) -- get values from CCs
					if selectionExists == true then -- if there is a CC selection
						if cc == destCC and ccSelected == true then -- if CC is destCC and is selected
							reaper.MIDI_SetCC(take, c, nil, nil, nil, nil, nil, nil, math.max(1, (math.floor(ccValue/decrease))), true) -- divide ccValue by decrease, convert to integer and limit lowest value to 0
						end	
					else
						if cc == destCC then -- if CC is destCC
							reaper.MIDI_SetCC(take, c, nil, nil, nil, nil, nil, nil, math.max(1, (math.floor(ccValue/decrease))), true) -- divide ccValue by decrease, convert to integer and limit lowest value to 0
						end
					end
				end
				reaper.MIDI_Sort(take)
			end
		end
	end
end




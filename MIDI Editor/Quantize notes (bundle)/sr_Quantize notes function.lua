--  @noindex

function Quantize(newGrid, newSwing, newSwingAmt, strength, useCurGrid)
	-- sockmonkey72's MIDIUtils init and settings
	package.path = reaper.GetResourcePath() .. "/Scripts/sockmonkey72 Scripts/MIDI/?.lua"
	local mu = require("MIDIUtils")
	mu.CORRECT_OVERLAPS = true

	--  ╔══════════════════════════════════════════════════════════════════════════════════════════════════╗
	--  ║                                         Helper Functions                                         ║
	--  ╚══════════════════════════════════════════════════════════════════════════════════════════════════╝

	-- Check if item can be modified (= is neither looped, locked or not MIDI)

	local function ItemModifiable(item, take)
		-- Get loop status for item
		local IsLooped = reaper.GetMediaItemInfo_Value(item, "B_LOOPSRC")
		local isLocked = reaper.GetMediaItemInfo_Value(item, "C_LOCK")
		local isMidi = reaper.TakeIsMIDI(take)

		if IsLooped == 1.0 or isLocked == 1.0 or isMidi == false then
			return false
		else
			return true
		end
	end

	-- Round to an arbitrary number of digits. Thanks Leon!

	function Round(num, idp)
		local mult = 10 ^ (idp or 0)
		return math.floor(num * mult + 0.5) / mult
	end

	-- Store take within razor selection to table

	local function GetRazorTakes()
		local trackCnt = reaper.CountTracks(0)
		local razorItems = {}

		for t = 0, trackCnt - 1 do
			local track = reaper.GetTrack(0, t)
			local trackItemCnt = reaper.CountTrackMediaItems(track)
			local isFreemode = reaper.GetMediaTrackInfo_Value(track, "B_FREEMODE")

			-- Track is set to single lane
			if isFreemode == 0 then
				local razorOk, razorStr = reaper.GetSetMediaTrackInfo_String(track, "P_RAZOREDITS", "", false)
				if razorOk and #razorStr ~= 0 then
					-- Parse string for razor selection

					for razorLeft, razorRight, envGuid in razorStr:gmatch([[([%d%.]+) ([%d%.]+) "([^"]*)"]]) do
						if envGuid == "" then -- ignore envelope razor selection
							razorLeft, razorRight = tonumber(razorLeft), tonumber(razorRight)

							-- Go thru all items on current track and check if they overlap with razor boundaries

							for i = 0, trackItemCnt - 1 do
								local item = reaper.GetTrackMediaItem(track, i)
								local itemStart = reaper.GetMediaItemInfo_Value(item, "D_POSITION")
								local itemEnd = itemStart + reaper.GetMediaItemInfo_Value(item, "D_LENGTH")
								local take = reaper.GetActiveTake(item)

								-- Store found items to table

								if itemStart < razorRight and itemEnd > razorLeft and ItemModifiable(item, take) then
									razorItems[#razorItems + 1] = {
										take = take,
										razorLeft = razorLeft,
										razorRight = razorRight,
									}
								end
							end
						end
					end
				end

			-- Track is set to multi (fixed) lanes
			else
				local razorOk, razorStr = reaper.GetSetMediaTrackInfo_String(track, "P_RAZOREDITS_EXT", "", false)
				if razorOk and #razorStr ~= 0 then
					-- Parse string for razor selection

					for razorLeft, razorRight, envGuid, razorTop, razorBottom in
						razorStr:gmatch([[([%d%.]+) ([%d%.]+) "([^"]*)" ([%d%.]+) ([%d%.]+)]])
					do
						if envGuid == "" then -- ignore envelope razor selection
							razorLeft, razorRight, razorTop, razorBottom =
								tonumber(razorLeft), tonumber(razorRight), tonumber(razorTop), tonumber(razorBottom)

							for i = 0, trackItemCnt - 1 do
								local item = reaper.GetTrackMediaItem(track, i)
								local take = reaper.GetActiveTake(item)
								local itemStart = reaper.GetMediaItemInfo_Value(item, "D_POSITION")
								local itemEnd = itemStart + reaper.GetMediaItemInfo_Value(item, "D_LENGTH")
								local itemTop = reaper.GetMediaItemInfo_Value(item, "F_FREEMODE_Y")
								local itemTopR = Round(itemTop, 6) -- round to 6 decimals, because the razor value is truncated at 6 decimals (=string)
								local itemHeight = reaper.GetMediaItemInfo_Value(item, "F_FREEMODE_H")
								local itemBottomR = Round(itemTop + itemHeight, 6)

								-- Store found items to table
								if
									itemTopR >= razorTop
									and itemBottomR <= razorBottom
									and itemStart < razorRight
									and itemEnd > razorLeft
									and ItemModifiable(item, take)
								then
									razorItems[#razorItems + 1] = {
										take = take,
										razorLeft = razorLeft,
										razorRight = razorRight,
									}
								end
							end
						end
					end
				end
			end
		end

		if next(razorItems) ~= nil then -- table not empty?
			return razorItems
		else
			return false
		end
	end

	-- Extend item end, if (all or selected) notes will exceed take end

	local function ExtendItem(take, rightmostNEnd)
		local item = reaper.GetMediaItemTake_Item(take)

		-- Get item end boundary in ppq
		local itemStart = reaper.GetMediaItemInfo_Value(item, "D_POSITION") -- get item position
		local itemEnd = itemStart + reaper.GetMediaItemInfo_Value(item, "D_LENGTH") -- calculate item end position
		local itemEndPpq = reaper.MIDI_GetPPQPosFromProjTime(take, itemEnd) -- convert item end position to ppq

		if rightmostNEnd > itemEndPpq then -- if note that is closest to item end exceeds item, extend item end
			local rightmostNEndPT = reaper.MIDI_GetProjTimeFromPPQPos(take, rightmostNEnd) -- convert closest note end to project time
			local nextGridPos = reaper.SnapToGrid(0, rightmostNEndPT) -- snap note end to closest grid
			nextGridPos = reaper.BR_GetNextGridDivision(nextGridPos) -- from there, add another grid division
			reaper.MIDI_SetItemExtents(
				item,
				reaper.TimeMap2_timeToQN(0, itemStart),
				reaper.TimeMap2_timeToQN(0, nextGridPos)
			) -- extend item to next grid position
		end
	end

	--  ╔══════════════════════════════════════════════════════════════════════════════════════════════════╗
	--  ║                                 Grid store and restore functions                                 ║
	--  ╚══════════════════════════════════════════════════════════════════════════════════════════════════╝

	-- Set / backup grid settings (necessary for SnapToGrid() to work)

	local function SetArrangeGrid()
		local gridVisLinked, gridMinimum, gridMinChanged

		-- Backup Arrange grid settings
		local _, arrGrid, arrSwing, arrSwingAmt = reaper.GetSetProjectGrid(0, false)

		-- Set new grid settings, provided by aux script
		reaper.GetSetProjectGrid(0, true, newGrid, newSwing, newSwingAmt)

		-- If snap doesn't follow grid visiblity, enable it
		if reaper.GetToggleCommandState(reaper.NamedCommandLookup("_BR_OPTIONS_SNAP_FOLLOW_GRID_VIS")) == 0 then
			reaper.Main_OnCommand(reaper.NamedCommandLookup("_BR_OPTIONS_SNAP_FOLLOW_GRID_VIS"), 0)
			gridVisLinked = true
		end

		-- Get grid minimum, if value is higher than 0, then project zoom will define the visible grid
		gridMinimum = reaper.SNM_GetIntConfigVar("projgridmin", 0)
		if gridMinimum > 0 then
			reaper.SNM_SetIntConfigVar("projgridmin", 0) -- set minimum to 0 so that the project zoom doesn't affect SnapToGrid()
			gridMinChanged = true
		end

		return arrGrid, arrSwing, arrSwingAmt, gridVisLinked, gridMinimum, gridMinChanged
	end

	-- Restore Arrange grid settings

	local function RestoreArrangeGrid(arrGrid, arrSwing, arrSwingAmt, gridVisLinked, gridMinimum, gridMinChanged)
		if gridMinChanged == true then
			reaper.SNM_SetIntConfigVar("projgridmin", gridMinimum)
		end

		-- Toggle off "snap follows grid visiblity"
		if gridVisLinked == true then
			reaper.Main_OnCommand(reaper.NamedCommandLookup("_BR_OPTIONS_SNAP_FOLLOW_GRID_VIS"), 0)
		end

		-- Finally, restore Arrange grid settings
		reaper.GetSetProjectGrid(0, true, arrGrid, arrSwing, arrSwingAmt)
	end

	-- Set / backup MIDI Editor grid and then sync with arrange

	-- In order to apply swing to the MIDI Editor, it is necessary to temporarily sync the MIDI Editor grid with the Arrange,
	-- because there is no API to set the swing amount in the MIDI Editor.

	local function SetMIDIEditorGrid(take)
		local midiGrid, midiSwingAmt, midiSwing, gridSync, gridVisLinked, gridMinimum, gridMinChanged

		-- Backup arrange grid settings
		local _, arrGrid, arrSwing, arrSwingAmt = reaper.GetSetProjectGrid(0, false)

		-- If snap doesn't follow grid visiblity, enable it
		if reaper.GetToggleCommandState(reaper.NamedCommandLookup("_BR_OPTIONS_SNAP_FOLLOW_GRID_VIS")) == 0 then
			reaper.Main_OnCommand(reaper.NamedCommandLookup("_BR_OPTIONS_SNAP_FOLLOW_GRID_VIS"), 0)
			gridVisLinked = true
		end

		-- Get grid minimum, if value is higher than 0, then project zoom will define the visible grid
		gridMinimum = reaper.SNM_GetIntConfigVar("projgridmin", 0)
		if gridMinimum > 0 then
			reaper.SNM_SetIntConfigVar("projgridmin", 0) -- set minimum to 0 so that the project zoom doesn't affect SnapToGrid()
			gridMinChanged = true
		end

		-- If MIDI Editor and Arrange grid aren't synced, backup MIDI grid and temporarily sync it
		if reaper.GetToggleCommandStateEx(32060, 41022) == 0 then
			-- Backup MIDI Editor grid settings
			midiGrid, midiSwingAmt, _ = reaper.MIDI_GetGrid(take)
			midiGrid = midiGrid / 4 -- QN to PPQ

			-- MIDI_GetGrid() has no setting for swing on/off, instead: if swing amount is bigger than 0, then swing is turned on
			if midiSwingAmt > 0 then
				midiSwing = 1
			else
				midiSwing = 0
			end

			-- Toggle on: use same grid settings for MIDI Editor and arrange
			reaper.SetToggleCommandState(32060, 41022, 1) -- enable grid sync
			gridSync = true -- indicate that grid sync was necessary, in order to restore it later
		end

		-- Use current grid or external values
		if useCurGrid == true then
			reaper.GetSetProjectGrid(0, true, midiGrid, midiSwing, midiSwingAmt) -- set Arrange to MIDI Editor grid settings
		else
			reaper.GetSetProjectGrid(0, true, newGrid, newSwing, newSwingAmt) -- set Arrange to grid values, provided by external script
		end

		return gridSync,
			midiGrid,
			midiSwing,
			midiSwingAmt,
			arrGrid,
			arrSwing,
			arrSwingAmt,
			gridVisLinked,
			gridMinimum,
			gridMinChanged
	end

	-- Restore MIDI Editor grid and unsync from arrange

	local function RestoreMIDIEditorGrid(
		gridSync,
		midiGrid,
		midiSwing,
		midiSwingAmt,
		arrGrid,
		arrSwing,
		arrSwingAmt,
		gridVisLinked,
		gridMinimum,
		gridMinChanged
	)
		-- Restore gridMinimum in arrange grid
		if gridMinChanged == true then
			reaper.SNM_SetIntConfigVar("projgridmin", gridMinimum)
		end

		-- Toggle off "snap follows grid visiblity"
		if gridVisLinked == true then
			reaper.Main_OnCommand(reaper.NamedCommandLookup("_BR_OPTIONS_SNAP_FOLLOW_GRID_VIS"), 0)
		end

		-- If grid sync was previously off, restore MIDI Editor grid settings and disable grid sync
		if gridSync == true then
			reaper.GetSetProjectGrid(0, true, midiGrid, midiSwing, midiSwingAmt) -- restore MIDI Editor grid setting
			reaper.SetToggleCommandState(32060, 41022, 0) -- siable grid sync
		end

		-- Finally, restore Arrange grid settings
		reaper.GetSetProjectGrid(0, true, arrGrid, arrSwing, arrSwingAmt)
	end

	--  ╔══════════════════════════════════════════════════════════════════════════════════════════════════╗
	--  ║                                        Quantize Functions                                        ║
	--  ╚══════════════════════════════════════════════════════════════════════════════════════════════════╝

	local function Quantize(take, notesSelected)
		mu.MIDI_OpenWriteTransaction(take)

		local rightmostNEnd = 0 -- start value for note boundary

		local _, noteCnt, _, _ = mu.MIDI_CountEvts(take)

		for n = 0, noteCnt - 1 do -- loop through all notes
			local _, selected, _, nStart, nEnd, _, _, _ = mu.MIDI_GetNote(take, n) -- get selection status and positions

			local noteStartPT = reaper.MIDI_GetProjTimeFromPPQPos(take, nStart) -- convert note start to seconds
			local closestGridPT = reaper.SnapToGrid(0, noteStartPT) -- get closest grid (this function relies on visible grid)
			local closestGrid = reaper.MIDI_GetPPQPosFromProjTime(take, closestGridPT) -- convert closest grid to PPQ

			if
				selected
				or not notesSelected -- selected notes always move, unselected only move if no notes are selected
					and closestGrid ~= nStart -- if notes are not on the grid
			then
				mu.MIDI_SetNote(
					take,
					n,
					nil,
					nil,
					nStart + (closestGrid - nStart) * strength / 100,
					nStart + (closestGrid - nStart) * strength / 100 + nEnd - nStart,
					nil,
					nil,
					nil,
					nil
				) -- quantize notes

				-- While iterating, also store note end boundary in order to extend the item, if necessary
				if nStart + (closestGrid - nStart) * strength / 100 + nEnd - nStart > rightmostNEnd then
					rightmostNEnd = nStart + (closestGrid - nStart) * strength / 100 + nEnd - nStart
				end
			end
		end
		mu.MIDI_CommitWriteTransaction(take)
		ExtendItem(take, rightmostNEnd)
	end

	local function QuantizeRazorSelection(take, razorLeft, razorRight)
		mu.MIDI_OpenWriteTransaction(take)

		local razorLeftPPQ = reaper.MIDI_GetPPQPosFromProjTime(take, razorLeft) -- convert left razor to PPQ
		local razorRightPPQ = reaper.MIDI_GetPPQPosFromProjTime(take, razorRight) -- convert left razor to PPQ
		local _, noteCnt, _, _ = mu.MIDI_CountEvts(take) -- count notes and save amount to notecnt
		local rightmostNEnd = 0

		for n = 0, noteCnt - 1 do -- loop through all notes
			local _, _, _, nStart, nEnd, _, _, _ = mu.MIDI_GetNote(take, n) -- get note positions
			local noteStartPT = reaper.MIDI_GetProjTimeFromPPQPos(take, nStart) -- convert note start to seconds
			local closestGridPT = reaper.SnapToGrid(0, noteStartPT) -- get closest grid (this function relies on visible grid)
			local closestGrid = reaper.MIDI_GetPPQPosFromProjTime(take, closestGridPT) -- convert closest grid to PPQ

			-- If notes are on the grid and in between the razor selection
			if nStart >= razorLeftPPQ and nStart < razorRightPPQ and closestGrid ~= nStart then
				mu.MIDI_SetNote(
					take,
					n,
					nil,
					nil,
					nStart + (closestGrid - nStart) * strength / 100,
					nStart + (closestGrid - nStart) * strength / 100 + nEnd - nStart,
					nil,
					nil,
					nil,
					nil
				) -- quantize all notes

				-- While iterating, also store note end boundary in order to extend the item, if necessary
				if nStart + (closestGrid - nStart) * strength / 100 + nEnd - nStart > rightmostNEnd then
					rightmostNEnd = nStart + (closestGrid - nStart) * strength / 100 + nEnd - nStart
				end
			end
		end
		mu.MIDI_CommitWriteTransaction(take)
		ExtendItem(take, rightmostNEnd)
	end

	--  ╔══════════════════════════════════════════════════════════════════════════════════════════════════╗
	--  ║                                     Process Focus Functions                                      ║
	--  ╚══════════════════════════════════════════════════════════════════════════════════════════════════╝

	local function ProcessMIDIEditor()
		local takeTbl = {}
		local notesSelected
		local takeCntSelNotes = 0
		local midiEditor = reaper.MIDIEditor_GetActive()

		-- Write all takes into a table. 1st iteration gets all editable takes and note selection,
		-- 2nd iteration processes the takes.

		for i = 0, math.huge do -- iterate to infinity
			local take = reaper.MIDIEditor_EnumTakes(midiEditor, i, true) -- get editable takes

			-- As long as there are takes and items are modifiable
			if take ~= nil and ItemModifiable(reaper.GetMediaItemTake_Item(take), take) then
				-- If at least a single event is selected, set true
				notesSelected = mu.MIDI_EnumSelNotes(take, -1) ~= -1

				if notesSelected then
					takeCntSelNotes = takeCntSelNotes + 1
				end

				-- Store all relevant data into takes table
				takeTbl[i + 1] = {
					take = take,
					notesSelected = notesSelected,
				}
			else
				break
			end
		end

		-- Set Arrange to MIDI grid and backup. With multiple takes in the MIDI editor, it's sufficient to retrieve the grid
		-- from the  first take (take_tbl[1]).take), since all takes share the same grid.
		local gridSync, midiGrid, midiSwing, midiSwingAmt, arrGrid, arrSwing, arrSwingAmt, gridVisLinked, gridMinimum, gridMinChanged =
			SetMIDIEditorGrid(takeTbl[1].take)

		-- Process all takes in table
		for i = 1, #takeTbl do
			if
				takeCntSelNotes == 0 -- no selected notes in all takes? Move all notes
				or takeTbl[i].notesSelected -- selected notes in at least 1 take? Move selected notes only
			then
				Quantize(takeTbl[i].take, takeTbl[i].notesSelected)
			end
		end

		RestoreMIDIEditorGrid(
			gridSync,
			midiGrid,
			midiSwing,
			midiSwingAmt,
			arrGrid,
			arrSwing,
			arrSwingAmt,
			gridVisLinked,
			gridMinimum,
			gridMinChanged
		)
	end

	local function ProcessInlineEditor()
		local take = reaper.BR_GetMouseCursorContext_Take() -- get take from mouse
		local item = reaper.GetMediaItemTake_Item(take)
		local notesSelected = mu.MIDI_EnumSelNotes(take, -1) ~= -1

		local arrGrid, arrSwing, arrSwingAmt, gridLinked, gridMinimum, gridMinChanged = SetArrangeGrid()

		if ItemModifiable(item, take) then
			Quantize(take, notesSelected)
		end
		RestoreArrangeGrid(arrGrid, arrSwing, arrSwingAmt, gridLinked, gridMinimum, gridMinChanged)
	end

	local function ProcessArrange()
		local itemCnt = reaper.CountSelectedMediaItems(0)

		if itemCnt ~= 0 then
			local arrGrid, arrSwing, arrSwingAmt, gridLinked, gridMinimum, gridMinChanged = SetArrangeGrid()

			for i = 0, itemCnt - 1 do -- loop through all selected items
				local item = reaper.GetSelectedMediaItem(0, i) -- get current selected item
				local take = reaper.GetActiveTake(item) -- get take of item

				-- Ignore note selection by using "-1"
				if ItemModifiable(item, take) then
					Quantize(take, false)
				end
			end
			RestoreArrangeGrid(arrGrid, arrSwing, arrSwingAmt, gridLinked, gridMinimum, gridMinChanged)
		else
			reaper.ShowMessageBox("Please select at least one item", "Error", 0)
			return false
		end
	end

	local function ProcessRazorSelection(razorItems)
		local tblLen = #razorItems

		local arrGrid, arrSwing, arrSwingAmt, gridLinked, gridMinimum, gridMinChanged = SetArrangeGrid()

		-- Iterate thru the razor items table
		for t = 1, tblLen do
			local take, razorLeft, razorRight = razorItems[t].take, razorItems[t].razorLeft, razorItems[t].razorRight
			QuantizeRazorSelection(take, razorLeft, razorRight)
		end
		RestoreArrangeGrid(arrGrid, arrSwing, arrSwingAmt, gridLinked, gridMinimum, gridMinChanged)
	end

	--  ╔══════════════════════════════════════════════════════════════════════════════════════════════════╗
	--  ║                                               Main                                               ║
	--  ╚══════════════════════════════════════════════════════════════════════════════════════════════════╝

	local function Main()
		local window, _, _ = reaper.BR_GetMouseCursorContext() -- initialize cursor context
		local _, inlineEditor, _, _, _, _ = reaper.BR_GetMouseCursorContext_MIDI() -- check if mouse hovers an inline editor

		reaper.PreventUIRefresh(1)

		if window == "midi_editor" then
			-- MIDI editor focused
			if not inlineEditor then
				ProcessMIDIEditor()

			-- Inline Editor focused
			else
				ProcessInlineEditor()
			end
		else
			local razorTakes = GetRazorTakes()
			if razorTakes then -- if table has elements (=not false)
				ProcessRazorSelection(razorTakes)
			else
				ProcessArrange()
			end
		end

		reaper.PreventUIRefresh(-1)
		reaper.UpdateArrange()
	end

	Main()
end

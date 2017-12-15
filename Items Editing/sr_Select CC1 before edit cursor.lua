-- @description Select CC1 before edit cursor
-- @version 1.0
-- @author Stephan Römer
-- @about
--    # Description
--    - this script selects the CC1 data before the edit cursor
--    - this script works in arrangement, MIDI Editor and Inline Editor
--
-- @link https://forums.cockos.com/showthread.php?p=1923923
--
-- @changelog
--     + Initial release


for i = 0, reaper.CountSelectedMediaItems(0)-1 do -- loop through all selected items
    item = reaper.GetSelectedMediaItem(0, i)
    for t = 0, reaper.CountTakes(item)-1 do -- Loop through all takes within each selected item
        take = reaper.GetTake(item, t)
        if reaper.TakeIsMIDI(take) then -- make sure, that take is MIDI
			cursor_position = reaper.GetCursorPosition()  -- get edit cursor position 
            cursor_position_ppq = reaper.MIDI_GetPPQPosFromProjTime(take, cursor_position) -- convert to PPQ
            _, _, ccCount, _ = reaper.MIDI_CountEvts(take) -- count CCs and save amount to "ccCount"
            for c = 0, ccCount - 1 do -- loop thru all CCs
                _, _, _, ppqposOut, _, _, cc, _ = reaper.MIDI_GetCC(take, c) -- get values from CCs
                if cc == 1 and ppqposOut < cursor_position_ppq then -- if CC is CC1
					reaper.MIDI_SetCC(take, c, true, nil, nil, nil, nil, nil, nil, true) -- select CC1
                elseif cc == 1 then -- if CC1 is after edit cursor
					reaper.MIDI_SetCC(take, c, false, nil, nil, nil, nil, nil, nil, true) -- unselect CC1
				end
            end
        end
    end
end





-- @description sr_Delete all CCs before edit cursor
-- @version 1.0
-- @author Stephan Römer
-- @about
--    # Description
--    - this script deletes the data of all CC lanes before the edit cursor
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
            for c = ccCount - 1, 0, -1 do -- loop thru all CCs, back to forth
                _, _, _, ppqposOut, _, _, _, _ = reaper.MIDI_GetCC(take, c) -- get position from CCs
                if ppqposOut < cursor_position_ppq then -- if CC position is before cursor position
					reaper.MIDI_DeleteCC(take, c) -- delete CCs
                end
            end
        end
    end
end




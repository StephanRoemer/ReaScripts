-- @description sr_Delete CC64 after edit cursor
-- @version 1.0
-- @author Stephan Römer
-- @about
--    # Description
--    - this script deletes the CC64 (sustain) data after the edit cursor
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
                _, _, _, ppqposOut, _, _, cc, _ = reaper.MIDI_GetCC(take, c) -- get values from CCs
                if cc == 64 and ppqposOut >= cursor_position_ppq then -- if CC is CC64
					reaper.MIDI_DeleteCC(take, c) -- delete CC64
                end
            end
        end
    end
end




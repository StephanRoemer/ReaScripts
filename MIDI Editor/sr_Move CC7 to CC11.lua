-- @description sr_Move CC7 to CC11
-- @version 1.0
-- @author Stephan Römer
-- @about
--    # Description
--    - this script moves CC7 data to CC11
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
            _, _, ccCount, _ = reaper.MIDI_CountEvts(take) -- count CCs and save amount to "ccCount"
            for c = 0, ccCount - 1 do -- loop thru all CCs
                _, _, _, ppqposOut, chanmsgOut, chanOut, cc, ccValue = reaper.MIDI_GetCC(take, c) -- get values from CCs
                if cc == 7 then -- if CC is CC7
                  reaper.MIDI_InsertCC(take, false, false, ppqposOut, chanmsgOut, chanOut, 11, ccValue) -- insert CC7 values into CC11 lane
                  reaper.MIDI_DeleteCC(take, c) -- after copying CC7 to CC11, delete CC7 (=move)
                end
            end
        end
    end
end





-- @description Move CC1 to CC11
-- @version 1.0    
-- @author Stephan Römer
-- @about
--    # Description
--    - this script moves CC1 data to CC11
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
            _, _, cc_count, _ = reaper.MIDI_CountEvts(take) -- count CCs and save amount to "cc_count"
            for c = 0, cc_count - 1 do -- loop thru all CCs, 2*cc_count is needed, when CC is copied, because amount of CC doubles!
                _, _, _, ppqposOut, chanmsgOut, chanOut, cc, ccValue = reaper.MIDI_GetCC(take, c) -- get values from CCs
                if cc == 11 and ppqposOut >= cursor_position_ppq then -- if CC is CC1
					reaper.MIDI_SetCC(take, c, true, nil, nil, nil, nil, nil, nil, true) -- select
                else 
					reaper.MIDI_SetCC(take, c, false, nil, nil, nil, nil, nil, nil, true) -- select                 
                end   
            end
        end
    end
end




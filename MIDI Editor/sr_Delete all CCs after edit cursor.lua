-- @description Delete all CCs after edit cursor
-- @version 1.0
-- @author Stephan Römer
-- @about
--    # Description
--    - this script deletes the data of all CC lanes after the edit cursor
--    - this script works in arrangement, MIDI Editor and Inline Editor
--
-- @link https://forums.cockos.com/showthread.php?p=1923923
--
-- @provides [main=main,midi_editor,midi_inlineeditor] .
-- @changelog
--     v1.1 (2017-12-16)
--     + added undo state
--     v1.0
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
                if ppqposOut >= cursor_position_ppq then -- if CC position is beyond/equal cursor position
					reaper.MIDI_DeleteCC(take, c) -- delete CCs
                end
            end
        end
    end
end

reaper.Undo_OnStateChange2(proj, "Delete all CCs after edit cursor")



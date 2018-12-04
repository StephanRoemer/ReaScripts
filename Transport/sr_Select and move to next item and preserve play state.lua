-- @description Select and move to next item and preserve play state
-- @version 1.0
-- @changelog
--   initial release
-- @author Stephan Römer
-- @provides [main=main] .
-- @about
--    # Description
--    * This script moves the edit cursor to the start of the next item
--    * If the edit cursor is moved, while playback is on, the playback continues
--    * This script works only in the Arrangement
-- @link https://forums.cockos.com/showthread.php?p=1923923

reaper.Main_OnCommandEx(40417, 0, 0) -- Item navigation: Select and move to next item

if reaper.GetPlayState() == 1 then -- if playback is on
    reaper.OnPlayButton() -- press play to move the play cursor to the edit cursor
end




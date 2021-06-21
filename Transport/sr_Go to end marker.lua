-- @description Go to end marker
-- @version 1.1
-- @changelog
--  + Code optimizations
-- @author Stephan Römer
-- @link https://forums.cockos.com/showthread.php?p=1923923
-- @provides [main] .
-- @about
--    # Description
--    * This script puts the edit / play cursor to the marker named "=END"
--    * I use this in conjunction with "X-Raym_Insert or update start and end marker from time selection.lua" to create the project boundaries
--    or my own script "sr_Set start and end marker to items in project.lua" (both available via ReaPack)
--    * This script works only in the arrangement


local marker_num = reaper.CountProjectMarkers(0)

for i=0, marker_num-1 do
    local _, _, pos, _, name, _ = reaper.EnumProjectMarkers(i)
    if name == "=END" then
        reaper.SetEditCurPos(pos, true, false)
    end
end

if reaper.GetPlayState() == 1 then -- if playback is on
    reaper.OnPlayButton() -- press play to move the play cursor to the edit cursor
end

reaper.UpdateArrange()

function NoUndoPoint() end 
reaper.defer(NoUndoPoint)

-- @description Go to start marker
-- @version 1.0
-- @changelog
--   initial release
-- @author Stephan Römer
-- @provides [main=main] .
-- @about
--    # Description
--    * This script puts the edit / play cursor to the marker named "=START"
--    * I use this in conjunction with "X-Raym_Insert or update start and end marker from time selection.lua" to create the project boundaries
--    * This script works only in the arrangement
-- @link https://forums.cockos.com/showthread.php?p=1923923


marker_num = reaper.CountProjectMarkers(0)

for i=0, marker_num-1 do
    _, _, pos, _, name, _ = reaper.EnumProjectMarkers(i)
    if name == "=START" then
        reaper.GoToMarker(0, i+1, true)
    end
end

reaper.UpdateArrange()

function NoUndoPoint() end 
reaper.defer(NoUndoPoint)

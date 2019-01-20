-- @description Zoom to start and end marker
-- @version 1.0
-- @changelog
--   initial release
-- @author Stephan Römer
-- @provides [main=main] .
-- @about
--    # Description
--    * This script zooms in between the boundaries of the start and end marker
--    * I use this in conjunction with "X-Raym_Insert or update start and end marker from time selection.lua" to create the project boundaries
--    * To undo the zoom, use "View: Restore previous zoom level"
--    * This script works only in the arrangement
-- @link https://forums.cockos.com/showthread.php?p=1923923


reaper.Undo_BeginBlock()

marker_num = reaper.CountProjectMarkers(0)

for i=0, marker_num-1 do
    _, _, pos, _, name, _ = reaper.EnumProjectMarkers(i)
    if name == "=START" then
        startpos = pos
    elseif name == "=END" then
        endpos = pos
    end
end

reaper.GetSet_ArrangeView2(0, true, 0, 0, startpos-1, endpos+1)
reaper.UpdateArrange()

reaper.Undo_EndBlock("Zoom to start and end marker", -1)

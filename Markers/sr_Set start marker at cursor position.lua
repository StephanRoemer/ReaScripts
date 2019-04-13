-- @description Set start marker at cursor position
-- @version 1.0
-- @changelog
--   initial release
-- @author Stephan Römer
-- @provides [main=main] .
-- @about
--    # Description
--    * This script sets the start marker to the current edit cursor position
--    * This script works only in the arrangement
-- @link https://forums.cockos.com/showthread.php?p=1923923


local cursor_pos = reaper.GetCursorPosition()
local marker_count = reaper.CountProjectMarkers(0)

for m = 0, marker_count-1 do
    _, _, _, _, name, marker_id = reaper.EnumProjectMarkers(m)
    
    if name == "=START" then
        marker_exists = 1
        break
    end
end
   

reaper.Undo_BeginBlock2(0)

if marker_exists then
    -- reaper.SetProjectMarker(integer markrgnindexnumber, boolean isrgn, number pos, number rgnend, string name)
    reaper.SetProjectMarker(marker_id, false, cursor_pos, 0, "=START")
else
    reaper.AddProjectMarker(0, false, cursor_pos, 0, "=START", -1)
end

reaper.Undo_EndBlock2(0, "Set start marker at cursor position", -1)

reaper.UpdateArrange()
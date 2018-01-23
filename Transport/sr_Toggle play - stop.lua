-- @description Toggle play / stop
-- @version 1.0
-- @author Stephan Römer
-- @about
--    # Description
--    - this script toggles between play and stop and mimics the Cubase transport behavior of the space bar
--    - no undo will be created for this script
--
-- @link https://forums.cockos.com/showthread.php?p=1923923
--
-- @provides [main] .
-- @changelog
--     v1.0 (2018-01-23)
--     + Initial release

function NoUndoPoint() end 

playstate = reaper.GetPlayState() -- get play state of the transport
if playstate > 0 then -- when play state is greater 0 (play, pause, record)
	reaper.Main_OnCommand(40434, 0) -- View: Move edit cursor to play cursor
	reaper.Main_OnCommand(1016, 0) -- Transport: Stop
else 
	reaper.Main_OnCommand(1007, 0) -- Transport: Play
end

reaper.defer(NoUndoPoint)
-- @description Stop / return to last cursor positions
-- @version 1.0
-- @author Stephan Römer
-- @about
--    # Description
--    - this script either stops the playback (when transport is playing) or returns to the last cursor positions (when transport is stopped)
--    and mimics the Cubase behavior of the 0 NumPad key
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
	reaper.Main_OnCommand(reaper.NamedCommandLookup("_SWS_EDITCURUNDO"), 0) -- Undo edit cursor move
end

reaper.defer(NoUndoPoint)
-- @description Move edit cursor by frames (mousewheel)
-- @version 1.0
-- @author Stephan Römer
-- @about
--    # Description
--    - this script moves the edit cursor by frames depending on the value sent by the mousewheel.
--
-- @link https://forums.cockos.com/showthread.php?p=1923923
--
-- @provides [main] .
-- @changelog
--     v1.0 (2018-06-20)
--     + Initial release

function NoUndoPoint() end

_,_,_,_,_,_,val = reaper.get_action_context()

if val > 0 then
	reaper.ApplyNudge(0, -- project
					  2, -- snap
					  6, -- edit cursor
					  18, -- frames
					  1, -- amount
					  0, -- move right
					  0) -- no copies

else 
	reaper.ApplyNudge(0, -- project
					  2, -- snap
					  6, -- edit cursor
					  18, -- frames
					  1, -- amount
					  1, -- move left
					  0) -- no copies
end

reaper.defer(NoUndoPoint)
-- @noindex

package.path = debug.getinfo(1,"S").source:match[[^@?(.*[\/])[^\/]-$]] .."?.lua;".. package.path
require 'sr_Nudge notes function'

newPosition = -10 -- ticks

NudgeNotes(new_position) -- call function
reaper.Undo_OnStateChange2(proj, "Nudge notes left by 10 ticks")
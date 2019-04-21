-- @noindex

package.path = debug.getinfo(1,"S").source:match[[^@?(.*[\/])[^\/]-$]] .."?.lua;".. package.path
require 'sr_Nudge notes function'

local new_position = 10 -- ticks

NudgeNotes(new_position) -- call function
reaper.Undo_OnStateChange2(proj, "Nudge notes right by 10 ticks")
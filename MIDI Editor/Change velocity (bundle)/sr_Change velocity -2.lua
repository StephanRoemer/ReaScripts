-- @noindex

package.path = debug.getinfo(1,"S").source:match[[^@?(.*[\/])[^\/]-$]] .."?.lua;".. package.path
require 'sr_Change velocity function'

local new_velocity = -2

ChangeVelocity(new_velocity) -- call function
reaper.Undo_OnStateChange2(proj, "Change velocity -2")
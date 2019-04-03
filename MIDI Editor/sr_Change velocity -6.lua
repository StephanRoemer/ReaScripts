-- @noindex

package.path = debug.getinfo(1,"S").source:match[[^@?(.*[\/])[^\/]-$]] .."?.lua;".. package.path
require 'sr_Change velocity function'

new_velocity = -6

ChangeVelocity(new_velocity) -- call function
reaper.Undo_OnStateChange2(proj, "Change velocity -6")

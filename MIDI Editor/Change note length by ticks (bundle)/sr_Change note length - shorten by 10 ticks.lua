-- @noindex

package.path = debug.getinfo(1,"S").source:match[[^@?(.*[\/])[^\/]-$]] .."?.lua;".. package.path
require 'sr_Change note length by ticks function'

new_length = -10 -- ticks

ChangeNoteLength(new_length) -- call function
reaper.Undo_OnStateChange2(proj, "Change note length - shorten by 10 ticks")

-- @noindex

package.path = debug.getinfo(1,"S").source:match[[^@?(.*[\/])[^\/]-$]] .."?.lua;".. package.path
require 'sr_Transpose notes function'

interval = 1 -- semitones

transpose(interval) -- call function
reaper.Undo_OnStateChange2(proj, "Transpose notes 1")
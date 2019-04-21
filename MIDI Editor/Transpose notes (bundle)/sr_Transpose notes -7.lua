-- @noindex

package.path = debug.getinfo(1,"S").source:match[[^@?(.*[\/])[^\/]-$]] .."?.lua;".. package.path
require 'sr_Transpose notes function'

local interval = -7 -- semitones

Transpose(interval) -- call function
reaper.Undo_OnStateChange2(proj, "Transpose notes -7")
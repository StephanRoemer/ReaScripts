-- @noindex

package.path = debug.getinfo(1,"S").source:match[[^@?(.*[\/])[^\/]-$]] .."?.lua;".. package.path
require 'sr_MIDI functions'

interval = 9 -- semitones

transpose(interval) -- call function
reaper.Undo_OnStateChange2(proj, "Transpose notes 9")
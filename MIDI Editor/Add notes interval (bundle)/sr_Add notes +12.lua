--  @noindex

package.path = debug.getinfo(1,"S").source:match[[^@?(.*[\/])[^\/]-$]] .."?.lua;".. package.path
require 'sr_Add notes interval function'

local interval = 12 -- semitones

AddNotesInterval(interval) -- call function
reaper.Undo_OnStateChange2(proj, "Add notes +12")
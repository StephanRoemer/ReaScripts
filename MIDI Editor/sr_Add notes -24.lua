--  @noindex

package.path = debug.getinfo(1,"S").source:match[[^@?(.*[\/])[^\/]-$]] .."?.lua;".. package.path
require 'sr_Add notes interval function'

interval = -24 -- semitones

Add_Notes_Interval(interval) -- call function
reaper.Undo_OnStateChange2(proj, "Add notes -24")
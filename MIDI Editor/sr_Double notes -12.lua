--  @noindex

package.path = debug.getinfo(1,"S").source:match[[^@?(.*[\/])[^\/]-$]] .."?.lua;".. package.path
require 'sr_Double notes function'

interval = -12 -- semitones

double_notes(interval) -- call function
reaper.Undo_OnStateChange2(proj, "Add notes -12")
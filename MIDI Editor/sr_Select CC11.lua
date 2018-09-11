--  @noindex

package.path = debug.getinfo(1,"S").source:match[[^@?(.*[\/])[^\/]-$]] .."?.lua;".. package.path
require 'sr_Select CC function'

destCC = 11 -- CC

SelectCC(dest_cc) -- call function
reaper.Undo_OnStateChange2(proj, "Select CC11")



--  @noindex

package.path = debug.getinfo(1,"S").source:match[[^@?(.*[\/])[^\/]-$]] .."?.lua;".. package.path
require 'sr_Select CC before edit cursor function'

dest_cc = 7 -- CC

SelectCCBeforeEditCursor(dest_cc) -- call function
reaper.Undo_OnStateChange2(proj, "Select CC7 before edit cursor")
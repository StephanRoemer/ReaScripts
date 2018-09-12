--  @noindex

package.path = debug.getinfo(1,"S").source:match[[^@?(.*[\/])[^\/]-$]] .."?.lua;".. package.path
require 'sr_Select CC after edit cursor function'

dest_cc = 1 -- CC

SelectCCAfterEditCursor(dest_cc) -- call function
reaper.Undo_OnStateChange2(proj, "Select CC1 after edit cursor")
--  @noindex

package.path = debug.getinfo(1,"S").source:match[[^@?(.*[\/])[^\/]-$]] .."?.lua;".. package.path
require 'sr_Select CC after edit cursor function'

local dest_cc = 2 -- CC

SelectCCAfterEditCursor(dest_cc) -- call function
reaper.Undo_OnStateChange2(proj, "Select CC2 after edit cursor")
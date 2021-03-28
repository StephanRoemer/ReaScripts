--  @noindex

package.path = debug.getinfo(1,"S").source:match[[^@?(.*[\/])[^\/]-$]] .."?.lua;".. package.path
require 'sr_Select CC before edit cursor function'

local dest_cc = 64 -- CC

SelectCCBeforeEditCursor(dest_cc) -- call function
reaper.Undo_OnStateChange2(proj, "Select CC" .. dest_cc .. " before edit cursor")
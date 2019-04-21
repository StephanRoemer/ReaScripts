--  @noindex

package.path = debug.getinfo(1,"S").source:match[[^@?(.*[\/])[^\/]-$]] .."?.lua;".. package.path
require 'sr_Delete CC before edit cursor function'

local dest_cc = 1 -- destination CC

DeleteCCBeforeEditCursor(dest_cc) -- call function
reaper.Undo_OnStateChange2(proj, "Delete CC1 before edit cursor")


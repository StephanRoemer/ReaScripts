--  @noindex

package.path = debug.getinfo(1,"S").source:match[[^@?(.*[\/])[^\/]-$]] .."?.lua;".. package.path
require 'sr_Delete CC function'

local dest_cc = 1 -- CC

DeleteCC(dest_cc) -- call function
reaper.Undo_OnStateChange2(proj, "Delete CC1")




--  @noindex

package.path = debug.getinfo(1,"S").source:match[[^@?(.*[\/])[^\/]-$]] .."?.lua;".. package.path
require 'sr_Copy CC to CC function'

local src_cc = 11 -- source CC
local dest_cc = 7 -- destination CC

CopySrcCCToDestCC(src_cc, dest_cc) -- call function
reaper.Undo_OnStateChange2(proj, "Copy CC11 to CC7")
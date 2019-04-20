--  @noindex

package.path = debug.getinfo(1,"S").source:match[[^@?(.*[\/])[^\/]-$]] .."?.lua;".. package.path
require 'sr_Move CC to CC function'

local src_cc = 7 -- source CC
local dest_cc = 11 -- destination CC

MoveSrcCCToDestCC(src_cc, dest_cc) -- call function
reaper.Undo_OnStateChange2(proj, "Move CC7 to CC11")
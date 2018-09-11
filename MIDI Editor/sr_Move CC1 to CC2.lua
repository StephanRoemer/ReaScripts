--  @noindex

package.path = debug.getinfo(1,"S").source:match[[^@?(.*[\/])[^\/]-$]] .."?.lua;".. package.path
require 'sr_Move CC to CC function'

src_cc = 1 -- source CC
dest_cc = 2 -- destination CC

MoveSrcCCToDestCC(src_cc, dest_cc) -- call function
reaper.Undo_OnStateChange2(proj, "Move CC1 to CC2")



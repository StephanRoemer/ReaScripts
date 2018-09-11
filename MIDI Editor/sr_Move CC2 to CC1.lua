--  @noindex

package.path = debug.getinfo(1,"S").source:match[[^@?(.*[\/])[^\/]-$]] .."?.lua;".. package.path
require 'sr_Move CC to CC function'

src_cc = 2 -- source CC
dest_cc = 1 -- destination CC

MoveSrcCCToDestCC(src_cc, dest_cc) -- call function
reaper.Undo_OnStateChange2(proj, "Move CC2 to CC1")
--  @noindex

package.path = debug.getinfo(1,"S").source:match[[^@?(.*[\/])[^\/]-$]] .."?.lua;".. package.path
require 'sr_Copy CC to CC function'

src_cc = 7 -- source CC
dest_cc = 2 -- destination CC

CopySrcCCToDestCC(src_cc, dest_cc) -- call function
reaper.Undo_OnStateChange2(proj, "Copy CC7 to CC2")
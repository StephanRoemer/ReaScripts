--  @noindex

package.path = debug.getinfo(1,"S").source:match[[^@?(.*[\/])[^\/]-$]] .."?.lua;".. package.path
require 'sr_Increase CC function'

decrease = 1.1 -- value to decrease the CC event
dest_cc = 2 -- destination CC

DecreaseCC(dest_cc, decrease) -- call function
reaper.Undo_OnStateChange2(proj, "Decrease CC2")
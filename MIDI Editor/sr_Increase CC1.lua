--  @noindex

package.path = debug.getinfo(1,"S").source:match[[^@?(.*[\/])[^\/]-$]] .."?.lua;".. package.path
require 'sr_Increase CC function'

increase = 1.1 -- value to increase the CC event
dest_cc = 1 -- destination CC

IncreaseCC(dest_cc, increase) -- call function
reaper.Undo_OnStateChange2(proj, "Increase CC1")
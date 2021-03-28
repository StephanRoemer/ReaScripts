--  @noindex

package.path = debug.getinfo(1,"S").source:match[[^@?(.*[\/])[^\/]-$]] .."?.lua;".. package.path
require 'sr_Decrease CC function'

local decrease = 1.1 -- value to decrease the CC event
local dest_cc = 7 -- destination CC

DecreaseCC(dest_cc, decrease) -- call function
reaper.Undo_OnStateChange2(proj, "Decrease CC" .. dest_cc)
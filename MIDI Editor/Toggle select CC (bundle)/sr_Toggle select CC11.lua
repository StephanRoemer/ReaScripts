--  @noindex

package.path = debug.getinfo(1,"S").source:match[[^@?(.*[\/])[^\/]-$]] .."?.lua;".. package.path
require 'sr_Toggle select CC function'

local dest_cc = 11 -- CC

ToggleSelectCC(dest_cc) -- call function
reaper.Undo_OnStateChange2(proj, "Toggle select CC" .. dest_cc)
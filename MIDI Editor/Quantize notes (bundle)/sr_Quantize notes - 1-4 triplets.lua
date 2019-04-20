--  @noindex

package.path = debug.getinfo(1,"S").source:match[[^@?(.*[\/])[^\/]-$]] .."?.lua;".. package.path
require 'sr_Quantize notes function'

local grid = 1/6 -- 1/16 triplets grid
local swing = 0 -- swing off
local swing_amt = 0 -- swing amount

_, save_project_grid, save_swing, save_swing_amt = reaper.GetSetProjectGrid(proj, false) -- backup current grid settings
reaper.GetSetProjectGrid(proj, true, grid, swing, swing_amt) -- set new grid settings according variable grid, swing and swing_amt
Quantize() -- call function
reaper.GetSetProjectGrid(proj, true, save_project_grid, save_swing, save_swing_amt) -- restore saved grid settings
reaper.Undo_OnStateChange2(proj, "Quantize notes - 1/4 triplets")
--  @noindex

package.path = debug.getinfo(1,"S").source:match[[^@?(.*[\/])[^\/]-$]] .."?.lua;".. package.path
require 'sr_Quantize notes function'

-- ================================================================================================================== --
--                                               User Configuration Area                                              --
-- ================================================================================================================== --

-- Set your prefered values here and save this script under a different name.

local use_cur_grid = false  -- use custom values for grid
local grid = 1/24           -- 1/24 grid
local swing = 0             -- swing off
local swing_amt = 0         -- swing amount
local strength = 50         -- strength value in percent
local undo_text = "Quantize notes 50% - 1/16 triplets"


-- ================================================================================================================== --
--                                                   Code Execution                                                   --
-- ================================================================================================================== --

Quantize(grid, swing, swing_amt, strength, use_cur_grid) -- call function
reaper.Undo_OnStateChange2(proj, undo_text)

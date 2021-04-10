--  @noindex

package.path = debug.getinfo(1,"S").source:match[[^@?(.*[\/])[^\/]-$]] .."?.lua;".. package.path
require 'sr_Quantize notes function'

-- ================================================================================================================== --
--                                               User Configuration Area                                              --
-- ================================================================================================================== --

-- Set your prefered values here and save this script under a different name.

local grid = 1/4        -- 1/4 grid
local swing = 1         -- swing off
local swing_amt = 0.7   -- swing amount
local strength = 50     -- strength value in percent
local undo_text = "Quantize notes 50% - 1/4 - swing 70%"


-- ================================================================================================================== --
--                                                   Code Execution                                                   --
-- ================================================================================================================== --

Quantize(grid, swing, swing_amt, strength) -- call function
reaper.Undo_OnStateChange2(proj, undo_text)
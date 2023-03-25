--  @noindex

package.path = debug.getinfo(1, "S").source:match([[^@?(.*[\/])[^\/]-$]]) .. "?.lua;" .. package.path
require("sr_Quantize notes function")

--  ╔══════════════════════════════════════════════════════════════════════════════════════════════════╗
--  ║                                     User Configuration Area                                      ║
--  ╚══════════════════════════════════════════════════════════════════════════════════════════════════╝

-- Set your prefered values here and save this script under a different name.

local useCurGrid = false -- use custom values for grid
local grid = 1 / 6 -- 1/4 triplets grid
local swing = 0 -- swing off
local swingAmt = 0 -- swing amount
local strength = 100 -- strength value in percent
local undoText = "Quantize notes 100% - 1/4 triplets"

--  ╔══════════════════════════════════════════════════════════════════════════════════════════════════╗
--  ║                                          Code Execution                                          ║
--  ╚══════════════════════════════════════════════════════════════════════════════════════════════════╝

Quantize(grid, swing, swingAmt, strength, useCurGrid) -- call function
reaper.Undo_OnStateChange2(0, undoText)

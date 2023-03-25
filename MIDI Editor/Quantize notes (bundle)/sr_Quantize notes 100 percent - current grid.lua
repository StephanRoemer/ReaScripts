--  @noindex

package.path = debug.getinfo(1, "S").source:match([[^@?(.*[\/])[^\/]-$]]) .. "?.lua;" .. package.path
require("sr_Quantize notes function")

--  ╔══════════════════════════════════════════════════════════════════════════════════════════════════╗
--  ║                                     User Configuration Area                                      ║
--  ╚══════════════════════════════════════════════════════════════════════════════════════════════════╝

-- Set your prefered values here and save this script under a different name.

local useCurGrid = true -- use current grid
local strength = 100 -- strength value in percent
local undoText = "Quantize notes 100% - current grid"

--  ╔══════════════════════════════════════════════════════════════════════════════════════════════════╗
--  ║                                          Code Execution                                          ║
--  ╚══════════════════════════════════════════════════════════════════════════════════════════════════╝

Quantize(nil, nil, nil, strength, useCurGrid) -- call function
reaper.Undo_OnStateChange2(0, undoText)

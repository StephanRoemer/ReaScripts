--  @noindex

package.path = debug.getinfo(1,"S").source:match[[^@?(.*[\/])[^\/]-$]] .."?.lua;".. package.path
require 'sr_Quantize notes function'

-- ================================================================================================================== --
--                                               User Configuration Area                                              --
-- ================================================================================================================== --

-- Set your prefered values here and save this script under a different name.

local use_cur_grid = true   -- use current grid
local strength = 100        -- strength value in percent
local undo_text = "Quantize notes 100% - current grid"


-- ================================================================================================================== --
--                                                   Code Execution                                                   --
-- ================================================================================================================== --

Quantize(nil, nil, nil, strength, use_cur_grid) -- call function
reaper.Undo_OnStateChange2(proj, undo_text)

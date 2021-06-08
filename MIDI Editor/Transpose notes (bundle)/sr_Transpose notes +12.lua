-- @noindex

package.path = debug.getinfo(1,"S").source:match[[^@?(.*[\/])[^\/]-$]] .."?.lua;".. package.path
require 'sr_Transpose notes function'

-- ================================================================================================================== --
--                                               User Configuration Area                                              --
-- ================================================================================================================== --

-- Set your prefered values here and save this script under a different name.

local interval = 12 -- semitones
local undo_text = "Transpose notes +12"

-- ================================================================================================================== --
--                                                   Code Execution                                                   --
-- ================================================================================================================== --

Transpose(interval) -- call function
reaper.Undo_OnStateChange2(proj, undo_text)
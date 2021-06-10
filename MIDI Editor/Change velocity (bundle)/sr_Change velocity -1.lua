-- @noindex

package.path = debug.getinfo(1,"S").source:match[[^@?(.*[\/])[^\/]-$]] .."?.lua;".. package.path
require 'sr_Change velocity function'

-- ================================================================================================================== --
--                                               User Configuration Area                                              --
-- ================================================================================================================== --

-- Set your prefered value here and save this script under a different name. You should also change the undo text 

local velocity_val = -1
local undo_text = "Change velocity -1"

-- ================================================================================================================== --
--                                                   Code Execution                                                   --
-- ================================================================================================================== --

ChangeVelocity(velocity_val) -- call function
reaper.Undo_OnStateChange2(proj, undo_text)
-- @noindex

package.path = debug.getinfo(1,"S").source:match[[^@?(.*[\/])[^\/]-$]] .."?.lua;".. package.path
require 'sr_Change note length by ticks function'

-- ================================================================================================================== --
--                                               User Configuration Area                                              --
-- ================================================================================================================== --

-- Set your prefered value here and save this script under a different name

new_length = 10 -- ticks

-- ================================================================================================================== --
--                                                   Code Execution                                                   --
-- ================================================================================================================== --

ChangeNoteLength(new_length) -- call function
reaper.Undo_OnStateChange2(proj, "Change note length - lengthen by 10 ticks")
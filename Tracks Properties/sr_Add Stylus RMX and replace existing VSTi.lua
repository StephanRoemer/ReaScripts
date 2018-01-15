-- @description Add Stylus RMX and replace existing VSTi
-- @version 1.0
-- @author Stephan Römer
-- @about
--    # Description
--    - this script adds a Stylus RMX instance in FX slot 1
--    - if there is already a VSTi, it will be replaced by this one
--	  - if there is no VSTi, this one will be added in FX slot 1. Existing insert FX will be moved down by one slot
--    - after loading the VSTi, the floating GUI will be shown
-- 	  - in order to function correctly, the script expects only 1 VSTi on a track
--
-- @link https://forums.cockos.com/showthread.php?p=1923923
--
-- @provides [main=main] .
-- @changelog
--     v1.0 (2018-01-15)
--     + Initial release

package.path = debug.getinfo(1,"S").source:match[[^@?(.*[\/])[^\/]-$]] .."?.lua;".. package.path
require 'sr_Add or replace VSTi'

VSTi = "StylusRMX (Spectrasonics) (16 out)" -- VSTi identifier
pluginName = "Stylus RMX" -- plugin name


reaper.Undo_BeginBlock()

addInstrument(VSTi, pluginName) -- call function

reaper.Undo_EndBlock("Add".." "..pluginName, 0)
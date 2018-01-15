-- @description Add Engine 2 and replace existing VSTi
-- @version 1.0
-- @author Stephan Römer
-- @about
--    # Description
--    - this script adds a Engine 2 instance in FX slot 1
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

VSTi = "ENGINE (Best Service) (24 out)" -- VSTi identifier
pluginName = "Engine 2" -- plugin name


reaper.Undo_BeginBlock()

addInstrument(VSTi, pluginName) -- call function

reaper.Undo_EndBlock("Add".." "..pluginName, 0)
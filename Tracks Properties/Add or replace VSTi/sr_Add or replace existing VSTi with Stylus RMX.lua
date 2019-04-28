package.path = debug.getinfo(1,"S").source:match[[^@?(.*[\/])[^\/]-$]] .."?.lua;".. package.path
require 'sr_Add or replace VSTi function'

vsti = "StylusRMX (Spectrasonics) (16 out)" -- VSTi identifier
plugin_name = "Stylus RMX" -- plugin name


reaper.Undo_BeginBlock()

local replaced = AddInstrument(vsti, plugin_name) -- call function an get replaced variable, relevant for undo text

if replaced then
    undo_text = "Replace existing VSTi with "
else
    undo_text = "Add "
end

reaper.Undo_EndBlock(undo_text..plugin_name, 0)
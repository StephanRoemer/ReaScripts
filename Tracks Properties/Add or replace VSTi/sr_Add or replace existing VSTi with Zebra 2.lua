-- @noindex

package.path = debug.getinfo(1,"S").source:match[[^@?(.*[\/])[^\/]-$]] .."?.lua;".. package.path
require 'sr_Add or replace VSTi function'

local vsti = "Zebra2 (u-he)" -- VSTi identifier
local track_name = "Zebra 2" -- new track name


reaper.Undo_BeginBlock()

local replaced = AddInstrument(vsti, track_name) -- call function an get replaced variable, relevant for undo text

if replaced then
    undo_text = "Replace existing VSTi with "
else
    undo_text = "Add "
end

reaper.Undo_EndBlock(undo_text..track_name, 1)

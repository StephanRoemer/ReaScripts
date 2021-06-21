-- @noindex

package.path = debug.getinfo(1,"S").source:match[[^@?(.*[\/])[^\/]-$]] .."?.lua;".. package.path
require 'sr_Add or replace VSTi function'

local vsti = "Vienna Synchron Player (VSL) (18 out)" -- VSTi identifier
local track_name = "Synchron Player" -- new track name


reaper.Undo_BeginBlock()

local replaced = AddInstrument(vsti, track_name) -- call function an get replaced variable, relevant for undo text

if replaced then
    undo_text = "Replace existing VSTi with "
else
    undo_text = "Add "
end

reaper.Undo_EndBlock(undo_text..track_name, 1)

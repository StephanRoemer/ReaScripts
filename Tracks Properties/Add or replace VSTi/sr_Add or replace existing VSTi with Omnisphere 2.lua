-- @noindex

package.path = debug.getinfo(1, "S").source:match([[^@?(.*[\/])[^\/]-$]]) .. "?.lua;" .. package.path
require("sr_Add or replace VSTi function")

local vsti = "Omnisphere (Spectrasonics) (18 out)" -- VSTi identifier
local track_name = "Omnisphere 2" -- new track name

reaper.Undo_BeginBlock()

AddInstrument(vsti, track_name) -- call function an get replaced variable, relevant for undo text

local undo_text = "Add "

reaper.Undo_EndBlock(undo_text .. track_name, 2)

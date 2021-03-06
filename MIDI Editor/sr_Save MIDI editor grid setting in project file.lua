-- @description Save MIDI editor grid setting in project file
-- @version 1.1
-- @changelog
--  + save the note length
-- @author Stephan Römer
-- @provides [main=midi_editor] .
-- @about
--    # Description
--    * This script stores the current MIDI grid setting in the project file.
--    * This script only works in the MIDI editor.
-- @link https://forums.cockos.com/showthread.php?p=1923923


local take = reaper.MIDIEditor_GetTake(reaper.MIDIEditor_GetActive()) -- get take from active MIDI editor
local grid, _, note_length = reaper.MIDI_GetGrid(take) -- get MIDI grid setting from take

reaper.SetProjExtState(0, "Save MIDI grid", "midi_grid", tostring(grid/4)) -- store grid setting in project file
reaper.SetProjExtState(0, "Save MIDI grid", "note_length", note_length) -- store note length in project file

reaper.defer(function() end) -- no undo point
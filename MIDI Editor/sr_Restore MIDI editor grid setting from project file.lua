-- @description Restore MIDI editor grid setting from project file
-- @version 1.0
-- @changelog
--  * initial release
-- @author Stephan Römer
-- @provides [midi_editor] .
-- @about
--    # Description
--    * This script restores the current MIDI grid setting from the project file.
--    * This script only works in the MIDI editor.
-- @link https://forums.cockos.com/showthread.php?p=1923923


local _, restore_grid = reaper.GetProjExtState(0, "Save MIDI grid", "midi_grid")
reaper.SetMIDIEditorGrid(0, tonumber(restore_grid))

reaper.defer(function() end) -- no undo point

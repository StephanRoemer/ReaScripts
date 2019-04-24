-- @description Restore MIDI editor grid setting from project file
-- @version 1.1
-- @changelog
--  + restore the note length
-- @author Stephan Römer
-- @provides [main=midi_editor] .
-- @about
--    # Description
--    * This script restores the current MIDI grid setting from the project file.
--    * This script only works in the MIDI editor.
-- @link https://forums.cockos.com/showthread.php?p=1923923


local _, restore_grid = reaper.GetProjExtState(0, "Save MIDI grid", "midi_grid")
local _, restore_note_length = reaper.GetProjExtState(0, "Save MIDI grid", "note_length")

reaper.SetMIDIEditorGrid(0, tonumber(restore_grid))

if restore_note_length == "0.0" then -- grid
    reaper.MIDIEditor_OnCommand(reaper.MIDIEditor_GetActive(), 41295)
elseif restore_note_length == "4.0" then -- 1/1
    reaper.MIDIEditor_OnCommand(reaper.MIDIEditor_GetActive(), 41081)
elseif restore_note_length == "2.0" then -- 1/2
    reaper.MIDIEditor_OnCommand(reaper.MIDIEditor_GetActive(), 41079)
elseif restore_note_length == "1.0" then -- 1/4
    reaper.MIDIEditor_OnCommand(reaper.MIDIEditor_GetActive(), 41076)
elseif restore_note_length == "0.5" then -- 1/8
    reaper.MIDIEditor_OnCommand(reaper.MIDIEditor_GetActive(), 41073)
elseif restore_note_length == "0.25" then -- 1/16
    reaper.MIDIEditor_OnCommand(reaper.MIDIEditor_GetActive(), 41070)
elseif restore_note_length == "0.125" then -- 1/32
    reaper.MIDIEditor_OnCommand(reaper.MIDIEditor_GetActive(), 41067)
elseif restore_note_length == "0.0625" then -- 1/64
    reaper.MIDIEditor_OnCommand(reaper.MIDIEditor_GetActive(), 41064)
elseif restore_note_length == "0.03125" then -- 1/128s
    reaper.MIDIEditor_OnCommand(reaper.MIDIEditor_GetActive(), 41062)


elseif restore_note_length == "1.3333333333333" then -- 1/2T
    reaper.MIDIEditor_OnCommand(reaper.MIDIEditor_GetActive(), 41078)
elseif restore_note_length == "0.66666666666667" then -- 1/4T
    reaper.MIDIEditor_OnCommand(reaper.MIDIEditor_GetActive(), 41075)
elseif restore_note_length == "0.33333333333333" then -- 1/8T
    reaper.MIDIEditor_OnCommand(reaper.MIDIEditor_GetActive(), 41072)
elseif restore_note_length == "0.16666666666667" then -- 1/16T
    reaper.MIDIEditor_OnCommand(reaper.MIDIEditor_GetActive(), 41069)
elseif restore_note_length == "0.083333333333333" then -- 1/32T
    reaper.MIDIEditor_OnCommand(reaper.MIDIEditor_GetActive(), 41066)


elseif restore_note_length == "3.0" then -- 1/2.
    reaper.MIDIEditor_OnCommand(reaper.MIDIEditor_GetActive(), 41080)
elseif restore_note_length == "1.5" then -- 1/4.
    reaper.MIDIEditor_OnCommand(reaper.MIDIEditor_GetActive(), 41077)
elseif restore_note_length == "0.75" then -- 1/8.
    reaper.MIDIEditor_OnCommand(reaper.MIDIEditor_GetActive(), 41074)
elseif restore_note_length == "0.375" then --1/16.
    reaper.MIDIEditor_OnCommand(reaper.MIDIEditor_GetActive(), 41071)
elseif restore_note_length == "0.1875" then --1/32.
    reaper.MIDIEditor_OnCommand(reaper.MIDIEditor_GetActive(), 41068)
elseif restore_note_length == "0.09375" then --1/64.
    reaper.MIDIEditor_OnCommand(reaper.MIDIEditor_GetActive(), 41065)
elseif restore_note_length == "0.046875" then --1/128.
    reaper.MIDIEditor_OnCommand(reaper.MIDIEditor_GetActive(), 41063)
end


reaper.defer(function() end) -- no undo point

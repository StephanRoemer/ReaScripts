-- @description Move legato point of 2 selected notes (mousewheel)
-- @version 1.0
-- @changelog
--   initial release
-- @author Stephan Römer
-- @provides [main=midi_editor] .
-- @about
--    # Description
--    * This script moves the legato point of 2 selected notes
--    * This script only works, when exactly 2 notes are selected, otherwise an error message will pop up
--    * This script only works in the MIDI Editor
-- @link https://forums.cockos.com/showthread.php?p=1923923

local val
local note_count
local first_note_found = false
local selected_notes = 0

_,_,_,_,_,_, val = reaper.get_action_context() -- receive mousewheel action
local take = reaper.MIDIEditor_GetTake(reaper.MIDIEditor_GetActive()) -- get current take opened in editor
_, note_count, _, _ = reaper.MIDI_CountEvts(take)

-- check how many notes are selected
for n = 0, note_count-1 do
    _, selected, _, _, _, _, _, _ = reaper.MIDI_GetNote(take, n)
    if selected then
        selected_notes = selected_notes + 1
    end
end

if selected_notes > 2 then
    reaper.ShowMessageBox("Please select only 2 notes at a time", "Error", 0)
    return false
elseif selected_notes < 2 then
    reaper.ShowMessageBox("Please select 2 notes", "Error", 0)
    return false
end

-- decrease length on 1st note, increase start point on 2nd
for n = 0, note_count-1 do
    _, selected, _, note_start, note_end, _, _, _ = reaper.MIDI_GetNote(take, n)
    if selected then
        if first_note_found == false then
            reaper.MIDI_SetNote(take, n, nil, nil, nil, note_end+val, nil, nil, nil, false) -- edit 1st note
            first_note_found = true
        else 
            reaper.MIDI_SetNote(take, n, nil, nil, note_start+val, nil, nil, nil, nil, false) -- edit 2nd note
        end
    end
end







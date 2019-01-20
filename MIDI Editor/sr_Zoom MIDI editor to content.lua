-- @description Zoom MIDI editor to content
-- @version 1.1
-- @changelog
--   undo function added
-- @author Julian Sader, Stephan Römer
-- @provides [main=midi_editor] .
-- @about
--    # Description
--    * This script zooms to the content of the MIDI item, without changing the horizontal zoom of the notes
--    * This script works only in the MIDI editor
-- @link https://forums.cockos.com/showthread.php?p=1923923


-- is there an active MIDI editor?
editor = reaper.MIDIEditor_GetActive()
if editor == nil then return end

reaper.Undo_BeginBlock2(0)
reaper.PreventUIRefresh(1)

-- get item range
item = reaper.GetMediaItemTake_Item(reaper.MIDIEditor_GetTake(editor))
start_item = reaper.GetMediaItemInfo_Value(item, "D_POSITION")
end_item = start_item + reaper.GetMediaItemInfo_Value(item, "D_LENGTH")

-- backup loop range
loopStart, loopEnd = reaper.GetSet_LoopTimeRange2(0, false, true, 0, 0, false)

-- set loop range to item boundaries and zoom
reaper.GetSet_LoopTimeRange2(0, true, true, start_item, end_item, false)
reaper.MIDIEditor_OnCommand(editor, 40726) -- Zoom to project loop selection

-- restore loop range
reaper.GetSet_LoopTimeRange2(0, true, true, loopStart, loopEnd, false)

reaper.PreventUIRefresh(-1)
reaper.UpdateTimeline()
reaper.Undo_EndBlock2(0, "Zoom MIDI editor to content", -1)
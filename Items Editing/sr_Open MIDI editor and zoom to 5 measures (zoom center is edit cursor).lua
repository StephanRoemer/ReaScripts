-- @description Open MIDI editor and zoom to 5 measures (zoom center is edit cursor)
-- @version 1.12
-- @changelog
--   code tidying, renamed the script
-- @author Stephan Römer
-- @provides [main=main] .
-- @about
--    # Description
--    * this script should ultimately help you to get rid of any MIDI Editor zooming issues. Assign it to the enter key and it will open 
--    * the MIDI Editor and zoom to 5 measures (default). Whereas the edit cursor represents the zoom center. 
--    * You can adjust the measures in the user area.
--    * The code is based to 99% on Julian's code, I only added the open MIDI editor command and cleaned up unnecessary parts.
-- @link https://forums.cockos.com/showthread.php?p=1923923


-- USER AREA
number_of_measures = 5

-- End of USER AREA
-------------------


-- open MIDI Editor
reaper.Main_OnCommand(40153, 0) 

-- is there an active MIDI editor?
editor = reaper.MIDIEditor_GetActive()
if editor == nil then return end
 
reaper.PreventUIRefresh(1)

-- backup loop range
loopStart, loopEnd = reaper.GetSet_LoopTimeRange2(0, false, true, 0, 0, false)

edit_cursor_pos = reaper.GetCursorPositionEx(0)
beats, measures = reaper.TimeMap2_timeToBeats(0, edit_cursor_pos)

-- zoom
zoomStart = reaper.TimeMap2_beatsToTime(0, 0, measures-math.floor(number_of_measures/2))
zoomEnd   = reaper.TimeMap2_beatsToTime(0, 0, measures+math.ceil(number_of_measures/2))
reaper.GetSet_LoopTimeRange2(0, true, true, zoomStart, zoomEnd, false)
reaper.MIDIEditor_OnCommand(editor, 40726) -- Zoom to project loop selection

-- restore loop range
reaper.GetSet_LoopTimeRange2(0, true, true, loopStart, loopEnd, false)

reaper.PreventUIRefresh(-1)
reaper.UpdateTimeline()

-- no undo point
function NoUndoPoint() end 
reaper.defer(NoUndoPoint)
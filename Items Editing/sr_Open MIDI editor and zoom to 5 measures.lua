-- @description Open MIDI editor and zoom to 5 measures
-- @version 1.11
-- @author Julian Sader, Stephan Römer
-- @about
--    # Description
--    - this script should ultimately help you to get rid of any MIDI Editor zooming issues. Assign it to the Enter key and it will open the MIDI Editor and zoom to 5 measures (default).
--      You can adjust the measures in the user area.
--    - this code is based to 99% on Julian's code, I only added the open MIDI editor command and cleaned up unnecessary parts.
--
-- @link https://forum.cockos.com/showpost.php?p=1923094&postcount=124
--
-- @changelog
--     v1.1 (2018-01-23)
--     + removed sr from description
--     v1.1 (2018-01-23)
--     + added a "no undo" function
--     v1.0
-- 	  + Initial release

-- USER AREA
number_of_measures = 5

-- End of USER AREA
-------------------

-- Open MIDI Editor
reaper.Main_OnCommand(40153, 0) 

--------------------------------------
-- Is SWS installed?
if not reaper.APIExists("BR_GetMouseCursorContext") then
    reaper.MB("This script requires the SWS/S&M extension, which adds all kinds of nifty features to REAPER.\n\nThe extension can be downloaded from www.sws-extension.org.", "ERROR", 0)
    return
end

   
-- Is there an active MIDI editor?
editor = reaper.MIDIEditor_GetActive()
if editor == nil then return end
    
reaper.PreventUIRefresh(1)

-- Store any pre-existing loop range
loopStart, loopEnd = reaper.GetSet_LoopTimeRange2(0, false, true, 0, 0, false)

mouseTimePos = reaper.GetCursorPositionEx(0)
beats, measures = reaper.TimeMap2_timeToBeats(0, mouseTimePos)

-- Zoom!
zoomStart = reaper.TimeMap2_beatsToTime(0, 0, measures-math.floor(number_of_measures/2))
zoomEnd   = reaper.TimeMap2_beatsToTime(0, 0, measures+math.ceil(number_of_measures/2))
reaper.GetSet_LoopTimeRange2(0, true, true, zoomStart, zoomEnd, false)
reaper.MIDIEditor_OnCommand(editor, 40726) -- Zoom to project loop selection

-- Reset the pre-existing loop range
reaper.GetSet_LoopTimeRange2(0, true, true, loopStart, loopEnd, false)

reaper.PreventUIRefresh(-1)
reaper.UpdateTimeline()

function NoUndoPoint() end 
reaper.defer(NoUndoPoint)
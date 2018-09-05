-- @description Remove 3rd send FX
-- @version 1.0
-- @author Stephan Römer
-- @about
--    # Description
--    - removes the 3rd send FX in the send slot of selected track(s)
--
-- @link https://forums.cockos.com/showthread.php?p=1923923
--
-- @provides [main=main] .
-- @changelog
--     	v1.0 (2018-09-04)
-- 	   	+ Initial release

reaper.Undo_BeginBlock()

if reaper.CountSelectedTracks(0) == 0 then
    reaper.ShowMessageBox("Please select at least one track", "Error", 0)
else
    local selected_tracks = reaper.CountSelectedTracks(0)
    for i = 0, selected_tracks-1 do -- loop thru all selected tracks
        local track = reaper.GetSelectedTrack(0, i) -- get current selected track
        reaper.RemoveTrackSend(track, 0, 2) -- remove 3rd send of selected track(s)
    end
end

reaper.Undo_EndBlock("Remove 3rd send FX", 1)



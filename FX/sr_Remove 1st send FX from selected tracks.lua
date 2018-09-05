-- @description Remove 1st send FX from selected tracks
-- @version 1.0
-- @changelog
--   Initial release
-- @author Stephan Römer
-- @provides [main=main] .
-- @about
--   # Description
--   - this script removes the 1st send FX in the send slot of selected track(s)
-- @link Forum Thread https://forums.cockos.com/showthread.php?p=1923923

reaper.Undo_BeginBlock()

if reaper.CountSelectedTracks(0) == 0 then
    reaper.ShowMessageBox("Please select at least one track", "Error", 0)
else
    local selected_tracks = reaper.CountSelectedTracks(0)
    for i = 0, selected_tracks-1 do -- loop thru all selected tracks
        local track = reaper.GetSelectedTrack(0, i) -- get current selected track
        reaper.RemoveTrackSend(track, 0, 0) -- remove 1st send FX of selected track(s)
    end
end

reaper.Undo_EndBlock("Remove 1st send FX", 1)



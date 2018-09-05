-- @description Toggle show UI of all FX in 3rd send slot
-- @version 1.0
-- @changelog
--   initial release
-- @author Stephan Römer
-- @provides [main=main] .
-- @about
--   # Description
--   - this script shows/hides the UI of all FX in the 3rd send FX slot
-- @link Forum Thread https://forums.cockos.com/showthread.php?p=1923923

local selected_tracks = reaper.CountSelectedTracks(0)

if selected_tracks == 0 then
    reaper.ShowMessageBox("Please select a track", "Error", 0)
    return false
elseif selected_tracks > 1 then
    reaper.ShowMessageBox("Please select only one track", "Error", 0)
    return false
else
    local track = reaper.GetSelectedTrack(0, 0) -- get selected track
    local send_track = reaper.BR_GetMediaTrackSendInfo_Track(track, 0, 2, 1) -- get 3rd send track
    
    reaper.Undo_BeginBlock()

    if reaper.GetTrackNumSends(track, 0) > 2 then
        fx_count = reaper.TrackFX_GetCount(send_track) -- get number of inserts on FX track

        for i = 0, fx_count do
            if not reaper.TrackFX_GetOpen(send_track, i) then -- UI closed?
                reaper.TrackFX_SetOpen(send_track, i, true) -- open 3rd send UI
            else
                reaper.TrackFX_SetOpen(send_track, i, false) -- close 3rd send UI
            end
        end
    else
        reaper.ShowMessageBox("The selected track has no send FX in slot 3", "Error", 0)
        return false
    end

    reaper.Undo_EndBlock("Toggle show UI of 3rd send FX", -1)
end






    



		
		
		

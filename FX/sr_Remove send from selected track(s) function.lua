-- @description Remove send from selected track(s)
-- @version 1.1
-- @changelog
--   switched to external function file and put all scripts in a bundle
-- @author Stephan Römer
-- @provides
-- 	. > sr_Remove send from selected tracks function
-- 	. > sr_Remove send from selected track(s) function
-- 	. > sr_Remove send 1 from selected track(s)
-- 	. > sr_Remove send 2 from selected track(s)
-- 	. > sr_Remove send 3 from selected track(s)
-- 	. > sr_Remove send 4 from selected track(s)
-- @about
--   # Description
--   This script bundle consists of 4 scripts that remove sends 1-4 from the selected track(s)
-- @link Forum Thread https://forums.cockos.com/showthread.php?p=1923923


function RemoveSend(send_number)

    reaper.Undo_BeginBlock()

    if reaper.CountSelectedTracks(0) == 0 then
        reaper.ShowMessageBox("Please select at least one track", "Error", 0)
    else
        local selected_tracks = reaper.CountSelectedTracks(0)
        for i = 0, selected_tracks-1 do -- loop thru all selected tracks
            local track = reaper.GetSelectedTrack(0, i) -- get current selected track
            reaper.RemoveTrackSend(track, 0, send_number-1) -- remove send of selected track(s)
        end
    end

    reaper.Undo_EndBlock("Remove send "..send_number.." from selected track(s)", 1)
end
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
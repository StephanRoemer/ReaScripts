-- @noindex

function ToggleShowUISend(send_slot)

    local selected_tracks = reaper.CountSelectedTracks(0)

    if selected_tracks == 0 then
        reaper.ShowMessageBox("Please select a track", "Error", 0)
        return false
    
    elseif selected_tracks > 1 then
        reaper.ShowMessageBox("Please select only one track", "Error", 0)
        return false
    
    else
        local track = reaper.GetSelectedTrack(0, 0) -- get selected track
        local send_track = reaper.BR_GetMediaTrackSendInfo_Track(track, 0, send_slot-1, 1) -- get 1st send track

        reaper.Undo_BeginBlock()

        if reaper.GetTrackNumSends(track, 0) > send_slot-1 then
            fx_count = reaper.TrackFX_GetCount(send_track) -- get number of inserts on FX track
    
            if fx_count ~= 0 then
    
                for i = 0, fx_count do
    
                    if not reaper.TrackFX_GetOpen(send_track, i) then -- UI closed?
                        reaper.TrackFX_SetOpen(send_track, i, true) -- open send UI
    
                    else
                        reaper.TrackFX_SetOpen(send_track, i, false) -- close send UI
                    end
                end
            else
                reaper.ShowMessageBox("The send in slot "..send_slot.." is either a Bus or has no insert FX", "Error", 0) 
                return false
            end
        else
            reaper.ShowMessageBox("The selected track has no send FX in slot "..send_slot, "Error", 0)
            return false
        end
        
        reaper.Undo_EndBlock("Toggle show UI of all FX in send slot "..send_slot, -1)
    end
end
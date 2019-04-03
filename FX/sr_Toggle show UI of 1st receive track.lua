-- @noindex

function ToggleShowUISend(receive_slot)

    local selected_tracks = reaper.CountSelectedTracks(0)

    if selected_tracks == 0 then
        reaper.ShowMessageBox("Please select a track", "Error", 0)
        return false
    elseif selected_tracks > 1 then
        reaper.ShowMessageBox("Please select only one track", "Error", 0)
        return false
    else
        local track = reaper.GetSelectedTrack(0, 0) -- get selected track
        local receive_track = reaper.BR_GetMediaTrackSendInfo_Track(track, -1, receive_slot-1, 0) -- get 1st receive track

        reaper.Undo_BeginBlock()

        if reaper.GetTrackNumSends(track, -1) > receive_slot-1 then
            fx_count = reaper.TrackFX_GetCount(receive_track) -- get number of inserts on FX track
            if fx_count ~= 0 then
                for i = 0, fx_count do
                    if not reaper.TrackFX_GetOpen(receive_track, i) then -- UI closed?
                        reaper.TrackFX_SetOpen(receive_track, i, true) -- open receive UI
                    else
                        reaper.TrackFX_SetOpen(receive_track, i, false) -- close receive UI
                    end
                end
            else
                reaper.ShowMessageBox("The receive in slot "..receive_slot.." is either a Bus or has no insert FX", "Error", 0) 
                return false
            end
        else
            reaper.ShowMessageBox("The selected track has no receive FX in slot "..receive_slot, "Error", 0)
            return false
        end
        
        reaper.Undo_EndBlock("Toggle show UI of all FX in receive slot "..receive_slot, -1)
    end
end

receive_slot = 1
ToggleShowUISend(receive_slot)
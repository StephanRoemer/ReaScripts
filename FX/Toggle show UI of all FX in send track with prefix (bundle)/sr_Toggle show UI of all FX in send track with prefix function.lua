-- @noindex

function ToggleShowUISend(send_prefix)


    local function FindSendTrack(track, send_prefix)
        
        send_count = reaper.GetTrackNumSends(track, 0) -- get amount of sends on selected track

        if send_count > 0 then -- are there sends on the track?

            for s = 0, send_count-1 do

                send_track = reaper.BR_GetMediaTrackSendInfo_Track(track, 0, s, 1) -- iterate thru all sends from selected track
                _, send_track_name = reaper.GetSetMediaTrackInfo_String(send_track, 'P_NAME', '', false) -- get send_track_name
                
                if string.match(string.sub(send_track_name, 1,#send_prefix), send_prefix) then -- if send_track_name matches send_prefix
                    return s, send_track -- return the slot index and send_track 
                end
            end

            return false -- no match was found

        else -- no sends were found on the selected track
            reaper.ShowMessageBox("The selected tracks has no sends", "Error", 0) 
        end
    end


    local function ToggleSendUI(send_track, send_slot)

        fx_count = reaper.TrackFX_GetCount(send_track) -- get number of inserts on FX track

        if fx_count ~= 0 then
            
            for f = 0, fx_count do
                if not reaper.TrackFX_GetOpen(send_track, f) then -- UI closed?
        
                    reaper.TrackFX_SetOpen(send_track, f, true) -- open send UI

                else
                    reaper.TrackFX_SetOpen(send_track, f, false) -- close send UI
                end
            end
        end
    end


    local track, send_slot, send_track
    local selected_tracks = reaper.CountSelectedTracks(0)

    if selected_tracks == 0 then
        reaper.ShowMessageBox("Please select a track", "Error", 0)
        return false
    
    elseif selected_tracks > 1 then
        reaper.ShowMessageBox("Please select only one track", "Error", 0)
        return false
    
    else
        track = reaper.GetSelectedTrack(0, 0) -- get selected track
        send_slot, send_track = FindSendTrack(track, send_prefix) -- iterate thru all sends and find track with send_prefix
        
        if send_slot ~= false then -- send_prefix found
            ToggleSendUI(send_track, send_slot) -- open UIs of all insert FX on that send track

        else -- send_prefix not found
            reaper.ShowMessageBox("The selected track has no send prefixed with ".. send_prefix.. ".", "Error", 0)
        end
    end
end
-- @noindex

function SendTrackToFX(send_fx_prefix)


    local selected_tracks = reaper.CountSelectedTracks(0)
    

    local function GetFX()
        
        track_count = reaper.GetNumTracks()  
        
        for i = 0, track_count-1 do -- loop thru all tracks
            
            track = reaper.GetTrack(0, i) -- get current track
            _, track_name = reaper.GetTrackName(track, "")
            
            if string.match(string.sub(track_name, 1,#send_fx_prefix), send_fx_prefix) then -- prefix equals send_fx_prefix
                
                return track -- send_fx_prefix track found
                
            end
        end
        return false -- no send_fx_prefix track found
    end
    
    
    local function Main(fx_track)
        
        for i = 0, selected_tracks-1 do -- loop thru all selected tracks
            
            track = reaper.GetSelectedTrack(0, i) -- get current selected track
            _, track_name = reaper.GetTrackName(track, "")
            
            if not string.match(string.sub(track_name, 1,3), send_fx_prefix) then -- prefix is not send_fx_prefix
                reaper.CreateTrackSend(track, fx_track)
                
            else
                reaper.ShowMessageBox("Please don't select the "..send_fx_prefix.." track itself", "Error", 0)
                return false
            end
        end
    end
    
    
    if selected_tracks == 0 then
        reaper.ShowMessageBox("Please select at least one track", "Error", 0)
    else
        local fx_track = GetFX()
        if fx_track == false then -- fx_track doesn't exist
            reaper.ShowMessageBox("An FX track with prefix "..send_fx_prefix.." does not exist.", "Error", 0)
        else
            reaper.Undo_BeginBlock()
            Main(fx_track)
            reaper.Undo_EndBlock("Send selected tracks to "..send_fx_prefix, 1)  
        end
    end
end
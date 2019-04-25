-- @noindex

function SendTrackToBUS(bus_prefix)

    local selected_tracks = reaper.CountSelectedTracks(0)


    local function GetBUS()
        
        track_count = reaper.GetNumTracks()  
        
        for i = 0, track_count-1 do -- loop thru all tracks
            track = reaper.GetTrack(0, i) -- get current track
            _, track_name = reaper.GetTrackName(track, "")
            
            if string.match(string.sub(track_name, 1, #bus_prefix), bus_prefix) then -- prefix equals bus_prefix
                return track -- bus_prefix track found
            
            end
        end
        return false -- no bus_prefix track found
    end


    local function Main(bus_track)
        
        for i = 0, selected_tracks-1 do -- loop thru all selected tracks
            track = reaper.GetSelectedTrack(0, i) -- get current selected track
            _, track_name = reaper.GetTrackName(track, "")
            
            if not string.match(string.sub(track_name, 1,5), bus_prefix) then -- prefix is not bus_prefix
                reaper.CreateTrackSend(track, bus_track)
                reaper.SetMediaTrackInfo_Value(track, "B_MAINSEND", 0) -- remove from master send
            
            else
                reaper.ShowMessageBox("Please don't select the "..bus_prefix.." track itself", "Error", 0)
                return false
            end
        end
    end


    if selected_tracks == 0 then
        reaper.ShowMessageBox("Please select at least one track", "Error", 0)
    
    else
    
        local bus_track = GetBUS()
    
        if bus_track == false then -- bus_track doesn't exist
            reaper.ShowMessageBox("A bus track with prefix "..bus_prefix.." does not exist.", "Error", 0)
    
        else
            reaper.Undo_BeginBlock()
            Main(bus_track)
            reaper.Undo_EndBlock("Send selected tracks to "..bus_prefix, 1)  
        end
    end
end
-- @noindex

function ToggleSoloTrack(track_prefix)

    local track_prefix
    local script_id = ({reaper.get_action_context()})[4] -- get script id


    local function GetTrackByPrefix()
        
        track_count = reaper.GetNumTracks()  
        
        for i = 0, track_count-1 do -- loop thru all tracks
        
            track = reaper.GetTrack(0, i) -- get current track
            _, track_name = reaper.GetTrackName(track, "")
            
            if string.match(string.sub(track_name, 1, #track_prefix), track_prefix) then -- prefix equals track_prefix
                return track -- track_prefix track found
            end
        end
        return false -- no track with track_prefix found
    end


    local function Solo(dest_track)
        
        solo_state = reaper.GetMediaTrackInfo_Value(dest_track, "I_SOLO")
        reaper.Undo_BeginBlock()
        reaper.SetMediaTrackInfo_Value(dest_track, "I_SELECTED", 1)            

        if solo_state == 0 then
            reaper.SetToggleCommandState(0, script_id, 1) -- button toggle on
            reaper.Main_OnCommand(7, 0) -- toggle solo selected tracks
            reaper.Undo_EndBlock("Solo "..track_prefix, 1)
        
        else 
            reaper.SetToggleCommandState(0, script_id, 0) -- button toggle off
            reaper.Main_OnCommand(7, 0) -- toggle solo selected tracks
            reaper.Undo_EndBlock("Unsolo "..track_prefix, 1) 
        end
    end


    local dest_track = GetTrackByPrefix()
    
    if dest_track == false then -- dest_track doesn't exist
        reaper.ShowMessageBox("A bus track with prefix "..track_prefix.." does not exist.", "Error", 0)
    
    else
        reaper.Main_OnCommand(reaper.NamedCommandLookup('_SWS_SAVESEL'), 0) -- save track selection
        reaper.Main_OnCommand(40297, 0) -- unselect all
        Solo(dest_track)
        reaper.Main_OnCommand(reaper.NamedCommandLookup('_SWS_RESTORESEL'), 0) -- restore track selection
        reaper.RefreshToolbar2(0, script_id)
    end
end
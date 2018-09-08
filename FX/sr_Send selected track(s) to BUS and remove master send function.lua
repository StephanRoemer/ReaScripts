-- @description Send selected track(s) to BUS track and remove master send
-- @version 1.0
-- @changelog
--   Initial release
-- @author Stephan Römer
-- @provides
-- 	. > sr_Send selected track(s) to BUS and remove master send function.lua
-- 	. > sr_Send selected track(s) to BUS01 and remove master send.lua
-- 	. > sr_Send selected track(s) to BUS02 and remove master send.lua
-- 	. > sr_Send selected track(s) to BUS03 and remove master send.lua
-- 	. > sr_Send selected track(s) to BUS04 and remove master send.lua
-- 	. > sr_Send selected track(s) to BUS05 and remove master send.lua
-- 	. > sr_Send selected track(s) to BUS06 and remove master send.lua
-- 	. > sr_Send selected track(s) to BUS07 and remove master send.lua
-- 	. > sr_Send selected track(s) to BUS08 and remove master send.lua
-- 	. > sr_Send selected track(s) to BUS09 and remove master send.lua
-- 	. > sr_Send selected track(s) to BUS10 and remove master send.lua
-- 	. > sr_Send selected track(s) to BUS11 and remove master send.lua
-- 	. > sr_Send selected track(s) to BUS12 and remove master send.lua
-- 	. > sr_Send selected track(s) to BUS13 and remove master send.lua
-- 	. > sr_Send selected track(s) to BUS14 and remove master send.lua
-- 	. > sr_Send selected track(s) to BUS15 and remove master send.lua
-- 	. > sr_Send selected track(s) to BUS16 and remove master send.lua
-- @about
--   # Description
--  This script bundle consists of 16 scripts that will send all selected tracks 
--  to a BUS track prefixed with BUS01-16 and remove the parent/master send
-- @link Forum Thread https://forums.cockos.com/showthread.php?p=1923923


function SendTrackToBUS(bus_prefix)

    local selected_tracks = reaper.CountSelectedTracks(0)

    function GetBUS()
        local track_name
        local track_count = reaper.GetNumTracks()  
        
        for i = 0, track_count-1 do -- loop thru all tracks
            local track = reaper.GetTrack(0, i) -- get current track
            _, track_name = reaper.GetTrackName(track, "")
            if string.match(string.sub(track_name, 1,5), bus_prefix) then -- prefix equals bus_prefix
                return track -- bus_prefix track found
            end
        end
        return false -- no bus_prefix track found
    end


    function Main(bus_track)
        local track_name
        
        for i = 0, selected_tracks-1 do -- loop thru all selected tracks
            local track = reaper.GetSelectedTrack(0, i) -- get current selected track
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
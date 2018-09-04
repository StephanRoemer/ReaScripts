-- @description Send selected tracks to FX4
-- @version 1.0
-- @author Stephan Römer
-- @about
--    # Description
--    - sends all selected tracks to an FX track prefixed with FX4
--
-- @link https://forums.cockos.com/showthread.php?p=1923923
--
-- @provides [main=main] .
-- @changelog
--     	v1.0 (2018-09-04)
-- 	   	+ Initial release

if reaper.CountSelectedTracks(0) == 0 then
  reaper.ShowMessageBox("Please select the tracks you want to send to FX4", "Error", 0)
else
  track_count = reaper.GetNumTracks()
  selected_tracks ={} -- create table for selected tracks

  for i = 0, track_count-1 do -- loop thru all tracks
    track = reaper.GetTrack(0, i) -- get media track by track index
    _, track_name = reaper.GetSetMediaTrackInfo_String(track, "P_NAME", "", false)

    if reaper.IsTrackSelected(track) then
      if not string.match(string.sub(track_name, 1,3), "FX4") then -- prefix is not FX4
        table.insert(selected_tracks, track) -- write selected track to table
      else
        reaper.ShowMessageBox("Please don't select the FX4 track itself", "Error", 0)
        return false
      end
    else
      if string.match(string.sub(track_name, 1,3), "FX4") then -- prefix equals FX4
        fx4_track = track -- FX4 track found
      end
    end
  end

  if fx4_track ~= nil then -- FX4 track does exist
    for i = 1, #selected_tracks do
      reaper.CreateTrackSend(selected_tracks[i], fx4_track)
    end
  else
    reaper.ShowMessageBox("An FX track with prefix \"FX4\" does not exist.", "Error", 0) 
  end
end

reaper.Undo_OnStateChange2(proj, "Send selected tracks to FX4")
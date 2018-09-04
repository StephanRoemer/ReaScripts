-- @description Send selected tracks to FX1
-- @version 1.0
-- @author Stephan Römer
-- @about
--    # Description
--    - sends all selected tracks to an FX track prefixed with FX1
--
-- @link https://forums.cockos.com/showthread.php?p=1923923
--
-- @provides [main=main] .
-- @changelog
--     	v1.0 (2018-09-04)
-- 	   	+ Initial release

if reaper.CountSelectedTracks(0) == 0 then
  reaper.ShowMessageBox("Please select the tracks you want to send to FX1", "Error", 0)
else
  track_count = reaper.GetNumTracks()
  selected_tracks ={} -- create table for selected tracks

  for i = 0, track_count-1 do -- loop thru all tracks
    track = reaper.GetTrack(0, i) -- get media track by track index
    _, track_name = reaper.GetSetMediaTrackInfo_String(track, "P_NAME", "", false)

    if reaper.IsTrackSelected(track) then
      if not string.match(string.sub(track_name, 1,3), "FX1") then -- prefix is not FX1
        table.insert(selected_tracks, track) -- write selected track to table
      else
        reaper.ShowMessageBox("Please don't select the FX1 track itself", "Error", 0)
        return false
      end
    else
      if string.match(string.sub(track_name, 1,3), "FX1") then -- prefix equals FX1
        fx1_track = track -- FX1 track found
      end
    end
  end

  if fx1_track ~= nil then -- FX1 track does exist
    for i = 1, #selected_tracks do
      reaper.CreateTrackSend(selected_tracks[i], fx1_track)
    end
  else
    reaper.ShowMessageBox("An FX track with prefix \"FX1\" does not exist.", "Error", 0) 
  end
end

reaper.Undo_OnStateChange2(proj, "Send selected tracks to FX1")

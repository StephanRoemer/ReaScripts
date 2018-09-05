-- @description Send selected tracks to FX1
-- @version 1.1
-- @author Stephan Römer
-- @about
--    # Description
--    - this script sends all selected tracks to an FX track prefixed with FX1
--
-- @link https://forums.cockos.com/showthread.php?p=1923923
--
-- @provides [main=main] .
-- @changelog
--     	v1.1 (2018-09-04)
-- 	   	+ switched to functions
--     	v1.0 (2018-09-04)
-- 	   	+ Initial release

local selected_tracks = reaper.CountSelectedTracks(0)


function GetFX1()
	local track_name
	local track_count = reaper.GetNumTracks()  
	
	for i = 0, track_count-1 do -- loop thru all tracks
		local track = reaper.GetTrack(0, i) -- get current track
		_, track_name = reaper.GetTrackName(track, "")
		if string.match(string.sub(track_name, 1,3), "FX1") then -- prefix equals FX1
			return track -- FX1 track found
		end
	end
	return false -- no FX1 track found
end


function Main(fx1_track)
	local track_name
	
	for i = 0, selected_tracks-1 do -- loop thru all selected tracks
		local track = reaper.GetSelectedTrack(0, i) -- get current selected track
		_, track_name = reaper.GetTrackName(track, "")
		if not string.match(string.sub(track_name, 1,3), "FX1") then -- prefix is not FX1
			reaper.CreateTrackSend(track, fx1_track)
		else
			reaper.ShowMessageBox("Please don't select the FX1 track itself", "Error", 0)
			return false
		end
	end
end


if selected_tracks == 0 then
	reaper.ShowMessageBox("Please select at least one track", "Error", 0)
else
	local fx1_track = GetFX1()
	if fx1_track == false then -- FX1 track doesn't exist
		reaper.ShowMessageBox("An FX track with prefix \"FX1\" does not exist.", "Error", 0)
	else
		reaper.Undo_BeginBlock()
		Main(fx1_track)
		reaper.Undo_EndBlock("Send selected tracks to FX1", 1)  
	end
end
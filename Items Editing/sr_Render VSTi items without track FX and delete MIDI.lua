-- @description Render VSTi items without track FX and delete MIDI
-- @version 1.1
-- @changelog
--   changed script name
-- @author Stephan Römer
-- @provides [main].
-- @about
--    # Description
--    - this script will render a VSTi item to audio, without applying the track FX
--    - this script 
--
-- @link https://forums.cockos.com/showthread.php?p=1923923

  
reaper.Undo_BeginBlock()
 
for i = 0, reaper.CountSelectedTracks(0)-1 do -- loop through all selected tracks
	track = reaper.GetSelectedTrack(0,i) -- save actual track to "track"
	if track ~= nil then -- if selected track is not nil
		fxcount = reaper.TrackFX_GetCount(track) -- save amount of FX to fxcount 
		if fxcount ~= nil then -- if fxcount has a valid value
			for f = 1, fxcount do -- loop thru all FXs
				if f ~= reaper.TrackFX_GetInstrument(track)+1 then -- if FX is not an instrument
					reaper.TrackFX_SetEnabled(track, f-1, false) -- disable FX
				end
			end
		end
		for i = 0, reaper.CountSelectedMediaItems(0)-1 do -- loop through all selected items
			item = reaper.GetSelectedMediaItem(0, i) -- save actual item to "item"
			for t = 0, reaper.CountTakes(item)-1 do -- loop through all takes within each selected item
				activeTake = reaper.GetActiveTake(item) -- save active take to "activeTake"
				if reaper.TakeIsMIDI(activeTake) then -- make sure, that take is MIDI
					reaper.Main_OnCommand(40209,0) -- apply take fx
					reaper.Main_OnCommand(40126,0) -- switch to previous take
					reaper.Main_OnCommand(40129,0) -- delete active take
				end
			end
		end
	end
end
for i = 0, reaper.CountSelectedTracks(0)-1 do -- loop through all selected tracks
	track = reaper.GetSelectedTrack(0,i) -- save actual track to "track"
	if track ~= nil then -- if selected track is not nil
		for f = 1, fxcount do -- loop thru all FXs
			if f ~= reaper.TrackFX_GetInstrument(track)+1 and reaper.TrackFX_GetEnabled(track, f) == false then -- if FX is not an instrument and if FX is disabled						
				reaper.TrackFX_SetEnabled(track, f-1, true) -- enable FX
			end
		end
	end
end
					
reaper.Undo_EndBlock("Render VSTi items without track FX", 0)
-- @description Render VSTi item(s) without track FX and delete MIDI takes
-- @version 1.1
-- @changelog
--   changed script name
-- @author Stephan Römer
-- @provides [main].
-- @about
--    # Description
--    This script will render a VSTi item to audio, without applying the track FX
--	  and delete the original MIDI take. The track FX are kept intact.
-- @link https://forums.cockos.com/showthread.php?p=1923923

  
reaper.Undo_BeginBlock()

-- loop thru all selected tracks and bypass all track FX
for i = 0, reaper.CountSelectedTracks(0)-1 do
	track = reaper.GetSelectedTrack(0,i) -- save current track
	if track ~= nil then -- if selected track is not nil
		fx_count = reaper.TrackFX_GetCount(track) -- save amount of FXs to fx_count 
		if fx_count ~= nil then -- if fx_count has a valid value
			for f = 1, fx_count do -- loop thru all FXs
				if f ~= reaper.TrackFX_GetInstrument(track)+1 then -- if FX is not an instrument
					reaper.TrackFX_SetEnabled(track, f-1, false) -- disable FXs
				end
			end
		end

		-- loop thru all selected items, render to audio and delete MIDI take
		for i = 0, reaper.CountSelectedMediaItems(0)-1 do
			item = reaper.GetSelectedMediaItem(0, i) -- save current item
			for t = 0, reaper.CountTakes(item)-1 do -- loop through all takes within each selected item
				active_take = reaper.GetActiveTake(item) -- save active take
				if reaper.TakeIsMIDI(active_take) then -- make sure, that take is MIDI
					reaper.Main_OnCommand(40209,0) -- render VSTi only
					reaper.Main_OnCommand(40126,0) -- switch to previous take
					reaper.Main_OnCommand(40129,0) -- delete active take
				end
			end
		end
	end
end

-- re-enable all bypassed track FX
for i = 0, reaper.CountSelectedTracks(0)-1 do -- loop through all selected tracks
	track = reaper.GetSelectedTrack(0,i)
	if track ~= nil then
		for f = 1, fx_count do -- loop thru all FXs
			if f ~= reaper.TrackFX_GetInstrument(track)+1 and reaper.TrackFX_GetEnabled(track, f) == false then -- if FX is not an instrument and if FX is disabled						
				reaper.TrackFX_SetEnabled(track, f-1, true) -- enable FX
			end
		end
	end
end
					
reaper.Undo_EndBlock("Render VSTi item(s) without track FX and delete MIDI take(s)", 0)
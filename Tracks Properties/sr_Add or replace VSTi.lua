-- @nomain
-- @description Add or replace VSTi
-- @version 1.0
-- @author Stephan Römer
-- @about
--    # Description
--    - this is a function that will add or replace a VSTi in the 1st FX slot of a track
--    - in order to work correctly, the script expects only 1 VSTi on a track
--
-- @link https://forums.cockos.com/showthread.php?p=1923923
--
-- @changelog
--     v1.0 (2018-01-15)
--     + Initial release


function addInstrument(VSTi, pluginName)

	if reaper.CountSelectedTracks(0) == 0 then
		reaper.ShowMessageBox("Please select a track", "Error",0)
	else 
		for i = 0, reaper.CountSelectedTracks(0)-1 do -- loop through all selected items
			track = reaper.GetSelectedTrack(0,i) -- 
			if track ~= nil then
				fxCount = reaper.TrackFX_GetCount(track) -- get amount of FX in track
				instrument = reaper.TrackFX_GetInstrument(track) -- check, if there is a VSTi among FX
				if fxCount ~= nil and instrument ~= -1 then -- if there are FX on the track and VSTi exists
					reaper.SNM_MoveOrRemoveTrackFX(track, instrument, 0) -- remove VSTi
					reaper.TrackFX_AddByName(track, VSTi, false, -1) -- add VSTi (in last FX slot)
					reaper.GetSetMediaTrackInfo_String(track, "P_NAME", pluginName, true) -- rename track to "pluginName"
					while fxCount>0 do -- while fxCount is greater than 0
						reaper.SNM_MoveOrRemoveTrackFX(track, fxCount, -1) -- move last FX slot one slot up
						fxCount = fxCount-1 -- decrease fxCount by 1
					end -- VSTi is in slot 1
				elseif fxCount ~= nil and instrument == -1 then -- if there are FX on the track but VSTi does not exist
					reaper.TrackFX_AddByName(track, VSTi, false, -1) -- add VSTi (in last FX slot)
					reaper.GetSetMediaTrackInfo_String(track, "P_NAME", pluginName, true) -- rename track to "pluginName"
					fxCount = fxCount+1 -- increase fxCount by one, since a new FX (VSTi) has been added 
					while fxCount>0 do -- while fxCount is greater than 0
						reaper.SNM_MoveOrRemoveTrackFX(track, fxCount, -1) -- move last FX slot one slot up
						fxCount = fxCount-1 -- decrease fxCount by 1
					end
				else -- if there are no FX at all on the track
					reaper.TrackFX_AddByName(track, VSTi, false, -1) -- add VSTi (in last FX slot)
					reaper.GetSetMediaTrackInfo_String(track, "P_NAME", pluginName, true) -- rename track to "pluginName"
				end
			end
		end
	reaper.TrackFX_SetOpen(track, 0, true) -- show GUI of VSTi (slot 1)
	end

end
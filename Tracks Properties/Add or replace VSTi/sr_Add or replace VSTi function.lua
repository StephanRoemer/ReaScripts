-- @noindex

function AddInstrument(vsti, track_name)


	local function AddVSTi(track)
		
		fx_count = reaper.TrackFX_GetCount(track) -- count insert FX in track
		instrument_idx = reaper.TrackFX_GetInstrument(track) -- check, if there is a VSTi among FX
		
		if fx_count > 0 then -- if there are FX 
			
			if instrument_idx ~= -1 then -- if there's an existing VSTi
				
				reaper.TrackFX_Delete(track, instrument_idx) -- remove VSTi
				
				reaper.TrackFX_AddByName(track, vsti, false, -1) -- add VSTi (in last FX slot)
				
				reaper.TrackFX_CopyToTrack(track, fx_count-1, track, instrument_idx, true) -- move new VSTi to original VSTi slot
				reaper.GetSetMediaTrackInfo_String(track, "P_NAME", track_name, true) -- rename track to "track_name"
				replaced = true -- plugin has been replaced, relevant for different undo test
				return instrument_idx, replaced

			else -- if there's no VSTi
				
				reaper.TrackFX_AddByName(track, vsti, false, -1) -- add VSTi (in last FX slot)
				reaper.GetSetMediaTrackInfo_String(track, "P_NAME", track_name, true) -- rename track to "track_name"
				reaper.TrackFX_CopyToTrack(track, fx_count, track, 0, true) -- move VSTi to the first slot. fx_count and not fx_count-1, because a new FX was added
				replaced = false -- plugin has not been replaced but added, relevant for different undo test
				return 0, replaced
			end
			
		else -- only insert VSTi, since they are no other FX
			reaper.TrackFX_AddByName(track, vsti, false, -1) -- add VSTi (in last FX slot)
			reaper.GetSetMediaTrackInfo_String(track, "P_NAME", track_name, true) -- rename track to "track_name"
			replaced = false -- plugin has not been replaced but added, relevant for different undo test
			return 0, replaced
		end
	end
	
	
	local function OpenVSTi(track, slot)
		
		_, _, screen_w, screen_h = reaper.my_getViewport(0, 0, 0, 0, 0, 0, 0, 0, 1) -- get screen resolution of current display
		
		reaper.TrackFX_SetOpen(track, slot, true) -- show GUI of VSTi

		repeat -- wait and let time pass until the plugin GUI has opened (time varies depending on the plugin)
		until (reaper.TrackFX_GetOpen(track, slot) == true) 
		
		_, fx_name = reaper.TrackFX_GetFXName(track, slot, "") -- get FX name
		window_title = fx_name .. ' - Track ' .. tostring(reaper.CSurf_TrackToID(track, false).. " \""..track_name.."\"") -- 
		hwnd = reaper.JS_Window_Find(window_title, true) -- get hwnd

		if hwnd then
  			got_val_ok, width, height = reaper.JS_Window_GetClientSize(hwnd) -- get size of plugin GUI

			  if got_val_ok then -- if retrieving the plugin size values did work
    			reaper.JS_Window_Move(hwnd, math.ceil(screen_w/2-width/2), math.ceil(screen_h/2-height/2)) -- move plugin GUI to the horizontal and vertical center of the screen 
  			end
		end
	end
		
	
	-- check if js_ReaScriptAPI is installed or outdated
	if not reaper.JS_Window_GetForeground then
		reaper.ShowMessageBox("This script requires an up-to-date version of the js_ReaScriptAPI extension."
               .. "\n\nThe js_ReaScriptAPI extension can be installed via ReaPack, or can be downloaded manually."
               .. "\n\nTo install via ReaPack, ensure that the ReaTeam/Extensions repository is enabled. "
               .. "This repository should be enabled by default in recent versions of ReaPack, but if not, "
               .. "the repository can be added using the URL that the script will copy to REAPER's Console."
               .. "\n\n(In REAPER's menu, go to Extensions -> ReaPack -> Import a repository.)"
               .. "\n\nTo install the extension manually, download the most recent version from Github, "
               .. "using the second URL copied to the console, and copy it to REAPER's UserPlugins directory."
                , "ERROR", 0)
        reaper.ShowConsoleMsg("\n\nURL to add ReaPack repository:\nhttps://github.com/ReaTeam/Extensions/raw/master/index.xml")
        reaper.ShowConsoleMsg("\n\nURL for direct download:\nhttps://github.com/juliansader/ReaExtensions")
		return false
	end


	if reaper.CountSelectedTracks(0) == 0 then
		reaper.ShowMessageBox("Please select a track", "Error", 0)

	else 
		for i = 0, reaper.CountSelectedTracks(0)-1 do -- loop through all selected tracks
			
			local track = reaper.GetSelectedTrack(0, i) -- get current track
			local slot, replaced = AddVSTi(track) -- add VSTi and get VSTi slot
			OpenVSTi(track, slot) -- open VSTi and center it
			return replaced 
		end
	end
end
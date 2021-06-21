-- @noindex

function AddInstrument(vsti, track_name)
	
	
	-- ================================================================================================================== --
	--                                                  Helper Functions                                                  --
	-- ================================================================================================================== --
	

	local function ShowVSTi(track, slot, auto_float)
		
		local _, _, screen_w, screen_h = reaper.my_getViewport(0, 0, 0, 0, 0, 0, 0, 0, 1) -- get screen resolution of current display
		

		-- If auto float is disabled in REAPER prefs, open VSTi "manually"

		if auto_float == 0 then 
			reaper.TrackFX_Show(track, slot, 3)
		end
		

		local _, fx_name = reaper.TrackFX_GetFXName(track, slot, "") -- get FX name
		local window_title = fx_name .. ' - Track ' .. tostring(reaper.CSurf_TrackToID(track, false)) -- add track number to window title (shown in the FX window)
		
		repeat -- wait and let time pass until the plugin GUI has opened (time varies depending on the plugin)
		until (reaper.TrackFX_GetOpen(track, slot) == true) 
	
		local hwnd = reaper.JS_Window_Find(window_title, false) -- get hwnd of FX window

		
		-- Position FX window at the middle of the screen

		if hwnd then
			local got_val_ok, width, height = reaper.JS_Window_GetClientSize(hwnd) -- get size of plugin GUI
			
			if got_val_ok then -- if retrieving the plugin size values did work
				reaper.JS_Window_Move(hwnd, math.ceil(screen_w/2-width/2), math.ceil(screen_h/2-height/2)) -- move plugin GUI to the horizontal and vertical center of the screen 
			end
		end
	end

	

	-- ================================================================================================================== --
	--                                                      Add VSTi                                                      --
	-- ================================================================================================================== --
	

	local function AddVSTi(track)
		
		local replaced
		local fx_count = reaper.TrackFX_GetCount(track) -- count insert FX in track
		local instr_idx = reaper.TrackFX_GetInstrument(track) -- get index of existing VSTi
		
		reaper.GetSetMediaTrackInfo_String(track, "P_NAME", track_name, true) -- rename track to "track_name"
		
		
		-- If there are FX

		if fx_count > 0 then 
			
			-- If there's an existing VSTi
		
			if instr_idx ~= -1 then 
				
				reaper.TrackFX_Delete(track, instr_idx) -- remove VSTi
				reaper.TrackFX_AddByName(track, vsti, false, -1000-instr_idx) -- add VSTi at original VSTi position
				replaced = true -- plugin has been replaced, relevant for different undo cases
				return instr_idx, replaced
			

			-- If there's no VSTi, but probably a Reaticulate jsfx
		
			else 
				
				local slot 
				
				
				-- Check for possible Reaticulate jsfx
			
				for f = 0, fx_count-1 do
					_, fx_name = reaper.TrackFX_GetFXName(track, f, "")
					if fx_name == "JS: Reaticulate.jsfx" then
						
						-- Reaticulate would probably always be in slot 0, but just in case more jsx are stacked, 
						-- always check for slot and add +1, because the VSTi needs to be in the next slot
						slot = f+1 
						break
					end
				end


				-- no Reaticulate
			
				if slot == nil then
					reaper.TrackFX_AddByName(track, vsti, false, -1000) -- add VSTi in first slot (0)
					replaced = false -- plugin has not been replaced but added, relevant for different undo cases
					return 0, replaced
				

				-- Reaticulate -> move VSTi one slot below
			
				else 
						reaper.TrackFX_AddByName(track, vsti, false, -1000-slot) -- add VSTi in first slot 
						replaced = false -- plugin has not been replaced but added, relevant for different undo cases
						return slot, replaced
					end
				end
		
				
		-- only insert VSTi, since they are no other FX
		
		else 
			reaper.TrackFX_AddByName(track, vsti, false, -1000) -- add VSTi (in first slot)
			replaced = false -- plugin has not been replaced but added, relevant for different undo cases
			return 0, replaced
		end
	end


	
	-- ================================================================================================================== --
	--                                                        Main                                                        --
	-- ================================================================================================================== --
	

	local function Main()
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
		
		local auto_float = reaper.GetToggleCommandState(41078) -- get auto float state
		
		if reaper.CountSelectedTracks(0) == 0 then
			reaper.ShowMessageBox("Please select a track", "Error", 0)
			
		else 
			for i = 0, reaper.CountSelectedTracks(0)-1 do -- loop through all selected tracks
				
				local track = reaper.GetSelectedTrack(0, i) -- get current track
				local slot, replaced = AddVSTi(track) -- add VSTi and get VSTi slot
				ShowVSTi(track, slot, auto_float) -- open VSTi and center it
				return replaced 
			end
		end
	end

	Main()
end

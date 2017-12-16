-- @noindex
-- @description MIDI functions
-- @version 1.0
-- @author Stephan Römer
-- @about
--    # Description
--    - this is a collection of MIDI functions, that are used by various scripts that I created.
--
-- @link https://forums.cockos.com/showthread.php?p=1923923
--
-- @changelog
--     v1.0
--     + Initial release


function transpose(interval)
	for i = 0, reaper.CountSelectedMediaItems(0)-1 do -- loop through all selected items
		item = reaper.GetSelectedMediaItem(0, i)
		for t = 0, reaper.CountTakes(item)-1 do -- Loop through all takes within each selected item
			take = reaper.GetTake(item, t)
			if reaper.TakeIsMIDI(take) then -- make sure, that take is MIDI
				notes = reaper.MIDI_CountEvts(take) -- count notes and save amount to "notes"
				for n = 0, notes - 1 do -- loop thru all notes
					_, selectedOut, _, _, _, _, _, _ = reaper.MIDI_GetNote(take, n) -- get selection status
					if selectedOut == true then -- if at least note is selected
						notes_selected = true -- set notes_selected to true
						break -- break the for loop, because at least one selected note was found
					end
				end
			
				for n = 0, notes - 1 do -- loop thru all notes
					_, selectedOut, _, _, _, _, pitchOut, _ = reaper.MIDI_GetNote(take, n) -- get selection status and pitch
					if notes_selected == true then -- if there is a note selection
						if selectedOut == true then -- filter out selected notes to apply transpose
							reaper.MIDI_SetNote(take, n, true, nil, nil, nil, nil, pitchOut+interval, nil, true) -- transpose selected notes by interval
						end
					else
						reaper.MIDI_SetNote(take, n, nil, nil, nil, nil, nil, pitchOut+interval, nil, true) -- transpose all notes by interval
					end
				end
			end
		end
	end
end
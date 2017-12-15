-- @description sr_Transpose notes -12
-- @version 1.0
-- @author Stephan Römer
-- @about
--    # Description
--    - this script transposes either all notes or selected notes by 12 semitone down
--    - this script works in arrangement, MIDI Editor and Inline Editor
--
-- @link https://forums.cockos.com/showthread.php?p=1923923
--
-- @changelog
--     + Initial release


interval = 12


for i = 0, reaper.CountSelectedMediaItems(0)-1 do -- loop through all selected items
    item = reaper.GetSelectedMediaItem(0, i)
    for t = 0, reaper.CountTakes(item)-1 do -- Loop through all takes within each selected item
        take = reaper.GetTake(item, t)
        if reaper.TakeIsMIDI(take) then -- make sure, that take is MIDI
            notes = reaper.MIDI_CountEvts(take) -- count notes and save amount to "notes"
            for n = 0, notes - 1 do -- loop thru all notes
				_, sel, _, _, _, _, _, _ = reaper.MIDI_GetNote(take, n) -- get selection status
				if sel == true then -- if at least note is selected
					notes_selected = true -- set notes_selected to true
					break -- break the for loop, because at least one selected note was found
				end
			end
		
			if notes_selected == true then -- if there is a note selection
				for n = 0, notes - 1 do -- loop thru all notes
					_, sel, _, _, _, _, pitch, _ = reaper.MIDI_GetNote(take, n) -- get selection status and pitch
					if sel == true then -- filter out selected notes to apply transpose
						reaper.MIDI_SetNote(take, n, true, nil, nil, nil, nil, pitch-interval, nil, true) -- transpose selected notes +3
					end
				end
			else
				for n = 0, notes - 1 do -- loop thru all notes
					_, _, _, _, _, _, pitch, _ = reaper.MIDI_GetNote(take, n) -- get pitch
					reaper.MIDI_SetNote(take, n, nil, nil, nil, nil, nil, pitch-interval, nil, true) -- transpose all notes +3
				end
			end
		end
	end
end

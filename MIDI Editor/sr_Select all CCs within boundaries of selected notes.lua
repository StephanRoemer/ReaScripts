-- @description Select all CCs within boundaries of selected notes
-- @version 1.01
-- @author Stephan Römer
-- @about
--    # Description
--    - this script select all CCs within the boundaries of selected notes
--    - execute again to toggle selection
--    - this script works in arrangement, MIDI Editor and Inline Editor
--
-- @link https://forums.cockos.com/showthread.php?p=1923923
--
-- @provides [main=main,midi_editor,midi_inlineeditor] .
-- @changelog
--     v1.01 (2017-12-21)
-- 	   + fixed an issue with wrong assigned notesCount
--     v1.0 (2017-12-18)
--     + initial release


for i = 0, reaper.CountSelectedMediaItems(0)-1 do -- loop through all selected items
    item = reaper.GetSelectedMediaItem(0, i) -- 
    for t = 0, reaper.CountTakes(item)-1 do -- Loop through all takes within each selected item
        take = reaper.GetTake(item, t)
        if reaper.TakeIsMIDI(take) then -- make sure, that take is MIDI
            _, notesCount, ccCount, _ = reaper.MIDI_CountEvts(take) -- count notes and CCs 
         	for n = 0, notesCount - 1 do -- loop thru all notes
				_, selectedOut, _, startppqposOut, endppqposOut, _, _, _ = reaper.MIDI_GetNote(take, n) -- get selection, start and end position from notes
				if selectedOut == true and firstNotePPQ == nil then -- if note is selected and firsteNotePPQ has no value
					firstNotePPQ = startppqposOut -- write current start position to firstNotePPQ
					lastNotePPQ = endppqposOut -- write end position to lasteNotePPQ
                elseif selectedOut == true then -- if note is selected and firstNotePPQ has already a value
                	lastNotePPQ = endppqposOut -- write end position to lasteNotePPQ
				end
			end
			for c = 0, ccCount - 1 do -- loop thru all CCs
            	_, selectedOut, _, ppqposOut, _, _, cc, _ = reaper.MIDI_GetCC(take, c) -- get CC position
				if firstNotePPQ == nil then -- if firstNotePPQ is nil, e.g. if there are no notes selected
					reaper.ShowMessageBox("Please select notes first", "Error", 0)
					break
				else
					if  selectedOut == true then -- if CC is selected
						reaper.MIDI_SetCC(take, c, false, nil, nil, nil, nil, nil, nil, true) -- unseselect CCs 
					elseif ppqposOut >= firstNotePPQ and ppqposOut < lastNotePPQ then -- if CC events are within the boundaries of selected notes
						reaper.MIDI_SetCC(take, c, true, nil, nil, nil, nil, nil, nil, true) -- select CCs   
					end
				end
            end
        end
    end
end

reaper.Undo_OnStateChange2(proj, "Select all CCs within boundaries of selected notes")
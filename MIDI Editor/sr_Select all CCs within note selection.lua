-- @description Select all CCs within note selection
-- @version 1.31
-- @changelog
--   Fallback for no selected item
-- @author Stephan Römer
-- @provides [main=main,midi_editor,midi_inlineeditor] .
-- @about
--    # Description
--    * This script select all CCs within the boundaries of selected notes
--    * Executing the scripts again toggles the CC selection
--    * These scripts work in arrangement, MIDI Editor and Inline Editor
-- @link https://forums.cockos.com/showthread.php?p=1923923

if reaper.CountSelectedMediaItems(0) == 0 then
	reaper.ShowMessageBox("Please select at least one item", "Error", 0)
	return false
else 
	for i = 0, reaper.CountSelectedMediaItems(0)-1 do -- loop through all selected items
		local item = reaper.GetSelectedMediaItem(0, i) -- get current selected item
		local take = reaper.GetActiveTake(item)
		
		if reaper.TakeIsMIDI(take) then -- make sure, that take is MIDI
            _, notesCount, ccCount, _ = reaper.MIDI_CountEvts(take) -- count notes and CCs 
	
			for n = 0, notesCount - 1 do -- loop thru all notes
				_, selected_out, _, startppqpos_out, endppqpos_out, _, _, _ = reaper.MIDI_GetNote(take, n) -- get selection, start and end position from notes
	
				if selected_out == true and first_note_ppq == nil then -- if note is selected and firsteNotePPQ has no value
					first_note_ppq = startppqpos_out -- write current start position to first_note_ppq
					last_note_ppq = endppqpos_out -- write end position to lasteNotePPQ
                elseif selected_out == true then -- if note is selected and first_note_ppq has already a value
                	last_note_ppq = endppqpos_out -- write end position to lasteNotePPQ
				end
			end
	
			for c = 0, ccCount - 1 do -- loop thru all CCs
            	_, selected_out, _, ppqpos_out, _, _, cc, _ = reaper.MIDI_GetCC(take, c) -- get CC position
	
				if first_note_ppq == nil then -- if first_note_ppq is nil, e.g. if there are no notes selected
					reaper.ShowMessageBox("Please select notes first", "Error", 0)
					break
				else
					if  selected_out == true then -- if CC is selected
						reaper.MIDI_SetCC(take, c, false, nil, nil, nil, nil, nil, nil, true) -- unseselect CCs 
					elseif ppqpos_out >= first_note_ppq and ppqpos_out < last_note_ppq then -- if CC events are within the boundaries of selected notes
						reaper.MIDI_SetCC(take, c, true, nil, nil, nil, nil, nil, nil, true) -- select CCs   
					end
				end
            end
        end
    end
end

reaper.Undo_OnStateChange2(proj, "Select all CCs within note selection")
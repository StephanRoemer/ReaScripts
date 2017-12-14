-- @description sr_Delete short notes
-- @version 1.0    
-- @author Stephan Römer
-- @about
--    # Description
--    - deletes leftover short notes, that are created, when splitting (on grid) notes that are not hard quantized (humanized)
--    - this script works in arrangement, MIDI Editor and Inline Editor
--    - adjust the length of shortnote in the user area. To get an idea which values are typical for short notes, enable the 
--    - ShowConsoleMsg near the end of the script
--
-- @link https://forums.cockos.com/showthread.php?p=1923923
--
-- @changelog
-- 	  + Initial release


-- User Area

shortnote = 70 -- define the length of the leftover notes that should be deleted

-- /User Area


for i = 0, reaper.CountSelectedMediaItems(0)-1 do -- loop through all selected items
    item = reaper.GetSelectedMediaItem(0, i)
    for t = 0, reaper.CountTakes(item)-1 do -- Loop through all takes within each selected item
        take = reaper.GetTake(item, t)
        if reaper.TakeIsMIDI(take) then -- make sure, that take is MIDI
            notes = reaper.MIDI_CountEvts(take) -- count notes and save amount to "notes"
        
			reaper.Undo_BeginBlock() reaper.PreventUIRefresh(1)
        
			for n = notes-1, 0, -1 do -- loop thru all notes, back to front 
				_, _, _, start_note, end_note, _, _, _ = reaper.MIDI_GetNote(take, n) -- get start and end position
				note_length = end_note - start_note -- calculate note length
				if  note_length < shortnote then
					reaper.MIDI_DeleteNote(take, n) -- delete note if condition above is true
				end
			end
        
			reaper.PreventUIRefresh(-1) reaper.Undo_EndBlock('Delete short notes', 2)    

        end
    end
end 





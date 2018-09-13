-- @description Delete short notes
-- @version 1.2
-- @changelog
--   code tidying
-- @author Stephan Römer
-- @provides [main=main,midi_editor,midi_inlineeditor] .
-- @about
--    # Description
--    * Deletes leftover short notes, that are created, when splitting (on grid) notes that are not hard quantized (humanized)
--    * This script works in arrangement, MIDI Editor and Inline Editor
--    * Adjust the length of shortnote in the user area. To get an idea which values are typical for short notes, enable the 
--      ShowConsoleMsg near the end of the script
-- @link https://forums.cockos.com/showthread.php?p=1923923


-- User Area Start
shortnote = 40 -- define the length of the leftover notes that should be deleted
-- User Area End

for i = 0, reaper.CountSelectedMediaItems(0)-1 do -- loop through all selected items
    item = reaper.GetSelectedMediaItem(0, i)
    for t = 0, reaper.CountTakes(item)-1 do -- Loop through all takes within each selected item
        take = reaper.GetTake(item, t)
        if reaper.TakeIsMIDI(take) then -- make sure, that take is MIDI
            _, notes_count, _, _ = reaper.MIDI_CountEvts(take) -- count notes and save amount to notes_count
			for n = notes_count-1, 0, -1 do -- loop thru all notes, back to front 
				_, _, _, start_note, end_note, _, _, _ = reaper.MIDI_GetNote(take, n) -- get start and end position
				note_length = end_note - start_note -- calculate note length
				if  note_length < shortnote then
					reaper.MIDI_DeleteNote(take, n) -- delete note if condition above is true
				end
			end
        end
    end
end 

reaper.Undo_OnStateChange2(proj, "Delete short notes")



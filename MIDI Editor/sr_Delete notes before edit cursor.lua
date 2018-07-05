-- @description Delete notes before edit cursor
-- @version 1.2
-- @author Stephan Römer
-- @about
--    # Description
--    - delete all notes, that are located before the edit cursor position
--    - this script works in arrangement, MIDI Editor and Inline Editor
--    - for obvious reasons, this script only works with a single item and will popup a message box, if you have more than one item selected or no item selected at all
--
-- @link https://forums.cockos.com/showthread.php?p=1923923
--
-- @provides [main=main,midi_editor,midi_inlineeditor] .
-- @changelog
--     v1.2 (2018-07-05)
-- 	   + added a case for "no item selected"
--     v1.11 (2017-12-21)
-- 	   + fixed an issue with wrong assigned notesCount
--     v1.1 (2017-12-16)
--     + added undo state
-- 	   + Initial release
--     v1.0

if reaper.CountSelectedMediaItems(0) > 1 then
	reaper.ShowMessageBox("Please select only one item", "Error" , 0) -- popup error message, if more than 1 item is selected
	return
elseif reaper.CountSelectedMediaItems(0) == 0 then 
	reaper.ShowMessageBox("Please select one item", "Error" , 0) -- popup error message, if no item is selected
	return
elseif reaper.CountSelectedMediaItems(0) == 1 then
	for i = 0, reaper.CountSelectedMediaItems(0)-1 do -- loop through all selected items
		item = reaper.GetSelectedMediaItem(0, i)
			for t = 0, reaper.CountTakes(item)-1 do -- Loop through all takes within each selected item
				take = reaper.GetTake(item, t)
				if reaper.TakeIsMIDI(take) then -- make sure, that take is MIDI
					cursor_position = reaper.GetCursorPosition()  -- get edit cursor position 
					cursor_position_ppq = reaper.MIDI_GetPPQPosFromProjTime(take, cursor_position) -- convert to PPQ
					_, notesCount, _, _ = reaper.MIDI_CountEvts(take) -- count notes and save amount to notesCount
					for n = notesCount-1, 0, -1 do -- loop thru all notes, back to front 
						_, _, _, start_note, end_note, _, _, _ = reaper.MIDI_GetNote(take, n) -- get start and end position
						if start_note < cursor_position_ppq and end_note <= cursor_position_ppq or  start_note < cursor_position_ppq and end_note > cursor_position_ppq then
							reaper.MIDI_DeleteNote(take, n) -- delete note if condition above is true
						end
					end
				end
			end
		end 
	end
reaper.UpdateArrange()
reaper.Undo_OnStateChange2(proj, "Delete notes before edit cursor")
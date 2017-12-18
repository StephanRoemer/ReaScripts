-- @description Set edit cursor to last note in selected items
-- @version 1.0
-- @author Stephan Römer
-- @about
--    # Description
--    - this script sets the editor cursor to the beginning of the last note in selected items
--    - this script works in arrangement, MIDI Editor and Inline Editor
--
-- @link https://forums.cockos.com/showthread.php?p=1923923
--
-- @provides [main=main,midi_editor,midi_inlineeditor] .
-- @changelog
--     v1.0 (2017-12-18)
-- 	   + Initial release


countItems = reaper.CountSelectedMediaItems(0)-1 -- count items
item = reaper.GetSelectedMediaItem(0, countItems) -- get last item
countTakes = reaper.CountTakes(item)-1 -- count takes
take = reaper.GetTake(item, countTakes) -- get last takes
if reaper.TakeIsMIDI(take) then -- make sure, that take is MIDI
	notes = reaper.MIDI_CountEvts(take) -- count notes and save amount to notes
	_, _, _, _, noteEnd, _, _, _ = reaper.MIDI_GetNote(take, notes-1) -- get end of last note
	noteEndProj = reaper.MIDI_GetProjTimeFromPPQPos(take, noteEnd) -- convert noteEnd (PPQ) to project time
	reaper.SetEditCurPos(noteEndProj, false, false) -- set edit cursor to note end of last note
end

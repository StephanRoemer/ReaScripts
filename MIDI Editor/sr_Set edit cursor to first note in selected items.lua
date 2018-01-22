-- @description Set edit cursor to first note in selected items
-- @version 1.0
-- @author Stephan Römer
-- @about
--    # Description
--    - this script sets the edit cursor to the beginning of the first note in selected items
--    - this script works in arrangement, MIDI Editor and Inline Editor
--
-- @link https://forums.cockos.com/showthread.php?p=1923923
--
-- @provides [main=main,midi_editor,midi_inlineeditor] .
-- @changelog
--     v1.0 (2017-12-18)
-- 	   + Initial release


item = reaper.GetSelectedMediaItem(0, 0) -- get first item
take = reaper.GetTake(item, 0) -- get first take
if reaper.TakeIsMIDI(take) then -- make sure, that take is MIDI
	_, _, _, noteStart, _, _, _, _ = reaper.MIDI_GetNote(take, 0) -- get start of first note
	noteStartSec = reaper.MIDI_GetProjTimeFromPPQPos(take, noteStart) -- convert noteStart (PPQ) to project time
	reaper.SetEditCurPos(noteStartSec, false, false) -- set edit cursor to note start of first note
end
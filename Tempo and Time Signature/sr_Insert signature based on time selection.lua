-- @description Insert signature based on time selection
-- @version 1.1
-- @changelog
--   a lot of bug fixes, the script was very buggy in some edge cases
-- @author Stephan Römer
-- @provides [main=main,midi_editor] .
-- @about
--    # Description
--    * This script inserts a signature based on the grid value and the time selection
--    * This script works in the MIDI Editor and the Arrange view
-- @link https://forums.cockos.com/showthread.php?p=1923923


timesel_start, timesel_end = reaper.GetSet_LoopTimeRange(0, 0, 0, 0, 0) -- get time selection

midi_editor = reaper.MIDIEditor_GetActive() -- get active MIDI Editor

if midi_editor == nil then -- if user is in the Arrangement (MIDI Editor is closed), use project grid for quantize
    _, grid = reaper.GetSetProjectGrid(0, 0) -- get project grid
else
    grid, _, _ = reaper.MIDI_GetGrid(reaper.MIDIEditor_GetTake(midi_editor)) -- get MIDI editor grid
    grid = grid / 4 -- grid needs to be corrected, not sure why
end

_, _, _, fullbeats_timesel_start, cdenom = reaper.TimeMap2_timeToBeats(0, timesel_start) -- time selection start in beats
_, _, _, fullbeats_timesel_end, _ = reaper.TimeMap2_timeToBeats(0, timesel_end) -- time selection end in beats

fullbeats_timesel_distance = fullbeats_timesel_end - fullbeats_timesel_start -- time selection distance in beats

denominator = 1 / grid
numerator = fullbeats_timesel_distance/cdenom*denominator --
numerator = math.modf(numerator+0.5) -- "convert" float to integer by rounding

_, _, tempo = reaper.TimeMap_GetTimeSigAtTime(0, timesel_start) -- get tempo
reaper.SetTempoTimeSigMarker(0, -1, timesel_start, -1, -1, tempo, numerator, denominator, true) -- insert signature and tempo



-- signature = timesel_end_qn - timesel_start_qn -- calculate signature, 1 would be 4/4, 8/8, etc...

-- retval, timepos, measurepos, beatpos, bpm, timesig_num, timesig_denom, lineartempo = reaper.GetTempoTimeSigMarker( proj, ptidx )


reaper.UpdateTimeline()
reaper.UpdateArrange()

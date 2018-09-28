-- @description Insert signature based on time selection
-- @version 1.0
-- @changelog
--   initial release
-- @author Stephan Römer
-- @provides [main=main,midi_editor] .
-- @about
--    # Description
--    * This script inserts a signature based on the grid value and the time selection
--    * This script works in the MIDI Editor and the Arrange view
-- @link https://forums.cockos.com/showthread.php?p=1923923


timesel_start, timesel_end = reaper.GetSet_LoopTimeRange(0, 0, 0, 0, 0) -- get time selection
timesel_start_qn = reaper.TimeMap_QNToTime(timesel_start) -- convert to QN
timesel_end_qn = reaper.TimeMap_QNToTime(timesel_end) -- convert to QN

midi_editor = reaper.MIDIEditor_GetActive() -- get active MIDI Editor

if midi_editor == nil then -- if user is in the Arrangement (MIDI Editor is closed), use project grid for quantize
    _, grid = reaper.GetSetProjectGrid(0, 0) -- get project grid
else
    grid, _, _ = reaper.MIDI_GetGrid(reaper.MIDIEditor_GetTake(midi_editor)) -- get MIDI editor grid
    grid = grid / 4 -- grid needs to be corrected, not sure why
end

signature = timesel_end_qn - timesel_start_qn -- calculate signature, 1 would be 4/4, 8/8, etc...
numerator = signature / grid
denominator = 1 / grid

if math.floor(numerator) ~= numerator then -- if number can be rounded, then it's not an integer
    reaper.ShowMessageBox("The numerator is not an integer. The time selection does not fit in your current grid resolution. Please change your grid setting.", "Error", 0)
    return false
end

reaper.SetTempoTimeSigMarker(0, -1, timesel_start, -1, -1, 0, numerator, denominator, true) -- insert signature

reaper.UpdateTimeline()
reaper.UpdateArrange()

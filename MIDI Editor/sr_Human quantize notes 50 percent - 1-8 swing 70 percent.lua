-- @description Human quantize notes 50% - 1/8 swing 70%
-- @version 1.0
-- @author Stephan Römer
-- @about
--    # Description
--    - this script human quantizes either all notes or selected notes by 50% to the 1/8 grid swing 70%
--    - this script works in arrangement, MIDI Editor and Inline Editor
--
-- @link https://forums.cockos.com/showthread.php?p=1923923
--
-- @provides [main=main,midi_editor,midi_inlineeditor] .
-- @changelog
--     v1.0 (2017-12-17)
--     + Initial release


package.path = debug.getinfo(1,"S").source:match[[^@?(.*[\/])[^\/]-$]] .."?.lua;".. package.path
require 'sr_MIDI functions'


grid = 1/8 -- 1/8 grid swing
swing = 1 -- swing off
swingAmt = 0.7 -- swing amount
humanize = 50 -- humanize value in percent

_, saveProjectGrid, saveSwing, saveSwingAmt = reaper.GetSetProjectGrid(proj, false) -- backup current grid settings
reaper.GetSetProjectGrid(proj, true, grid, swing, swingAmt) -- set new grid settings according variable grid
human_quantize(humanize) -- call function
reaper.GetSetProjectGrid(proj, true, saveProjectGrid, saveSwing, saveSwingAmt) -- restore saved grid settings
reaper.Undo_OnStateChange2(proj, "Human Quantize 50% - 1/8 swing 70%")
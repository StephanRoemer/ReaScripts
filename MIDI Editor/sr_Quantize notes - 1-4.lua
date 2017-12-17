-- @description Quantize notes - 1/4
-- @version 1.0
-- @author Stephan Römer
-- @about
--    # Description
--    - this script quantizes either all notes or selected notes to 1/4
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


grid = 0.25 -- 1/4 grid
swing = 0 -- swing off
swingAmt = 0 -- swing amount

_, saveProjectGrid, saveSwing, saveSwingAmt = reaper.GetSetProjectGrid(proj, false) -- backup current grid settings
reaper.GetSetProjectGrid(proj, true, grid, swing, swingAmt) -- set new grid settings according variable grid, swing and swingAmt
quantize() -- call function
reaper.GetSetProjectGrid(proj, true, saveProjectGrid, saveSwing, saveSwingAmt) -- restore saved grid settings
reaper.Undo_OnStateChange2(proj, "Quantize notes - 1/4")
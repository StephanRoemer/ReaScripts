-- @description Human quantize notes 50% - grid
-- @version 1.0
-- @author Stephan Römer
-- @about
--    # Description
--    - this script human quantizes either all notes or selected notes by 50% to the currently set project grid
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

humanize = 50 -- humanize value in percent

human_quantize(humanize) -- call function
reaper.Undo_OnStateChange2(proj, "Human Quantize notes 50% - grid")
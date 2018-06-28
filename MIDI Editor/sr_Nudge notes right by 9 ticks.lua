-- @description Nudge notes right by 9 ticks
-- @version 1.0
-- @author Stephan Römer
-- @about
--    # Description
--    - this script nudges either all notes or selected notes right by 9 ticks
--    - this script works in arrangement, MIDI Editor and Inline Editor
--
-- @link https://forums.cockos.com/showthread.php?p=1923923
--
-- @provides [main=main,midi_editor,midi_inlineeditor] .
-- @changelog
--     v1.0 (2018-06-27)
--     + Initial release

package.path = debug.getinfo(1,"S").source:match[[^@?(.*[\/])[^\/]-$]] .."?.lua;".. package.path
require 'sr_MIDI functions'

newPosition = 9 -- ticks

nudgenotes(newPosition) -- call function
reaper.Undo_OnStateChange2(proj, "Nudge notes right by 9 ticks")
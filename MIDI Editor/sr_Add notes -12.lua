-- @description Add notes -12
-- @version 1.0
-- @author Stephan Römer
-- @about
--    # Description
--    - this script adds -12 semitones to either all notes or selected notes
--    - this script works in arrangement, MIDI Editor and Inline Editor
--
-- @link https://forums.cockos.com/showthread.php?p=1923923
--
-- @provides [main=main,midi_editor,midi_inlineeditor] .
-- @changelog
--     v1.1 (2017-12-16)
--     + added undo state
--     v1.0 (2017-12-15)
--     + Initial release

package.path = debug.getinfo(1,"S").source:match[[^@?(.*[\/])[^\/]-$]] .."?.lua;".. package.path
require 'sr_MIDI functions'

interval = -12 -- semitones

add_notes(interval) -- call function
reaper.Undo_OnStateChange2(proj, "Add notes -12")
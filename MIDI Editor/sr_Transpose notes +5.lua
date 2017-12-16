-- @description Transpose notes +5
-- @version 1.1
-- @author Stephan Römer
-- @about
--    # Description
--    - this script transposes either all notes or selected notes by 5 semitone up
--    - this script works in arrangement, MIDI Editor and Inline Editor
--
-- @link https://forums.cockos.com/showthread.php?p=1923923
--
-- @provides [main=main,midi_editor,midi_inlineeditor] .
-- @changelog
--     v1.11 (2017-12-16)
--     + added undo state
--     v1.1 (2017-12-15)
--     + moved the functions to a seperate file "sr_MIDI functions"
--     v1.0
--     + Initial release

package.path = debug.getinfo(1,"S").source:match[[^@?(.*[\/])[^\/]-$]] .."?.lua;".. package.path
require 'sr_MIDI functions'

interval = 5 -- semitones

transpose(interval) -- call function
reaper.Undo_OnStateChange2(proj, "Transpose notes 5")
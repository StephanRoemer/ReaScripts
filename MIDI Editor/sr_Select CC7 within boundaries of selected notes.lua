-- @description Select CC7 within boundaries of selected notes
-- @version 1.01
-- @author Stephan Römer
-- @about
--    # Description
--    - this script selects CC7 within boundaries of selected notes
--    - execute again to toggle selection
--    - this script works in arrangement, MIDI Editor and Inline Editor
--
-- @link https://forums.cockos.com/showthread.php?p=1923923
--
-- @provides [main=main,midi_editor,midi_inlineeditor] .
-- @changelog
--     v1.01 (2017-12-19)
--     + fixed wrong assigned CC
--     v1.0
--     + Initial release

package.path = debug.getinfo(1,"S").source:match[[^@?(.*[\/])[^\/]-$]] .."?.lua;".. package.path
require 'sr_MIDI functions'

destCC = 7 -- destination CC

select_CC_within_note_boundaries(destCC) -- call function

reaper.Undo_OnStateChange2(proj, "Select CC7 within boundaries of selected notes")
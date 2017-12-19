-- @description Select CC11 within boundaries of selected notes
-- @version 1.0
-- @author Stephan Römer
-- @about
--    # Description
--    - this script selects CC11 within the boundaries of selected notes
--    - execute again to toggle selection
--    - this script works in arrangement, MIDI Editor and Inline Editor
--
-- @link https://forums.cockos.com/showthread.php?p=1923923
--
-- @provides [main=main,midi_editor,midi_inlineeditor] .
-- @changelog
--     v1.0
--     + Initial release

package.path = debug.getinfo(1,"S").source:match[[^@?(.*[\/])[^\/]-$]] .."?.lua;".. package.path
require 'sr_MIDI functions'

destCC = 11 -- destination CC

select_CC_within_note_boundaries(destCC) -- call function

reaper.Undo_OnStateChange2(proj, "Select CC11 within boundaries of selected notes")
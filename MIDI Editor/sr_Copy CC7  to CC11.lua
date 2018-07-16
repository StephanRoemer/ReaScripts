-- @description Copy CC7 to CC11
-- @version 1.0
-- @author Stephan Römer
-- @about
--    # Description
--    - this script copies CC7 data to CC11
--    - this script works in arrangement, MIDI Editor and Inline Editor
--
-- @link https://forums.cockos.com/showthread.php?p=1923923
--
-- @provides [main=main,midi_editor,midi_inlineeditor] .
-- @changelog
--     v1.0 (2018-07-15)
--     + Initial release

package.path = debug.getinfo(1,"S").source:match[[^@?(.*[\/])[^\/]-$]] .."?.lua;".. package.path
require 'sr_MIDI functions'

srcCC = 7 -- source CC
destCC = 11 -- destination CC

copy_srcCC_to_destCC(srcCC, destCC) -- call function
reaper.Undo_OnStateChange2(proj, "Copy CC7 to CC11")



-- @description Copy CC2 to CC1
-- @version 1.0
-- @author Stephan Römer
-- @about
--    # Description
--    - this script copies CC2 data to CC1
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

srcCC = 2 -- source CC
destCC = 1 -- destination CC

copy_srcCC_to_destCC(srcCC, destCC) -- call function
reaper.Undo_OnStateChange2(proj, "Copy CC2 to CC1")



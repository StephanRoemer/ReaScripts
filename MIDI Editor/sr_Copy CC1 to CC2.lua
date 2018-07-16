-- @description Copy CC1 to CC2
-- @version 1.0
-- @author Stephan Römer
-- @about
--    # Description
--    - this script copies CC1 data to CC2
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

srcCC = 1 -- source CC
destCC = 2 -- destination CC

copy_srcCC_to_destCC(srcCC, destCC) -- call function
reaper.Undo_OnStateChange2(proj, "Copy CC1 to CC2")



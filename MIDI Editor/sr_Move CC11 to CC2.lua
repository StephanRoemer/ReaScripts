-- @description Move CC11 to CC2
-- @version 1.1
-- @author Stephan Römer
-- @about
--    # Description
--    - this script moves CC11 data to CC2
--    - this script works in arrangement, MIDI Editor and Inline Editor
--
-- @link https://forums.cockos.com/showthread.php?p=1923923
--
-- @provides [main=main,midi_editor,midi_inlineeditor]
-- @changelog
--     v1.0
--     + Initial release
--     v1.1 (2017-12-15)
--     + moved the functions to a seperate file "sr_MIDI functions"

package.path = debug.getinfo(1,"S").source:match[[^@?(.*[\/])[^\/]-$]] .."?.lua;".. package.path
require 'sr_MIDI functions'

srcCC = 11
destCC = 2

move_srcCC_to_destCC(srcCC, destCC)



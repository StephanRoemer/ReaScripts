-- @description Move CC11 to CC1
-- @version 1.11
-- @author Stephan Römer
-- @about
--    # Description
--    - this script moves CC11 data to CC1
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

srcCC = 11 -- source CC
destCC = 1 -- destination CC

move_srcCC_to_destCC(srcCC, destCC) -- call function
reaper.Undo_OnStateChange2(proj, "Move CC11 to CC1")



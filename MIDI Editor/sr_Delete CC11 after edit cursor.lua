-- @noindex
-- @description Delete CC11 after edit cursor
-- @version 1.0
-- @author Stephan Römer
-- @about
--    # Description
--    - this script deletes the CC11 data after the edit cursor
--    - this script works in arrangement, MIDI Editor and Inline Editor
--
-- @link https://forums.cockos.com/showthread.php?p=1923923
--

-- @changelog
--     v1.0
--     + Initial release
--     v1.1 (2017-12-15)
--     + moved the functions to a seperate file "sr_MIDI functions"

package.path = debug.getinfo(1,"S").source:match[[^@?(.*[\/])[^\/]-$]] .."?.lua;".. package.path
require 'sr_MIDI functions'

destCC = 11 -- destination CC

delete_CC_after_edit_cursor(destCC)
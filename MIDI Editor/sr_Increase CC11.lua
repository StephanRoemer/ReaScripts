-- @noindex
-- @description Increase CC11
-- @version 1.0
-- @author Stephan Römer
-- @about
--    # Description
--    - this script increases all values from the CC11 lane
--    - this script works in arrangement, MIDI Editor and Inline Editor
--
-- @link https://forums.cockos.com/showthread.php?p=1923923
--

-- @changelog
--     + Initial release

package.path = debug.getinfo(1,"S").source:match[[^@?(.*[\/])[^\/]-$]] .."?.lua;".. package.path
require 'sr_MIDI functions'

increase = 1.1 -- value to increase the CC event
destCC = 11 -- destination CC

increase_CC(destCC, increase)





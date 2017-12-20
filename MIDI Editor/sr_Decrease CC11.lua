-- @description Decrease CC11
-- @version 1.1
-- @author Stephan Römer
-- @about
--    # Description
--    - this script decreases all or selected CC events in the CC1 lane
--    - this script works in arrangement, MIDI Editor and Inline Editor
--
-- @link https://forums.cockos.com/showthread.php?p=1923923
--
-- @provides [main=main,midi_editor,midi_inlineeditor] .
-- @changelog
--     v1.1 (2017-12-16)
--     + added undo state
--     v1.0
--     + Initial release

package.path = debug.getinfo(1,"S").source:match[[^@?(.*[\/])[^\/]-$]] .."?.lua;".. package.path
require 'sr_MIDI functions'

decrease = 1.1 -- value to increase the CC event
destCC = 11 -- destination CC

decrease_CC(destCC, decrease) -- call function
reaper.Undo_OnStateChange2(proj, "Decrease CC11")


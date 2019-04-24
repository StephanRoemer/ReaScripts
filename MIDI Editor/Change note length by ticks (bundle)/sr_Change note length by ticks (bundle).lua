-- @description Change note length by ticks (bundle)
-- @version 1.0
-- @changelog
--   * initial release
-- @author Stephan Römer
-- @metapackage
-- @provides
--  [nomain] .
--  [main=main,midi_editor,midi_inlineeditor] sr_Change note length - lengthen by 10 ticks.lua
--  [main=main,midi_editor,midi_inlineeditor] sr_Change note length - shorten by 10 ticks.lua
--  [nomain] sr_Change note length by ticks function.lua
-- @about
--    # Description
--    * These scripts will change the note length by ticks.
--    * In the arrange view (item view), selected events are not taken into account, because you can't see what is selected.
--    * In the inline editor, you MUST hover the mouse over the active inline editor, otherwise ALL events will 
--    be affected, instead of only the selected ones.
--    * When hovering an inline editor, only the take under the mouse cursor will be affected, regardles of the item selection.
--    * You can easily customize the values in the scripts.
--    * The scripts work in the MIDI editor, inline editor and arrange view.
-- @link Forum Thread https://forums.cockos.com/showthread.php?p=1923923
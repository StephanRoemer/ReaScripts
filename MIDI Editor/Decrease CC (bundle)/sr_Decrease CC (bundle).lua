-- @description Decrease CC (bundle)
-- @version 1.61
-- @changelog
--   * the undo function now uses the variable to describe the CC
-- @author Stephan Römer
-- @metapackage
-- @provides
--  [nomain] .
--  [main=main,midi_editor,midi_inlineeditor] sr_Decrease CC1.lua
--  [main=main,midi_editor,midi_inlineeditor] sr_Decrease CC2.lua
--  [main=main,midi_editor,midi_inlineeditor] sr_Decrease CC7.lua
--  [main=main,midi_editor,midi_inlineeditor] sr_Decrease CC11.lua
--  [nomain] sr_Decrease CC function.lua
-- @about
--    # Description
--    * These scripts decrease all or selected events in a specific CC lane in one or multiple items.
--    * In the arrange view (item view), selected events are not taken into account, because you can't see what is selected.
--    * In the inline editor, you MUST hover the mouse over the active inline editor, otherwise ALL events will 
--    be affected, instead of only the selected ones.
--    * When hovering an inline editor, only the take under the mouse cursor will be affected, regardles of the item selection.
--    * You can easily customize the values in the scripts.
--    * The scripts work in the MIDI editor, inline editor and arrange view.
-- @link Forum Thread https://forums.cockos.com/showthread.php?p=1923923
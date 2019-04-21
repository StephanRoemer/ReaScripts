-- @description Move CC to CC (bundle)
-- @version 1.60
-- @changelog
--   + the scripts are now located in their own folder
--   * smaller bug fixes and improvements
-- @author Stephan Römer
-- @metapackage
-- @provides
--  [nomain] .
--  [main=main,midi_editor,midi_inlineeditor] sr_Move CC1 to CC2.lua
--  [main=main,midi_editor,midi_inlineeditor] sr_Move CC1 to CC7.lua
--  [main=main,midi_editor,midi_inlineeditor] sr_Move CC1 to CC11.lua
--  [main=main,midi_editor,midi_inlineeditor] sr_Move CC2 to CC1.lua
--  [main=main,midi_editor,midi_inlineeditor] sr_Move CC2 to CC7.lua
--  [main=main,midi_editor,midi_inlineeditor] sr_Move CC2 to CC11.lua
--  [main=main,midi_editor,midi_inlineeditor] sr_Move CC7 to CC1.lua
--  [main=main,midi_editor,midi_inlineeditor] sr_Move CC7 to CC2.lua
--  [main=main,midi_editor,midi_inlineeditor] sr_Move CC7 to CC11.lua
--  [main=main,midi_editor,midi_inlineeditor] sr_Move CC11 to CC1.lua
--  [main=main,midi_editor,midi_inlineeditor] sr_Move CC11 to CC2.lua
--  [main=main,midi_editor,midi_inlineeditor] sr_Move CC11 to CC7.lua
--  [nomain] sr_Move CC to CC function.lua
-- @about
--    # Description
--    * These scripts move all or selected events from CC X to CC Y in one or multiple items.
--    * In the arrange view (item view), selected events are not taken into account, because you can't see what is selected.
--    * In the inline editor, you MUST hover the mouse over the active inline editor, otherwise ALL events will 
--    be affected, instead of only the selected ones.
--    * When hovering an inline editor, only the take under the mouse cursor will be affected, regardles of the item selection.
--    * You can easily customize the values in the scripts.
--    * The scripts work in the MIDI editor, inline editor and arrange view.
-- @link Forum Thread https://forums.cockos.com/showthread.php?p=1923923
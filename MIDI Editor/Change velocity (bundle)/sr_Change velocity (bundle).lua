-- @description Change velocity (bundle)
-- @version 1.52
-- @changelog
--   + the scripts are now located in their own folder
--   * smaller bug fixes and improvements
-- @author Stephan Römer
-- @metapackage
-- @provides
--  [main=main,midi_editor,midi_inlineeditor] Change velocity (bundle)/sr_Change velocity -1.lua
--  [main=main,midi_editor,midi_inlineeditor] Change velocity (bundle)/sr_Change velocity +1.lua
--  [main=main,midi_editor,midi_inlineeditor] Change velocity (bundle)/sr_Change velocity +2.lua
--  [main=main,midi_editor,midi_inlineeditor] Change velocity (bundle)/sr_Change velocity -2.lua
--  [main=main,midi_editor,midi_inlineeditor] Change velocity (bundle)/sr_Change velocity +5.lua
--  [main=main,midi_editor,midi_inlineeditor] Change velocity (bundle)/sr_Change velocity -5.lua
--  [main=main,midi_editor,midi_inlineeditor] Change velocity (bundle)/sr_Change velocity +6.lua
--  [main=main,midi_editor,midi_inlineeditor] Change velocity (bundle)/sr_Change velocity -6.lua
--  [nomain] Change velocity (bundle)/sr_Change velocity (bundle).lua
--  [nomain] Change velocity (bundle)/sr_Change velocity function.lua
-- @about
--    # Description
--    * These scripts increase/decrease the velocity of either all notes or selected notes in one or multiple items.
--    * In the arrange view (item view), selected events are not taken into account, because you can't see what is selected.
--    * In the inline editor, you MUST hover the mouse over the active inline editor, otherwise ALL events will 
--    be affected, instead of only the selected ones.
--    * When hovering an inline editor, only the take under the mouse cursor will be affected, regardles of the item selection.
--    * You can easily customize the values in the scripts.
--    * The scripts work in the MIDI editor, inline editor and arrange view.
-- @link Forum Thread https://forums.cockos.com/showthread.php?p=1923923
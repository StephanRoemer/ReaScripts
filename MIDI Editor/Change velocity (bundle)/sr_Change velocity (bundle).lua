-- @description Change velocity (bundle)
-- @version 1.71
-- @changelog
--   + Razor selection fix
-- @author Stephan Römer
-- @link Forum Thread https://forums.cockos.com/showthread.php?p=1923923
-- @metapackage
-- @provides
--  [main=main,midi_editor,midi_inlineeditor] sr_Change velocity -1.lua
--  [main=main,midi_editor,midi_inlineeditor] sr_Change velocity +1.lua
--  [main=main,midi_editor,midi_inlineeditor] sr_Change velocity +2.lua
--  [main=main,midi_editor,midi_inlineeditor] sr_Change velocity -2.lua
--  [main=main,midi_editor,midi_inlineeditor] sr_Change velocity +5.lua
--  [main=main,midi_editor,midi_inlineeditor] sr_Change velocity -5.lua
--  [main=main,midi_editor,midi_inlineeditor] sr_Change velocity +6.lua
--  [main=main,midi_editor,midi_inlineeditor] sr_Change velocity -6.lua
--  [nomain] sr_Change velocity (bundle).lua
--  [nomain] sr_Change velocity function.lua
-- @about
--    # Description
--
--    * These scripts increase/decrease the velocity of either all notes (in arrange / razor selection) or selected / all notes in the MIDI editors.
--    * In the inline editor, you MUST hover the mouse over the active inline editor, otherwise ALL events will 
--    be affected, instead of only the selected ones.
--    * When hovering an inline editor, only the take under the mouse cursor will be affected, regardles of the item selection.
--    * You can easily customize the values in the scripts in the "User Configuration Area" and create your own presets.
--    * The scripts work in the MIDI editor, inline editor and arrange view. Razor selection is also supported.

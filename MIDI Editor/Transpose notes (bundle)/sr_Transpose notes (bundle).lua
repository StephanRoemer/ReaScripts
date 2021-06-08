-- @description Transpose notes (bundle)
-- @version 1.71
-- @changelog
--   + Support for multiple items opened in the MIDI editor 
-- @author Stephan Römer
-- @link Forum Thread https://forums.cockos.com/showthread.php?p=1923923
-- @metapackage
-- @provides
--  [main=main,midi_editor,midi_inlineeditor] sr_Transpose notes -1.lua
--  [main=main,midi_editor,midi_inlineeditor] sr_Transpose notes -2.lua
--  [main=main,midi_editor,midi_inlineeditor] sr_Transpose notes -3.lua
--  [main=main,midi_editor,midi_inlineeditor] sr_Transpose notes -4.lua
--  [main=main,midi_editor,midi_inlineeditor] sr_Transpose notes -5.lua
--  [main=main,midi_editor,midi_inlineeditor] sr_Transpose notes -6.lua
--  [main=main,midi_editor,midi_inlineeditor] sr_Transpose notes -7.lua
--  [main=main,midi_editor,midi_inlineeditor] sr_Transpose notes -8.lua
--  [main=main,midi_editor,midi_inlineeditor] sr_Transpose notes -9.lua
--  [main=main,midi_editor,midi_inlineeditor] sr_Transpose notes -10.lua
--  [main=main,midi_editor,midi_inlineeditor] sr_Transpose notes -11.lua
--  [main=main,midi_editor,midi_inlineeditor] sr_Transpose notes -12.lua
--  [main=main,midi_editor,midi_inlineeditor] sr_Transpose notes +1.lua
--  [main=main,midi_editor,midi_inlineeditor] sr_Transpose notes +2.lua
--  [main=main,midi_editor,midi_inlineeditor] sr_Transpose notes +3.lua
--  [main=main,midi_editor,midi_inlineeditor] sr_Transpose notes +4.lua
--  [main=main,midi_editor,midi_inlineeditor] sr_Transpose notes +5.lua
--  [main=main,midi_editor,midi_inlineeditor] sr_Transpose notes +6.lua
--  [main=main,midi_editor,midi_inlineeditor] sr_Transpose notes +7.lua
--  [main=main,midi_editor,midi_inlineeditor] sr_Transpose notes +8.lua
--  [main=main,midi_editor,midi_inlineeditor] sr_Transpose notes +9.lua
--  [main=main,midi_editor,midi_inlineeditor] sr_Transpose notes +10.lua
--  [main=main,midi_editor,midi_inlineeditor] sr_Transpose notes +11.lua
--  [main=main,midi_editor,midi_inlineeditor] sr_Transpose notes +12.lua
--  [nomain] sr_Transpose notes (bundle).lua
--  [nomain] sr_Transpose notes function.lua
-- @about
--    # Description
-- 
--    * These scripts transposes either all notes (in arrange / razor selection) or selected / all notes in the MIDI editors.
--    * In the inline editor, you MUST hover the mouse over the active inline editor, otherwise ALL events will 
--    be affected, instead of only the selected ones.
--    * When hovering an inline editor, only the take under the mouse cursor will be affected, regardles of the item selection.
--    * You can easily customize the values in the scripts in the "User Configuration Area" and create your own presets.
--    * The scripts work in the MIDI editor, inline editor and arrange view. Razor selection is also supported.

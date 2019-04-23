-- @description Quantize note start to closest grid (bundle)
-- @version 1.1
-- @changelog
--   * minor fixes
-- @author Stephan Römer
-- @metapackage
-- @provides
--  [nomain] .
--  [main=main,midi_editor,midi_inlineeditor] sr_Quantize note start to closest grid - 1-1.lua
--  [main=main,midi_editor,midi_inlineeditor] sr_Quantize note start to closest grid - 1-2.lua
--  [main=main,midi_editor,midi_inlineeditor] sr_Quantize note start to closest grid - 1-4.lua
--  [main=main,midi_editor,midi_inlineeditor] sr_Quantize note start to closest grid - 1-4 triplets.lua
--  [main=main,midi_editor,midi_inlineeditor] sr_Quantize note start to closest grid - 1-8.lua
--  [main=main,midi_editor,midi_inlineeditor] sr_Quantize note start to closest grid - 1-8 triplets.lua
--  [main=main,midi_editor,midi_inlineeditor] sr_Quantize note start to closest grid - 1-16.lua
--  [main=main,midi_editor,midi_inlineeditor] sr_Quantize note start to closest grid - 1-16 triplets.lua
--  [main=main,midi_editor,midi_inlineeditor] sr_Quantize note start to closest grid - grid.lua
--  [nomain] sr_Quantize note start to closest grid function.lua
-- @about
--    # Description
--    * This script quantizes note end (to closest grid) of either all notes or selected notes in one or multiple items.
--    * In the arrange view (item view), selected events are not taken into account, because you can't see what is selected.
--    * In the inline editor, you MUST hover the mouse over the active inline editor, otherwise ALL events will 
--    be affected, instead of only the selected ones.
--    * When hovering an inline editor, only the take under the mouse cursor will be affected, regardles of the item selection.
--    * You can easily customize the values in the scripts.
--    * The scripts work in the MIDI editor, inline editor and arrange view.
-- @link https://forums.cockos.com/showthread.php?p=1923923
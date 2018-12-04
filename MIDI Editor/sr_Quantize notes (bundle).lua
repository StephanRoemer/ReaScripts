-- @description Quantize notes (bundle)
-- @version 1.31
-- @changelog
--   switched from SnapToGrid() to BR_GetClosestGridDivision(), as this function will always snap to grid, 
--   even if the gridlines are not visible due to zoom factor. Thanks to X-Raym, for the heads up!
-- @author Stephan Römer
-- @metapackage
-- @provides
--  [main=main,midi_editor,midi_inlineeditor] sr_Quantize notes - 1-1.lua
--  [main=main,midi_editor,midi_inlineeditor] sr_Quantize notes - 1-2.lua
--  [main=main,midi_editor,midi_inlineeditor] sr_Quantize notes - 1-4.lua
--  [main=main,midi_editor,midi_inlineeditor] sr_Quantize notes - 1-4 swing 70 percent.lua
--  [main=main,midi_editor,midi_inlineeditor] sr_Quantize notes - 1-4 triplets.lua
--  [main=main,midi_editor,midi_inlineeditor] sr_Quantize notes - 1-8.lua
--  [main=main,midi_editor,midi_inlineeditor] sr_Quantize notes - 1-8 swing 70 percent.lua
--  [main=main,midi_editor,midi_inlineeditor] sr_Quantize notes - 1-8 triplets.lua
--  [main=main,midi_editor,midi_inlineeditor] sr_Quantize notes - 1-16.lua
--  [main=main,midi_editor,midi_inlineeditor] sr_Quantize notes - 1-16 swing 70 percent.lua
--  [main=main,midi_editor,midi_inlineeditor] sr_Quantize notes - 1-16 triplets.lua
--  [main=main,midi_editor,midi_inlineeditor] sr_Quantize notes - grid.lua
--  [nomain] sr_Quantize notes (bundle).lua
--  [nomain] sr_Quantize notes function.lua
-- @about
--    # Description
--    * This script bundle consists of various quantize scripts that affect either all or selected notes
--    * You can easily edit the scripts to adjust them to your needs or create new ones
--    * The scripts work in arrangement, MIDI Editor and Inline Editor
-- @link Forum Thread https://forums.cockos.com/showthread.php?p=1923923
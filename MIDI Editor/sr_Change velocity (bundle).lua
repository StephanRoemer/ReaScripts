-- @description Change velocity (bundle)
-- @version 1.0
-- @changelog
--   initial release
-- @author Stephan Römer
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
--    * This script bundles consists of 2 scripts that nudges either all notes or selected notes left/right.
--    * The amount of ticks can be adjusted in the scripts. That way, you can easily create different versions
--      that fit your personal needs. 
--    * The scripts work in arrangement, MIDI Editor and Inline Editor
-- @link Forum Thread https://forums.cockos.com/showthread.php?p=1923923
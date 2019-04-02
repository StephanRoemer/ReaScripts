-- @description Add notes interval (bundle)
-- @version 1.42
-- @changelog
--   + code optimization
-- @author Stephan Römer
-- @metapackage
-- @provides
--  [main=main,midi_editor,midi_inlineeditor] sr_Add notes -24.lua
--  [main=main,midi_editor,midi_inlineeditor] sr_Add notes -12.lua
--  [main=main,midi_editor,midi_inlineeditor] sr_Add notes +12.lua
--  [main=main,midi_editor,midi_inlineeditor] sr_Add notes +24.lua
--  [nomain] sr_Add notes interval (bundle).lua
--  [nomain] sr_Add notes interval function.lua
-- @about
--    # Description
--    * This script bundle consists of scripts that add intervals to either all or only selected notes.
--    * If you add intervals from the arrangement, selected notes are not taken into account, because you can't see what is selected from
--    the arrangement. If you want to add intervals from the inline editor, you MUST hover the mouse over the active inline editor, otherwise 
--    ALL notes will be affected, instead of only the selected ones.
--    * You can easily edit the scripts to adjust them to your needs or create new ones
--    * The scripts work in arrangement, MIDI editor and inline editor.
-- @link Forum Thread https://forums.cockos.com/showthread.php?p=1923923
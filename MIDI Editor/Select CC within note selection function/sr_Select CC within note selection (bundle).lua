-- @description Select CC within note selection (bundle)
-- @version 1.60
-- @changelog
--   + switched to MIDI_SetAllEvts
--   + the scripts are now located in their own folder
--   * smaller bug fixes and improvements
-- @author Stephan Römer
-- @metapackage
-- @provides
--  [nomain] .
--  [main=main,midi_editor,midi_inlineeditor] sr_Select CC1 within note selection.lua
--  [main=main,midi_editor,midi_inlineeditor] sr_Select CC2 within note selection.lua
--  [main=main,midi_editor,midi_inlineeditor] sr_Select CC7 within note selection.lua
--  [main=main,midi_editor,midi_inlineeditor] sr_Select CC11 within note selection.lua
--  [main=main,midi_editor,midi_inlineeditor] sr_Select CC64 within note selection.lua
--  [nomain] sr_Select CC within note selection function.lua
-- @about
--    # Description
--    * These scripts select the CC events within the boundaries of a note selection in the current take
--    * Only continous note selections will work (no gaps) in order to select the CCs, since the first
--    and last selected note set the selection boundary.
--    * You can easily customize the values in the scripts.
--    * The scripts work in the MIDI editor and inline editor.
-- @link Forum Thread https://forums.cockos.com/showthread.php?p=1923923
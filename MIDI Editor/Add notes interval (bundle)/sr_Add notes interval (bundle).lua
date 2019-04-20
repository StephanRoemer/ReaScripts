-- @description Add notes interval (bundle)
-- @version 1.52
-- @changelog
--   + the scripts are now located in their own folder
--   * smaller bug fixes and improvements
-- @author Stephan Römer
-- @metapackage
-- @provides
--  [main=main,midi_editor,midi_inlineeditor] . > Add notes interval (bundle)/sr_Add notes -24.lua
--  [main=main,midi_editor,midi_inlineeditor] . > Add notes interval (bundle)/sr_Add notes -12.lua
--  [main=main,midi_editor,midi_inlineeditor] . > Add notes interval (bundle)/sr_Add notes +12.lua
--  [main=main,midi_editor,midi_inlineeditor] . > Add notes interval (bundle)/sr_Add notes +24.lua
--  [nomain] . > Add notes interval (bundle)/sr_Add notes interval (bundle).lua
--  [nomain] . > Add notes interval (bundle)/sr_Add notes interval function.lua
-- @about
--    # Description
--    * These scripts add note intervals to all or selected events in a specific CC lane in one or multiple items.
--    * In the arrange view (item view), selected events are not taken into account, because you can't see what is selected.
--    * In the inline editor, you MUST hover the mouse over the active inline editor, otherwise ALL events will 
--    be affected, instead of only the selected ones.
--    * When hovering an inline editor, only the take under the mouse cursor will be affected, regardles of the item selection.
--    * You can easily customize the values in the scripts.
--    * The scripts work in the MIDI editor, inline editor and arrange view.
-- @link Forum Thread https://forums.cockos.com/showthread.php?p=1923923

local script_name = ({reaper.get_action_context()})[2]:match("([^/\\_]+)%.lua$")
local notes = tonumber(script_name:match("Add notes (%-?%d+)"))
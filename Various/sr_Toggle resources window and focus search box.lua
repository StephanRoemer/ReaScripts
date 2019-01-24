-- @description Zoom MIDI editor to content
-- @version 1.0
-- @changelog
--   initial release
-- @author Stephan Römer
-- @provides [main=midi_editor] .
-- @about
--    # Description
--    * This script zooms to the content of the MIDI item, without changing the horizontal zoom of the notes
--    * This script works only in the MIDI editor
-- @link https://forums.cockos.com/showthread.php?p=1923923

reaper.Main_OnCommand(reaper.NamedCommandLookup("_S&M_SHOW_RESOURCES_VIEW"), 0) -- open/close resources window

local title = reaper.JS_Localize("Resources", "common") -- get localized window title
local resources = reaper.JS_Window_Find(title, true)    -- find window
local search = reaper.JS_Window_FindChildByID(resources, 1126) -- get search box

if search then -- if search box can be retrieved
    reaper.JS_Window_SetFocus(search) -- focus search box
end

-- @description Toggle resources window and focus search box
-- @version 1.0
-- @changelog
--   initial release
-- @author Stephan Römer
-- @provides [main=main] .
-- @about
--    # Description
--    * This script toggles the resources window and puts the focus on the search box
--    * This script works only in the arrangement
-- @link https://forums.cockos.com/showthread.php?p=1923923


reaper.Main_OnCommand(reaper.NamedCommandLookup("_S&M_SHOW_RESOURCES_VIEW"), 0) -- open/close resources window

local title = reaper.JS_Localize("Resources", "common") -- get localized window title
local resources = reaper.JS_Window_Find(title, true)    -- find window
local search = reaper.JS_Window_FindChildByID(resources, 1126) -- get search box

if search then -- if search box can be retrieved
    reaper.JS_Window_SetFocus(search) -- focus search box
end

-- @description Toggle show UI of all FX in send track
-- @version 1.1
-- @changelog
--   switched to external function file and put all scripts in a bundle
-- @author Stephan Römer
-- @provides
--  . > sr_Toggle show UI of all FX in send function.lua
-- 	. > sr_Toggle show UI of all FX in send 1.lua
-- 	. > sr_Toggle show UI of all FX in send 2.lua
-- 	. > sr_Toggle show UI of all FX in send 3.lua
-- 	. > sr_Toggle show UI of all FX in send 4.lua
-- @about
--   # Description
--   This script bundle consists of 4 scripts that shows/hide the UI of all FX in send 1-4
-- @link Forum Thread https://forums.cockos.com/showthread.php?p=1923923

package.path = debug.getinfo(1,"S").source:match[[^@?(.*[\/])[^\/]-$]] .."?.lua;".. package.path
require 'sr_Toggle show UI of all FX in send slots'

local send_slot = 3 -- 3rd send slot

ToggleShowUISend(send_slot) -- call function
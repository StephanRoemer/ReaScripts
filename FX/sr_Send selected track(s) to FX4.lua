-- @description Send selected track(s) to FX track
-- @version 1.11
-- @changelog
--   switched to external function file and put all scripts in a bundle
-- @author Stephan Römer
-- @provides
-- 	. > sr_Send selected track(s) to FX function.lua
-- 	. > sr_Send selected track(s) to FX1.lua
-- 	. > sr_Send selected track(s) to FX2.lua
-- 	. > sr_Send selected track(s) to FX3.lua
-- 	. > sr_Send selected track(s) to FX4.lua
-- @about
--   # Description
--   This script bundle consists of 4 scripts that will send all selected tracks to an FX track prefixed with FX1-4
-- @link Forum Thread https://forums.cockos.com/showthread.php?p=1923923

package.path = debug.getinfo(1,"S").source:match[[^@?(.*[\/])[^\/]-$]] .."?.lua;".. package.path
require 'sr_Send selected tracks to FX'

local send_fx_prefix = "FX4" -- send FX4

SendTrackToFX(send_fx_prefix) -- call function
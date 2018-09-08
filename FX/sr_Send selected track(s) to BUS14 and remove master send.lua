-- @description Send selected track(s) to BUS track and remove master send
-- @version 1.0
-- @changelog
--   Initial release
-- @author Stephan Römer
-- @provides
-- 	. > sr_Send selected track(s) to BUS and remove master send function.lua
-- 	. > sr_Send selected track(s) to BUS01 and remove master send.lua
-- 	. > sr_Send selected track(s) to BUS02 and remove master send.lua
-- 	. > sr_Send selected track(s) to BUS03 and remove master send.lua
-- 	. > sr_Send selected track(s) to BUS04 and remove master send.lua
-- 	. > sr_Send selected track(s) to BUS05 and remove master send.lua
-- 	. > sr_Send selected track(s) to BUS06 and remove master send.lua
-- 	. > sr_Send selected track(s) to BUS07 and remove master send.lua
-- 	. > sr_Send selected track(s) to BUS08 and remove master send.lua
-- 	. > sr_Send selected track(s) to BUS09 and remove master send.lua
-- 	. > sr_Send selected track(s) to BUS10 and remove master send.lua
-- 	. > sr_Send selected track(s) to BUS11 and remove master send.lua
-- 	. > sr_Send selected track(s) to BUS12 and remove master send.lua
-- 	. > sr_Send selected track(s) to BUS13 and remove master send.lua
-- 	. > sr_Send selected track(s) to BUS14 and remove master send.lua
-- 	. > sr_Send selected track(s) to BUS15 and remove master send.lua
-- 	. > sr_Send selected track(s) to BUS16 and remove master send.lua
-- @about
--   # Description
--  This script bundle consists of 16 scripts that will send all selected tracks 
--  to a BUS track prefixed with BUS01-16 and remove the parent/master send
-- @link Forum Thread https://forums.cockos.com/showthread.php?p=1923923

package.path = debug.getinfo(1,"S").source:match[[^@?(.*[\/])[^\/]-$]] .."?.lua;".. package.path
require 'sr_Send selected track(s) to BUS and remove master send function'

local bus_prefix = "BUS14"

SendTrackToBUS(bus_prefix) -- call function
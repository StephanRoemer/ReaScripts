-- @description Remove send from selected track(s)
-- @version 1.1
-- @changelog
--   switched to external function file and put all scripts in a bundle
-- @author Stephan Römer
-- @provides
-- 	. > sr_Remove send from selected track(s) function
-- 	. > sr_Remove send 1 from selected track(s)
-- 	. > sr_Remove send 2 from selected track(s)
-- 	. > sr_Remove send 3 from selected track(s)
-- 	. > sr_Remove send 4 from selected track(s)
-- @about
--   # Description
--   This script bundle consists of 4 scripts that remove sends 1-4 from the selected track(s)
-- @link Forum Thread https://forums.cockos.com/showthread.php?p=1923923

package.path = debug.getinfo(1,"S").source:match[[^@?(.*[\/])[^\/]-$]] .."?.lua;".. package.path
require 'sr_Remove send from selected tracks function'

local send_number = 4

RemoveSend(send_number) -- call function

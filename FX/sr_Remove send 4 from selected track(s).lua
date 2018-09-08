-- @noindex

package.path = debug.getinfo(1,"S").source:match[[^@?(.*[\/])[^\/]-$]] .."?.lua;".. package.path
require 'sr_Remove send from selected tracks function'

local send_number = 4

RemoveSend(send_number) -- call function

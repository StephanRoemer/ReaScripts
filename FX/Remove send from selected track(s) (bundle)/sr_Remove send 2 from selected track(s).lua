-- @noindex

package.path = debug.getinfo(1,"S").source:match[[^@?(.*[\/])[^\/]-$]] .."?.lua;".. package.path
require 'sr_Remove send from selected track(s) function'

local send_number = 2

RemoveSend(send_number) -- call function

-- @noindex

package.path = debug.getinfo(1,"S").source:match[[^@?(.*[\/])[^\/]-$]] .."?.lua;".. package.path
require 'sr_Toggle show UI of all FX in send function'

local send_slot = 2 -- 2nd send slot

ToggleShowUISend(send_slot) -- call function
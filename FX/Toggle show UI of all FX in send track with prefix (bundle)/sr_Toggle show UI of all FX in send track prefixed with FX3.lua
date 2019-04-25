-- @noindex

package.path = debug.getinfo(1,"S").source:match[[^@?(.*[\/])[^\/]-$]] .."?.lua;".. package.path
require 'sr_Toggle show UI of all FX in send track with prefix function'

local send_prefix = "FX3" -- send prefixed with FX3

ToggleShowUISend(send_prefix) -- call function
-- @noindex

package.path = debug.getinfo(1,"S").source:match[[^@?(.*[\/])[^\/]-$]] .."?.lua;".. package.path
require 'sr_Send selected track(s) to FX track function'

local send_fx_prefix = "FX2" -- send FX2

SendTrackToFX(send_fx_prefix) -- call function
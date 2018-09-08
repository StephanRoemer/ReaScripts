-- @noindex

package.path = debug.getinfo(1,"S").source:match[[^@?(.*[\/])[^\/]-$]] .."?.lua;".. package.path
require 'sr_Send selected tracks to FX'

local send_fx_prefix = "FX3" -- send FX3

SendTrackToFX(send_fx_prefix) -- call function
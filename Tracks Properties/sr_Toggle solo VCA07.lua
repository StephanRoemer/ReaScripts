-- @noindex

package.path = debug.getinfo(1,"S").source:match[[^@?(.*[\/])[^\/]-$]] .."?.lua;".. package.path
require 'sr_Toggle solo by track prefix function'

local track_prefix = "VCA07"

ToggleSoloTrack(track_prefix) -- call function
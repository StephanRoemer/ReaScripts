-- @noindex

package.path = debug.getinfo(1,"S").source:match[[^@?(.*[\/])[^\/]-$]] .."?.lua;".. package.path
require 'sr_Toggle mute by track prefix function'

local track_prefix = "VCA08"

ToggleMuteTrack(track_prefix) -- call function
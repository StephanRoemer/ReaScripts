--  @noindex

package.path = debug.getinfo(1,"S").source:match[[^@?(.*[\/])[^\/]-$]] .."?.lua;".. package.path
require 'sr_Quantize notes function'

Quantize() -- call function
reaper.Undo_OnStateChange2(proj, "Quantize notes - grid")
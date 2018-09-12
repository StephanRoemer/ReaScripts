--  @noindex

package.path = debug.getinfo(1,"S").source:match[[^@?(.*[\/])[^\/]-$]] .."?.lua;".. package.path
require 'sr_Human quantize notes function'

humanize = 50 -- humanize value in percent

HumanQuantize(humanize) -- call function
reaper.Undo_OnStateChange2(proj, "Human Quantize notes 50% - grid")
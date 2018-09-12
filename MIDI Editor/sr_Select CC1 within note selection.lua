--  @noindex

package.path = debug.getinfo(1,"S").source:match[[^@?(.*[\/])[^\/]-$]] .."?.lua;".. package.path
require 'sr_Select CC within note selection function'

dest_cc = 1 -- destination CC

SelectCCWithinNoteSelection(dest_cc) -- call function

reaper.Undo_OnStateChange2(proj, "Select CC1 within note selection")
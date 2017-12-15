-- @description Edit cursor follows start of item
-- @version 1.0    
-- @author Stephan Römer
-- @about
--    # Description
--    - this script mimics the behaviour of Nuendo's Edit Mode. You select an item, execute the script 
--      and move/nudge the item with the mouse. As result, the edit cursor will snap to the start of the 
--      item and follow your mouse movement.
--    - the script is executed as an endless loop, so you have to terminate it, when you are done. 
--      Best is, to assign it as a shortcut and terminate it when pressing the shortcut again.
--
-- @link https://forums.cockos.com/showpost.php?p=1909014&postcount=6
--
-- @changelog
-- 	  + Initial release


loopcount=0

function runloop()
  
  loopcount=loopcount+1
  if loopcount >= 1 then
    loopcount=0
    item = reaper.GetSelectedMediaItem(0, 0)
    item_pos = reaper.GetMediaItemInfo_Value(item, "D_POSITION")
    reaper.SetEditCurPos(item_pos, true, false)
  end
  
  reaper.defer(runloop) 

end

reaper.defer(runloop)
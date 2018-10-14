-- @description Align selected items to item under mouse cursor
-- @version 1.0
-- @changelog
--  initial release
-- @author Stephan Römer
-- @provides [main] .
-- @about
--    # Description
--    * This script aligns selected takes to the take under the mouse
--    * Depending on where the mouse is located (near the start or end of the item), seleczed items will be aligned to their start or end
--    * Items with a snap offset will always be aligned to their offset
--    * This script only works in the Arrangement
-- @link https://forums.cockos.com/showthread.php?p=1923923

_, _, _ = reaper.BR_GetMouseCursorContext() -- initialize mouse context
local dest_item = reaper.BR_GetMouseCursorContext_Item() -- get item under mouse
if dest_item == nil then
    reaper.ShowMessageBox("Please move your mouse over an item", "Error", 0)
    return false
end

local mouse_position =  reaper.BR_PositionAtMouseCursor(false) -- get position in arrangement under mouse
local dest_item_position = reaper.GetMediaItemInfo_Value(dest_item, 'D_POSITION')
local dest_item_length = reaper.GetMediaItemInfo_Value(dest_item, 'D_LENGTH')

local item_count = reaper.CountSelectedMediaItems(0) -- get selected items

if mouse_position < dest_item_position+dest_item_length/2 then -- if mouse hovers the first half of the dest_item
    for i = 0, item_count-1 do
        local item = reaper.GetSelectedMediaItem(0, i)
        local item_snap_offset = reaper.GetMediaItemInfo_Value(item, 'D_SNAPOFFSET') -- get item snap offset
        reaper.SetMediaItemInfo_Value(item, 'D_POSITION', dest_item_position-item_snap_offset) -- align left edge or snap offset of item to start of dest_item
    end
elseif mouse_position > dest_item_position+dest_item_length/2 then -- if mouse hovers the last half of the dest_item
    for i = 0, item_count-1 do
        local item = reaper.GetSelectedMediaItem(0, i)
        local item_snap_offset = reaper.GetMediaItemInfo_Value(item, 'D_SNAPOFFSET')
        local item_length = reaper.GetMediaItemInfo_Value(item, 'D_LENGTH')
        local item_length_diff = dest_item_length - item_length

        if item_snap_offset ~= 0 then -- if there is an offset
            reaper.SetMediaItemInfo_Value(item, 'D_POSITION', dest_item_position+item_length_diff+(item_length-item_snap_offset)) -- align offset of item to end of dest_item
        else -- no offset
            reaper.SetMediaItemInfo_Value(item, 'D_POSITION', dest_item_position+item_length_diff) -- align right item edge to end of dest_item
        end
    end
end

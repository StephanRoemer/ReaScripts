-- @description Trim tail of item(s) and delete item(s) after mouse cursor
-- @version 1.0
-- @changelog
--  * initial release
-- @author Stephan Römer
-- @provides [main=main] .
-- @about
--    # Description
--    * This script trims the tail of all or selected items after the mouse cursor
--    * Additionally, all items located behind the mouse cursor will be deleted
--    * This script only works in the arrangement
-- @link https://forums.cockos.com/showthread.php?p=1923923


-- get selected items and write to table
function GetSelectedItems(num_selected_items)
    
    local item_table = {} -- initialize item_table
    
    for i = 1, num_selected_items do -- iterate thru all selected items
        local item = reaper.GetSelectedMediaItem(0, i-1) -- get every selected item
        item_table[i] = item -- store every item in table
    end
    return item_table
end


-- get all items and write to table
function GetItems(num_items)

    local item_table = {} -- initialize item_table

    for i = 1, num_items do -- iterate thru alle items
        local item = reaper.GetMediaItem(0, i-1) -- get every item
        item_table[i] = item -- store every item in table
    end
    return item_table
end


-- trim tail of items after mouse cursor, snap to grid
function TrimItemsRight(grid, item_table, num_items)
    for i = 1, num_items do -- iterate thru items
        local item_position = reaper.GetMediaItemInfo_Value(item_table[i], 'D_POSITION') -- get item position
        local item_length = reaper.GetMediaItemInfo_Value(item_table[i], 'D_LENGTH') -- get item position

        if grid > item_position and grid < item_position + item_length then  -- if trim-point is within boundaries of item (taking snap into account) -> prevents that item has length = 0
            local tail_item = reaper.SplitMediaItem(item_table[i], grid) -- split item and store tail-item
            reaper.DeleteTrackMediaItem(reaper.GetMediaItem_Track(tail_item), tail_item) -- delete tail-item
        elseif item_position + item_length > grid then -- if items are located after mouse
            reaper.DeleteTrackMediaItem(reaper.GetMediaItem_Track(item_table[i]), item_table[i]) -- delete all items after mouse
        end
    end
end



local mouse_pos = reaper.BR_PositionAtMouseCursor(true) -- get mouse position
local grid = reaper.SnapToGrid(0, mouse_pos) -- get grid position from mouse position

-- check if there are selected items
local num_selected_items = reaper.CountSelectedMediaItems(0)

if num_selected_items > 0 then -- if there are selected items, only affect selected items
    local item_table = GetSelectedItems(num_selected_items) --
    TrimItemsRight(grid, item_table, num_selected_items) -- 
    
else -- if there are no selected items, affect all items
    local num_items = reaper.CountMediaItems(0) --
    local item_table = GetItems(num_items) -- 
    TrimItemsRight(grid, item_table, num_items) -- 
end

reaper.UpdateArrange()
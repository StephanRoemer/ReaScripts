-- @description Set start and end marker to items
-- @version 1.0
-- @changelog
--   Initial release
-- @author Stephan Römer
-- @provides [main].
-- @about
--    # Description
--    * This script will set the start and end marker to all items in the project (excluding the Timecode Generator item). 
--    * This script works only in the arrange view.
-- @link https://forums.cockos.com/showthread.php?p=1923923


-- ================================================================================================================== --
--                                                  Helper Functions                                                  --
-- ================================================================================================================== --


-- -------------------- Get all relevant items to determine project boundaries (exclude MTC item) ------------------- --

local function GetProjectBoundaries()
    
    local num_items = reaper.CountMediaItems(0)
    
    -- get init values from second item in project (first one could be MTC or LTC)
    local item = reaper.GetMediaItem(0, 1)
    local proj_start = reaper.GetMediaItemInfo_Value(item, "D_POSITION")
    local proj_end = proj_start + reaper.GetMediaItemInfo_Value(item, "D_LENGTH")

    -- iterate thru all items to compare all item starts and ends
    for i = 0, num_items-1 do
        
        item = reaper.GetMediaItem(0, i)
        local take = reaper.GetActiveTake(item)
        local item_start = reaper.GetMediaItemInfo_Value(item, "D_POSITION")
        local item_end = item_start + reaper.GetMediaItemInfo_Value(item, "D_LENGTH")
        local _, take_name = reaper.GetSetMediaItemTakeInfo_String(take, "P_NAME", "", 0) 

        if item_start < proj_start and take_name ~= "Timecode Generator" then
            proj_start = item_start
        end
        
        if item_end > proj_end and take_name ~= "Timecode Generator" then
            proj_end = item_end
        end

    end
    return proj_start, proj_end
end


-- ------------------------------------- Get Start and End marker, if they exist ------------------------------------ --

local function GetMarker()
    
    local marker_count = reaper.CountProjectMarkers(0)

    for m = 0, marker_count-1 do
        _, _, marker_pos, _, name, marker_id = reaper.EnumProjectMarkers(m)
        
        if name == "=START" then
            start_marker_pos = marker_pos
            start_id = marker_id
        elseif name == "=END" then
            end_marker_pos = marker_pos
            end_id = marker_id
        end
    end
    return start_marker_pos, start_id, end_marker_pos, end_id
end


-- ================================================================================================================== --
--                                                        Main                                                        --
-- ================================================================================================================== --


local function Main()
    
    local proj_start, proj_end = GetProjectBoundaries()
    local start_marker_pos, start_id, end_marker_pos, end_id = GetMarker()
   
    -- Start marker exists already
    if start_marker_pos ~= nil then
        
        -- New position is different -> change marker to new position
        if start_marker_pos ~= proj_start then
            reaper.SetProjectMarker(start_id, false, proj_start, 0, "=START")
        end
    else -- Start marker doesn't exist
        reaper.AddProjectMarker(0, false, proj_start, 0, "=START", -1, 0)
    end
    
    -- End marker exists already
    if end_marker_pos ~= nil then
        
        -- New position is different -> change marker to new position
        if end_marker_pos ~= proj_start then
            reaper.SetProjectMarker(end_id, false, proj_end, 0, "=END")
        end
    else -- End marker doesn't exist
        reaper.AddProjectMarker(0, false, proj_end, 0, "=END", -1, 0)
    end

end

Main()

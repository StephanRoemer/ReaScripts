-- @noindex

-- check, if the project contains an "Timecode Generator" item

local function Find_TC_Item()
    
    local item_cnt = reaper.CountMediaItems(proj)
    
    for i = 0, item_cnt-1 do
        local item = reaper.GetMediaItem(0, i)
        local take = reaper.GetActiveTake(item)
        
        if reaper.GetTakeName(take) == "Timecode Generator" then
            return item
        end
    end
end


-- if "Timecode Generator" item exists, also set timecode to item

local function Update_TC_Item(item, dest_tc)

    local item_pos = reaper.GetMediaItemInfo_Value(item, "D_POSITION")  -- get item start to make sure, tc gets applied correctly even if item doesn't start on bar 1

    local _, item_chunk = reaper.GetItemStateChunk(item, "", false)
    
    item_chunk = item_chunk:gsub('STARTTIME %d+', 'STARTTIME ' .. dest_tc + item_pos)  -- set project offset to tc item, take item pos into account
    reaper.SetItemStateChunk(item, item_chunk, false)
end


local function Main()

    reaper.PreventUIRefresh(1)

    local path = debug.getinfo(1,"S").source:match[[^@?(.*[\/])[^\/]-$]]  -- get current script path
    local filename = "timecode.txt"


    local main_hwnd = reaper.GetMainHwnd()
    reaper.JS_Window_SetFocus(main_hwnd)

    local f = assert(io.open(path .. filename, "r"))  -- open for read
    local tc = f:read() -- read content of file

    local curpos = reaper.GetCursorPosition()  -- get cursor position in Reaper time
    local tc = reaper.parse_timestr_len(tc, 0, 5)  -- convert "tc" to Reaper time
    local dest_tc = tc - curpos

    reaper.SNM_SetDoubleConfigVar('projtimeoffs', dest_tc)  -- set new project time


    local item = Find_TC_Item()  -- check, if the project contains an "Timecode Generator" item
    if item ~= nil then Update_TC_Item(item, dest_tc) end  -- if "Timecode Generator" item exists, also set timecode to item

    reaper.PreventUIRefresh(-1)
    reaper.UpdateTimeline()
end

Main()
-- @noindex

local path = debug.getinfo(1,"S").source:match[[^@?(.*[\/])[^\/]-$]]  -- get current script path
local filename = "timecode.txt"


local main_hwnd = reaper.GetMainHwnd()
reaper.JS_Window_SetFocus(main_hwnd)

local pos = reaper.GetCursorPosition() -- get edit cursor position
local tc = reaper.format_timestr_pos(pos, '', 5) -- convert position to TC (format hh:mm:ss:ff)

local f = assert(io.open(path .. filename, "w"))  -- open for write
f:write(tc) -- write tc
f:close() -- close file
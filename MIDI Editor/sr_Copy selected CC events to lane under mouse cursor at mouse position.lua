-- @description Copy selected CC events to lane under mouse cursor at mouse position
-- @version 1.0
-- @changelog
--   initial release
-- @author Stephan Römer
-- @provides [main=midi_editor] .
-- @about
--    # Description
--    * This script copies all selected CC events (from all lanes!) to the lane under the mouse cursor, starting at the mouse position
--    * This script works only in the MIDI Editor
-- @link https://forums.cockos.com/showthread.php?p=1923923


local cc_lane -- CC lane under mouse
_, _, _ = reaper.BR_GetMouseCursorContext() -- initiate "get mouse cursor context"
_, _, _, cc_lane, _, _ = reaper.BR_GetMouseCursorContext_MIDI() -- get CC lane
local take = reaper.MIDIEditor_GetTake(reaper.MIDIEditor_GetActive()) -- get active take in MIDI editor
local mouse_pos_ppq_int = math.floor(reaper.MIDI_GetPPQPosFromProjTime(take, reaper.BR_GetMouseCursorContext_Position())) -- get mouse position in project time, convert to PPQ and integer
_, segment, _ = reaper.BR_GetMouseCursorContext() -- get mouse hovering area
local selection_offset_found = false -- initalize

local function CopyCCToLaneUnderMouseAtMouse(cc_lane, take)

    local sum_offset = 0 -- initialize
    local MIDIlen = #MIDIstring -- get string length
    tableEvents = {} -- initialize table, MIDI events will temporarily be stored in this table until they are concatenated into a string again
    local stringPos = 1 -- position in MIDIstring while parsing through events 
    
    while stringPos < MIDIlen-12 do -- parse through all events in the MIDI string, one-by-one, excluding the final 12 bytes, which provides REAPER's All-notes-off end-of-take message

        offset, flags, msg, stringPos = string.unpack("i4Bs4", MIDIstring, stringPos) -- unpack MIDI-string on stringPos
        
        -- add offset until first selected event has been found
        if selection_offset_found == false then 
            sum_offset = sum_offset+offset
        end

        if #msg == 3 -- if msg consists of 3 bytes (= channel message)
        and (msg:byte(1)>>4) == 11 and flags&1 == 1	-- if status byte is a CC and event is selected
        and segment == "cc_lane" -- mouse cursor hovers the cc area
        and mouse_pos_ppq_int > 0 -- mouse cursor after take start (prevents unexpected event chaos)
        then
            if selection_offset_found == false then -- prevents writing "selection_offset_found = true" on each iteration
                selection_offset_found = true -- first selected event found
            end

            table.insert(tableEvents, string.pack("i4Bs4", offset, flags, msg)) -- keep original CC event
            msg_cc_lane = msg:sub(1,1) .. string.char(cc_lane) .. msg:sub(3,3) -- write msg chunk for cc_lane
            table.insert(tableEvents, string.pack("i4Bs4", mouse_pos_ppq_int-sum_offset, flags&~1, msg_cc_lane)) -- copy CC event to mouse cursor, unselect and re-pack MIDI string 
            table.insert(tableEvents, string.pack("i4Bs4", -mouse_pos_ppq_int+sum_offset, 0, "")) -- rectify distance and put an empty event after the new CC event
        else
            table.insert(tableEvents, string.pack("i4Bs4", offset, flags, msg)) -- write all other events back to table
        end
    end
    reaper.MIDI_SetAllEvts(take, table.concat(tableEvents) .. MIDIstring:sub(-12))
    reaper.MIDI_Sort(take)
end


if reaper.TakeIsMIDI(take) then -- make sure, that take is MIDI
    gotAllOK, MIDIstring = reaper.MIDI_GetAllEvts(take, "") -- write MIDI events to MIDIstring, get all events okay
    if not gotAllOK then reaper.ShowMessageBox("Error while loading MIDI", "Error", 0) return(false) end -- if getting the MIDI data failed

    CopyCCToLaneUnderMouseAtMouse(cc_lane, take) -- copy CC events to cc_lane
end

reaper.UpdateArrange()
reaper.Undo_OnStateChange2(proj, "Copy selected CC events to CC"..cc_lane.." lane under mouse cursor at mouse position")
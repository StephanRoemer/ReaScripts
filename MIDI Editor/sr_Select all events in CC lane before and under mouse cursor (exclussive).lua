-- @description Select all events in CC lane before and under mouse cursor (exclussive)
-- @version 1.0
-- @changelog
--   initial release
-- @author Stephan Römer
-- @provides [main=midi_editor] .
-- @about
--    # Description
--    * This script selects all CC events in the lane before and under the mouse cursor
--    * A CC selection is exclussive, e.g. another selected CC will get unselected
--    * This script works only in the MIDI Editor
-- @link https://forums.cockos.com/showthread.php?p=1923923


local cc_lane -- CC lane under mouse
_, _, _ = reaper.BR_GetMouseCursorContext() -- initiate "get mouse cursor context"
_, _, _, cc_lane, _, _ = reaper.BR_GetMouseCursorContext_MIDI() -- get CC lane
local take = reaper.MIDIEditor_GetTake(reaper.MIDIEditor_GetActive()) -- get active take in MIDI editor
local mouse_pos_ppq = reaper.MIDI_GetPPQPosFromProjTime(take, reaper.BR_GetMouseCursorContext_Position()) -- get mouse position in project time and convert to PPQ


function SelectCCBeforeMouse(cc_lane)

    local item = reaper.GetMediaItemTake_Item(take)
    local item_start = reaper.GetMediaItemInfo_Value(item, "D_POSITION")
    local item_start_ppq = reaper.MIDI_GetPPQPosFromProjTime(take, item_start) -- convert item_start to PPQ
        
    if reaper.TakeIsMIDI(take) then
        gotAllOK, MIDIstring = reaper.MIDI_GetAllEvts(take, "") -- write MIDI events to MIDIstring, get all events okay

        if not gotAllOK then reaper.ShowMessageBox("Error while loading MIDI", "Error", 0) return(false) end -- if getting the MIDI data failed
        
        MIDIlen = #MIDIstring -- get string length
        tableEvents = {} -- initialize table, MIDI events will temporarily be stored in this table until they are concatenated into a string again
        local stringPos = 1 -- position in MIDIstring while parsing through events 
        local sum_offset = 0 -- initialize sum_offset (adds all offsets to get the position of every event in ticks)

        while stringPos < MIDIlen-12 do -- parse through all events in the MIDI string, one-by-one, excluding the final 12 bytes, which provides REAPER's All-notes-off end-of-take message
            offset, flags, msg, stringPos = string.unpack("i4Bs4", MIDIstring, stringPos) -- unpack MIDI-string on stringPos
            sum_offset = sum_offset+offset -- add all event offsets to get next start position of event on each iteration
            local event_start = item_start_ppq+sum_offset -- calculate event start position based on item start position

            if #msg == 3 then -- if msg consists of 3 bytes (= channel message)
                
                if (msg:byte(1)>>4) == 11 and msg:byte(2) == cc_lane -- if status byte is a CC and CC# equals cc_lane 
                and event_start < mouse_pos_ppq -- events in cc_lane are before mouse position
                then 
                    flags = flags|1 -- select muted and unmuted CC events
                
                elseif (msg:byte(1)>>4) == 11 and (msg:byte(2) ~= cc_lane) or -- events are not in cc_lane
                (msg:byte(2) == cc_lane and event_start > mouse_pos_ppq) -- events in cc_lane are after mouse position
                then 
                    flags = flags&0 -- unselect muted and unmuted CC events
                end
            end
            table.insert(tableEvents, string.pack("i4Bs4", offset, flags, msg)) -- re-pack MIDI string and write to table
        end
    end
    reaper.MIDI_SetAllEvts(take, table.concat(tableEvents) .. MIDIstring:sub(-12))
    reaper.MIDI_Sort(take)
end

SelectCCBeforeMouse(cc_lane)

reaper.UpdateArrange()
reaper.Undo_OnStateChange2(proj, "Select all events in CC"..cc_lane.." lane before and under mouse cursor (exclussive)")
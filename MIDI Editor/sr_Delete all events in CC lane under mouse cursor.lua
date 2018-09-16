-- @description Delete all events in CC lane under mouse cursor
-- @version 1.0
-- @changelog
--   initial release
-- @author Stephan Römer
-- @provides [main=midi_editor] .
-- @about
--    # Description
--    * This script deletes all CC events in the lane under the mouse cursor
--    * This script works only in the MIDI Editor
-- @link https://forums.cockos.com/showthread.php?p=1923923


function DeleteCC(cc_lane, take) -- delete CC events
 
    local MIDIlen = #MIDIstring -- get string length
    tableEvents = {} -- initialize table, MIDI events will temporarily be stored in this table until they are concatenated into a string again
    local stringPos = 1 -- position in MIDIstring while parsing through events 
    
    while stringPos < MIDIlen-12 do -- parse through all events in the MIDI string, one-by-one, excluding the final 12 bytes, which provides REAPER's All-notes-off end-of-take message
        offset, flags, msg, stringPos = string.unpack("i4Bs4", MIDIstring, stringPos) -- unpack MIDI-string on stringPos
        
        if #msg == 3 -- if msg consists of 3 bytes (= channel message)
        and (msg:byte(1)>>4) == 11 and msg:byte(2) == cc_lane
        then
            msg ="" -- delete CC event
        end
        table.insert(tableEvents, string.pack("i4Bs4", offset, flags, msg)) -- re-pack MIDI string and write to table
    end
    reaper.MIDI_SetAllEvts(take, table.concat(tableEvents) .. MIDIstring:sub(-12))
    reaper.MIDI_Sort(take)
end


local take = reaper.MIDIEditor_GetTake(reaper.MIDIEditor_GetActive()) -- get active take in MIDI editor
local cc_lane -- CC lane under mouse
_, _, _ = reaper.BR_GetMouseCursorContext() -- initiate "get mouse cursor context"
_, _, _, cc_lane, _, _ = reaper.BR_GetMouseCursorContext_MIDI() -- get CC lane

if reaper.TakeIsMIDI(take) then -- make sure, that take is MIDI
    gotAllOK, MIDIstring = reaper.MIDI_GetAllEvts(take, "") -- write MIDI events to MIDIstring, get all events okay
    if not gotAllOK then reaper.ShowMessageBox("Error while loading MIDI", "Error", 0) return(false) end -- if getting the MIDI data failed

    DeleteCC(cc_lane, take) -- delete CC events
end
reaper.UpdateArrange()
reaper.Undo_OnStateChange2(proj, "Delete all events in CC"..cc_lane.." lane under mouse cursor")
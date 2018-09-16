-- @description Toggle select all events in CC lane under mouse cursor
-- @version 1.0
-- @changelog
--   initial release
-- @author Stephan Römer
-- @provides [main=midi_editor] .
-- @about
--    # Description
--    * This script selects/unselects the whole CC lane under the mouse cursor
--    * This script works only in the MIDI Editor
-- @link https://forums.cockos.com/showthread.php?p=1923923


function CheckAllSelected(cc_lane, take) -- check if all CC events in lane are selected

    local cc_amount = 0 -- number of CC events
    local selected_cc_amount = 0  -- number of selected CC events
    
    local MIDIlen = #MIDIstring -- get string length
    local stringPos = 1 -- position in MIDIstring while parsing through events 
    
    while stringPos < MIDIlen-12 do -- parse through all events in the MIDI string, one-by-one, excluding the final 12 bytes, which provides REAPER's All-notes-off end-of-take message
        offset, flags, msg, stringPos = string.unpack("i4Bs4", MIDIstring, stringPos) -- unpack MIDI-string on stringPos
        
        if #msg == 3 -- if msg consists of 3 bytes (= channel message)
        and (msg:byte(1)>>4) == 11 and msg:byte(2) == cc_lane -- if status byte is a CC and CC# equals cc_lane
        then
            if flags == flags &~ 1 then
                cc_amount = cc_amount + 1
            else
                selected_cc_amount = selected_cc_amount + 1
                cc_amount = cc_amount + 1
            end
        end
    end
    return cc_amount, selected_cc_amount
end


function SelectCC(cc_lane, take, cc_amount, selected_cc_amount) -- select or unselect CC
 
    local MIDIlen = #MIDIstring -- get string length
    tableEvents = {} -- initialize table, MIDI events will temporarily be stored in this table until they are concatenated into a string again
    local stringPos = 1 -- position in MIDIstring while parsing through events 
    
    while stringPos < MIDIlen-12 do -- parse through all events in the MIDI string, one-by-one, excluding the final 12 bytes, which provides REAPER's All-notes-off end-of-take message
        offset, flags, msg, stringPos = string.unpack("i4Bs4", MIDIstring, stringPos) -- unpack MIDI-string on stringPos
        
        if #msg == 3 -- if msg consists of 3 bytes (= channel message)
        and (msg:byte(1)>>4) == 11	and msg:byte(2) == cc_lane
        then
            if cc_amount ~= selected_cc_amount then -- if status byte is a CC and CC# equals cc_lane
                flags = flags|1 -- select muted or unmuted event
            else 
                flags = flags &~ 1 -- unselect if *all* CC events are selected
            end
        end
        table.insert(tableEvents, string.pack("i4Bs4", offset, flags, msg)) -- re-pack MIDI string and write to table
    end
    reaper.MIDI_SetAllEvts(take, table.concat(tableEvents) .. MIDIstring:sub(-12))
    reaper.MIDI_Sort(take)
end


local take = reaper.MIDIEditor_GetTake(reaper.MIDIEditor_GetActive()) -- get active take in MIDI editor
local cc_lane -- CC lane under mouse
local cc_amount, selected_cc_amount
_, _, _ = reaper.BR_GetMouseCursorContext() -- initiate "get mouse cursor context"
_, _, _, cc_lane, _, _ = reaper.BR_GetMouseCursorContext_MIDI() -- get CC lane

if reaper.TakeIsMIDI(take) then -- make sure, that take is MIDI
    gotAllOK, MIDIstring = reaper.MIDI_GetAllEvts(take, "") -- write MIDI events to MIDIstring, get all events okay
    if not gotAllOK then reaper.ShowMessageBox("Error while loading MIDI", "Error", 0) return(false) end -- if getting the MIDI data failed

    cc_amount, selected_cc_amount = CheckAllSelected(cc_lane, take) -- get number of CC events and selected CC events
    SelectCC(cc_lane, take, cc_amount, selected_cc_amount) -- select or unselect CC events
end

reaper.UpdateArrange()

if cc_amount == selected_cc_amount then
    reaper.Undo_OnStateChange2(proj, "Unselect all events in CC"..cc_lane.." lane under mouse cursor")
else
    reaper.Undo_OnStateChange2(proj, "Select all events in CC"..cc_lane.." lane under mouse cursor")
end
-- @description Select all CCs after mouse cursor (in take under mouse or in MIDI editor)
-- @version 1.0
-- @changelog
--  * initial release
-- @author Stephan Römer
-- @provides [main=main,midi_editor,midi_inlineeditor] .
-- @about
--    # Description
--    * This script selects all CCs after the mouse cursor in the currently focused MIDI editor or inline editor.
--    * Assign the script in the main action list, as well. That way, the inline editor will be opened automatically 
--    when hovering MIDI takes in the ararrange view.
--    * The scripts work in the MIDI editor, inline editor and arrange view.
-- @link https://forums.cockos.com/showthread.php?p=1923923

local function SelectAllCCsAfterMouse(take, item, mouse_pos)

    item_start = reaper.GetMediaItemInfo_Value(item, "D_POSITION") -- get start of item
    item_start_ppq = reaper.MIDI_GetPPQPosFromProjTime(take, item_start) -- convert item_start_ppq to PPQ
    mouse_position_ppq = reaper.MIDI_GetPPQPosFromProjTime(take, mouse_pos) -- convert mouse_pos to PPQ

    got_all_ok, midi_string = reaper.MIDI_GetAllEvts(take, "") -- write MIDI events to midi_string, get all events okay
    if not got_all_ok then reaper.ShowMessageBox("Error while loading MIDI", "Error", 0) return(false) end -- if getting the MIDI data failed
    
    midi_len = #midi_string -- get string length
    table_events = {} -- initialize table, MIDI events will temporarily be stored in this table until they are concatenated into a string again
    string_pos = 1 -- position in midi_string while parsing through events 
    sum_offset = 0 -- initialize sum_offset (adds all offsets to get the position of every event in ticks)

    while string_pos < midi_len-12 do -- parse through all events in the MIDI string, one-by-one, excluding the final 12 bytes, which provides REAPER's All-notes-off end-of-take message
        offset, flags, msg, string_pos = string.unpack("i4Bs4", midi_string, string_pos) -- unpack MIDI-string on string_pos
        sum_offset = sum_offset+offset -- add all event offsets to get next start position of event on each iteration
        event_start = item_start_ppq+sum_offset -- calculate event start position based on item start position
        event_type = msg:byte(1)>>4 -- save 1st nibble of status byte (contains info about the data type) to event_type, >>4 shif

        if #msg == 3 -- if msg consists of 3 bytes (= channel message)
        and (msg:byte(1)>>4) == 11 -- if status byte is a CC
        and event_start > mouse_position_ppq -- events are after cursor position
        then
            flags = flags|1 -- select muted and unmuted CC events
        else
            flags = flags&0 -- unselect CC events before cursor
        end
        table.insert(table_events, string.pack("i4Bs4", offset, flags, msg)) -- re-pack MIDI string and write to table
    end
    reaper.MIDI_SetAllEvts(take, table.concat(table_events) .. midi_string:sub(-12))
    reaper.MIDI_Sort(take)
end


-- check, where the user wants to change CCs: MIDI editor, inline editor or arrange view (item)

local take, item, midi_editor
local window, _, details = reaper.BR_GetMouseCursorContext() -- initialize cursor context
local _, inline_editor, _, _, _, _ = reaper.BR_GetMouseCursorContext_MIDI() -- check if mouse hovers an inline editor
local mouse_pos = reaper.BR_GetMouseCursorContext_Position() -- get mouse position

if window == "midi_editor" and not inline_editor then -- MIDI editor focused and not hovering inline editor
    midi_editor = reaper.MIDIEditor_GetActive() -- get active MIDI editor
    take = reaper.MIDIEditor_GetTake(midi_editor) -- get take from active MIDI editor
    item = reaper.GetMediaItemTake_Item(take) -- get item from take
    SelectAllCCsAfterMouse(take, item, mouse_pos) -- execute function

elseif details == "item" or inline_editor then -- if hovering item or inline editor
    item = reaper.BR_GetMouseCursorContext_Item() -- get item under mouse
    take = reaper.BR_GetMouseCursorContext_Take() -- get take under mouse
    
    if reaper.TakeIsMIDI(take) then -- if hovered item is MIDI take
        
        if reaper.BR_IsMidiOpenInInlineEditor(take) then -- if inline editor is active for hovered take
            SelectAllCCsAfterMouse(take, item, mouse_pos) -- execute function
        
        else  -- if user is hovering a MIDI take but inline editor is closed, open it
            reaper.Main_OnCommand(reaper.NamedCommandLookup('_SWS_SAVEALLSELITEMS1'), 0) -- save selected items
            reaper.Main_OnCommand(40289, 0) -- unselect all items
            reaper.SetMediaItemSelected(item, true) -- select item (under mouse)
            reaper.Main_OnCommand(40847, 0) -- open inline editor on selected item
            reaper.Main_OnCommand(reaper.NamedCommandLookup('_SWS_RESTALLSELITEMS1'), 0) -- restore selected items
            SelectAllCCsAfterMouse(take, item, mouse_pos) -- execute function
        end
    
    else -- take is not MIDI
        reaper.ShowMessageBox("No MIDI take found. Please hover a MIDI take", "Error", 0)
        return false
    end
    
else -- not hovering MIDI editor, inline editor nor item
    reaper.ShowMessageBox("No MIDI take found. Please hover a MIDI take", "Error", 0)
    return false
end

reaper.UpdateArrange()
reaper.Undo_OnStateChange2(proj, "Select all CCs after mouse cursor (in take under mouse or in MIDI editor)")
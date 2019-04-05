-- @description Mute notes before mouse (in take under mouse or in MIDI editor)
-- @version 1.0
-- @changelog
--  * initial release
-- @author Stephan Römer, with a lot of help from FnA and Julian Sader
-- @provides [main=main,midi_editor,midi_inlineeditor] .
-- @about
--    # Description
--    * This script mutes all notes before the mouse cursor in the take that the mouse is currently hovering (arrangement and inline editor) or in the focused MIDI editor
--    * This script works in the arrangement, MIDI editor and Inline editor
-- @link https://forums.cockos.com/showthread.php?p=1923923


function Mute_Notes(take, item, mouse_pos)

     -- create table for note-ons

     local c, m

     note_on_selection = {} -- initialize table
     for c = 0, 15 do -- channel table
         note_on_selection[c] = {} -- initialize table
         for f = 0, 2, 2 do -- flag table
             note_on_selection[c][f] = {} -- initialize table
         end
     end

    local item_start = reaper.GetMediaItemInfo_Value(item, "D_POSITION") -- get start of item
    local item_start_ppq = reaper.MIDI_GetPPQPosFromProjTime(take, item_start) -- convert item_start to PPQ
    local mouse_position_ppq = reaper.MIDI_GetPPQPosFromProjTime(take, mouse_pos) -- convert mouse_pos to PPQ

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
        local event_type = msg:byte(1)>>4 -- save 1st nibble of status byte (contains info about the data type) to event_type, >>4 shifts the channel nibble into oblivion
        
        if event_type == 9 and msg:byte(3) ~= 0 then -- if note-on and velocity is not 0
            local channel = msg:byte(1)&0x0F
            local pitch = msg:byte(2)
            
            -- check if current note-on is already tagged = overlapping note-ons!
            if note_on_selection[channel][flags&2][pitch] then
                reaper.ShowMessageBox("Can't mute notes, because overlapping notes were found", "Error", 0)
                return false

            -- note-on before mouse position? mute	
            elseif event_start < mouse_position_ppq then
                flags = flags|2 -- mute
                note_on_selection[channel][flags&2][pitch] = 1 -- tag note-on for mute

            -- note-on after mouse position? unmute 
            elseif event_start >= mouse_position_ppq then 
                flags = flags&~2 -- unmute
                note_on_selection[channel][flags&2][pitch] = 0 -- tag note-on for non-mute
            end
        
        elseif event_type == 8 or (event_type == 9 and msg:byte(3) == 0) then -- if note-off
                
            local channel = msg:byte(1)&0x0F
            local pitch = msg:byte(2)

            -- note-off anywhere and note-on before mouse? mute
            if note_on_selection[channel][2][pitch] == 1 then -- matching note-on tagged for mute? [2] = muted flag
                flags = flags|2 -- mute
                note_on_selection[channel][flags&2][pitch] = nil -- reset tag
            
            -- note-off and note-on after mouse? unmute
            elseif note_on_selection[channel][0][pitch] == 0 then -- matching note-on tagged for non-mute? [0] = non-muted flag
                flags = flags&~2 -- unmute
                note_on_selection[channel][flags&2][pitch] = nil -- reset tag
            end
        end
        table.insert(tableEvents, string.pack("i4Bs4", offset, flags, msg)) -- re-pack MIDI string and write to table
    end

    reaper.MIDI_SetAllEvts(take, table.concat(tableEvents) .. MIDIstring:sub(-12))
    reaper.MIDI_Sort(take)
end


-- check, where the user wants to mute notes: arrangement, inline editor or MIDI editor

local window, _, details = reaper.BR_GetMouseCursorContext() -- initialize cursor context
local _, inline_editor, _, _, _, _ = reaper.BR_GetMouseCursorContext_MIDI() -- check if mouse hovers an inline editor

local mouse_pos = reaper.BR_GetMouseCursorContext_Position() -- get mouse position

if window == "midi_editor" and not inline_editor then -- MIDI editor focused and not hovering inline editor
    local midi_editor = reaper.MIDIEditor_GetActive() -- get active MIDI editor
    local take = reaper.MIDIEditor_GetTake(midi_editor) -- get take from active MIDI editor
    local item = reaper.GetMediaItemTake_Item(take) -- get item from take
    Mute_Notes(take, item, mouse_pos) -- execute function

elseif details == "item" or inline_editor then -- hovering item in arrange or inline editor
    local take = reaper.BR_GetMouseCursorContext_Take() -- get take under mouse
    if reaper.TakeIsMIDI(take) then -- is take MIDI?
        local item = reaper.BR_GetMouseCursorContext_Item() -- get item under mouse
        Mute_Notes(take, item, mouse_pos) -- execute function
    else -- if take is not MIDI
        reaper.ShowMessageBox("No MIDI take found. Please hover a MIDI take", "Error", 0)
        return false
    end
else -- no item is hovered
    reaper.ShowMessageBox("No MIDI take found. Please hover a MIDI take", "Error", 0)
    return false
end

reaper.UpdateArrange()
reaper.Undo_OnStateChange2(proj, "Mute notes before mouse (in take under mouse or in MIDI editor)")
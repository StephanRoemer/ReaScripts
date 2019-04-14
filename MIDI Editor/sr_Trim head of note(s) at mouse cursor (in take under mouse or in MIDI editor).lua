-- @description Trim head of note(s) at mouse cursor (in take under mouse or in MIDI editor)
-- @version 1.0
-- @changelog
--  * initial release
-- @author Stephan Römer
-- @provides [main=main,midi_editor,midi_inlineeditor] .
-- @about
--    # Description
--    * This script trims the head of all or selected notes at the mouse cursor.
--    * This script works in the MIDI editor, inline editor and in the arrange view.
-- @link https://forums.cockos.com/showthread.php?p=1923923


-- get trim position and return in PPQ

local function GetTrimPosition(window, inline_editor, snap, mouse_pos, take)

    if snap == 1 then -- if snap is turned on, calculate grid value from mouse_pos
        
        if window == "midi_editor" and not inline_editor then
            
            grid_pt = reaper.TimeMap_QNToTime(reaper.MIDI_GetGrid(take)) -- get grid from MIDI editor and convert to project time
            int, frac = math.modf(mouse_pos / grid_pt) -- modulo
            return reaper.MIDI_GetPPQPosFromProjTime(take, (math.floor(frac + 0.5) == 1 and int + 1 or int) * grid_pt) -- rounding to the next grid (trim position ppq)
        
        else -- if hovering inline editor or arrange view = project grid applies

            grid_pt = reaper.BR_GetClosestGridDivision(mouse_pos) -- easy compared to MIDI editor, get closest grid from project, no rounding necessary
            return reaper.MIDI_GetPPQPosFromProjTime(take, grid_pt) -- return trim position ppq
        end
    else 
        return reaper.MIDI_GetPPQPosFromProjTime(take, mouse_pos) -- if snap is turned off, no rounding necessary, return mouse_pos
    end
end


-- trim note tails, respect selected notes

local function TrimNoteHead(take, mouse_pos, trim_position_ppq)
    
    if reaper.MIDI_EnumSelNotes(take, -1) ~= -1 then 
        notes_selected = true 
    end -- check, if there are selected notes, set notes_selected to true

    mouse_pos_ppq = reaper.MIDI_GetPPQPosFromProjTime(take, mouse_pos) -- convert mouse position to PPQ
    _, num_notes, _, _ = reaper.MIDI_CountEvts(take) -- get number of notes

    for n = 0, num_notes-1 do
        _, selected, _, note_start_pos_ppq, note_end_pos_ppq, _, _, _ = reaper.MIDI_GetNote(take, n) -- get current note

        if note_start_pos_ppq < mouse_pos_ppq -- if note is
        and note_end_pos_ppq > mouse_pos_ppq -- under mouse cursor
        and (selected or not notes_selected)
        and note_end_pos_ppq - trim_position_ppq > 1 -- and note is longer than 1 tick (prevents "ghost notes")
        then
            reaper.MIDI_SetNote(take, n, nil, nil, trim_position_ppq, nil, nil, nil, nil, true) -- set new note length to trim position
        end
    end
    reaper.MIDI_Sort(take)
end


-- trim note tails, ignore selected notes

local function TrimNoteHeadArrange(take, mouse_pos, trim_position_ppq)
    
    mouse_pos_ppq = reaper.MIDI_GetPPQPosFromProjTime(take, mouse_pos) -- convert mouse position to PPQ
    _, num_notes, _, _ = reaper.MIDI_CountEvts(take) -- get number of notes

    for n = 0, num_notes-1 do
        _, _, _, note_start_pos_ppq, note_end_pos_ppq, _, _, _ = reaper.MIDI_GetNote(take, n) -- get current note values

        if note_start_pos_ppq < mouse_pos_ppq -- if note is
        and note_end_pos_ppq > mouse_pos_ppq -- under mouse cursor
        and note_end_pos_ppq - trim_position_ppq  > 1 -- and note is longer than 1 tick (prevents "ghost notes")
        then
            reaper.MIDI_SetNote(take, n, nil, nil, trim_position_ppq, nil, nil, nil, nil, true) -- set new note length to trim position
        end
    end
    reaper.MIDI_Sort(take)
end


-- check, where the user wants to trim notes: MIDI editor, inline editor or arrange view

local snap, take, trim_position_ppq
local window, _, _ = reaper.BR_GetMouseCursorContext() -- initialize cursor context
local _, inline_editor, _, _, _, _ = reaper.BR_GetMouseCursorContext_MIDI() -- check if mouse hovers an inline editor
local mouse_pos = reaper.BR_GetMouseCursorContext_Position() -- get mouse position

if window == "midi_editor" and not inline_editor then -- MIDI editor is focused and its not the inline editor
    local midi_editor = reaper.MIDIEditor_GetActive() -- get active MIDI editor
    take = reaper.MIDIEditor_GetTake(midi_editor) -- get take from active MIDI editor
    snap = reaper.MIDIEditor_GetSetting_int(midi_editor, "snap_enabled") -- get snap state
    trim_position_ppq = GetTrimPosition(window, snap, mouse_pos, take) -- get trim position
    TrimNoteHead(take, mouse_pos, trim_position_ppq) -- trim note tail
    
else -- common commands for inline editor and arrange view
    take = reaper.BR_GetMouseCursorContext_Take() -- get take from mouse
    snap = reaper.GetToggleCommandState(1157) -- get arrange snap state
    trim_position_ppq = GetTrimPosition(window, inline_editor, snap, mouse_pos, take)
    
    if inline_editor then -- inline editor has focus
        TrimNoteHead(take, mouse_pos, trim_position_ppq) -- trim note tails
    else -- arrange view has focus
        TrimNoteHeadArrange(take, mouse_pos, trim_position_ppq) -- trim note tails, ignore note selection!
    end
end
reaper.Undo_OnStateChange2(0, "Trim head of note(s) at mouse cursor (in take under mouse or in MIDI editor)")
reaper.UpdateArrange()
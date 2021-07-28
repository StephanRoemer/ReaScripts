-- @description Velocity crescendo
-- @version 1.01
-- @changelog
--  + initial release
-- @author Stephan Römer, Leon Bradley (LBX)
-- @provides [main=midi_editor] .
-- @about
--    # Description
--    * This script creates a velocity decrescendo based on all or selected notes. 
--    * The velocity of the first note (in the item, or selected note) will always be the start velocity!
--    * Avoid selecting groups of notes with gaps in between. If you want to apply multiple decrescendi, select the note groups 
--    * consecutively and apply the script each time.
--    * This script only works in the MIDI Editor
--    * Thanks a lot to Leon Bradley for nailing the main algo, without his help this script wouldn't exist!
-- @link https://forums.cockos.com/showthread.php?p=1923923


local function GetTargetNotes(take)

    -- Put notes into a table, all or selected ones

    local note_tbl = {}
    local _, note_cnt, _, _ = reaper.MIDI_CountEvts(take)
    local sel_notes = reaper.MIDI_EnumSelNotes(take, -1)

    -- all notes
    if sel_notes == -1 then 
        for n = 0, note_cnt - 1 do 
            local retval, _, _, note_startpos, _, _, _, velocity = reaper.MIDI_GetNote(take, n)
            note_tbl[#note_tbl+1] = {index = n,  note_startpos = note_startpos, velocity = velocity} 
        end

    -- selected notes
    else
        for n = 0, note_cnt - 1 do 
            local retval, note_sel, _, note_startpos, _, _, _, velocity = reaper.MIDI_GetNote(take, n)
            if note_sel then
                note_tbl[#note_tbl+1] = {index = n,  note_startpos = note_startpos, velocity = velocity} 
            end
        end
    end
    return note_tbl 
end


local function VelocityDecrescendo(take, note_tbl)
    local tbl_len = #note_tbl
    local first_note_startpospos = note_tbl[1].note_startpos
    local start_vel = note_tbl[1].velocity
    local last_note_startpospos = note_tbl[tbl_len].note_startpos
    local total_distance = last_note_startpospos - first_note_startpospos

    reaper.MIDI_DisableSort(take)

    -- Iterate thru all notes, skip first note, since it provides the start velocity
    for n = 2, tbl_len do

        -- Calculate the "percentage"" that a note will get of the start_vel.
        -- math.max makes sure, "1"" is the lowest possible start value
        local velocity = math.max(((last_note_startpospos - note_tbl[n].note_startpos) / total_distance) * start_vel, 1)        

        reaper.MIDI_SetNote(take, note_tbl[n].index, nil, nil, nil, nil, nil, nil, math.floor(velocity), nil) -- set velocity, math.floor converts to integer
    end
    reaper.MIDI_Sort(take)
end


local function Main()
    local take = reaper.MIDIEditor_GetTake(reaper.MIDIEditor_GetActive())
    local note_tbl = GetTargetNotes(take)

    reaper.Undo_BeginBlock()
    VelocityDecrescendo(take, note_tbl)
    reaper.Undo_EndBlock("Velocity decrescendo", 4)
end

Main()

-- @description Toggle show UI of all FX in send track
-- @version 1.1
-- @changelog
--   switched to external function file and put all scripts in a bundle
-- @author Stephan Römer
-- @provides
--  . > sr_Toggle show UI of all FX in send function.lua
-- 	. > sr_Toggle show UI of all FX in send 1.lua
-- 	. > sr_Toggle show UI of all FX in send 2.lua
-- 	. > sr_Toggle show UI of all FX in send 3.lua
-- 	. > sr_Toggle show UI of all FX in send 4.lua
-- @about
--   # Description
--   This script bundle consists of 4 scripts that shows/hide the UI of all FX in send 1-4
-- @link Forum Thread https://forums.cockos.com/showthread.php?p=1923923


function ToggleShowUISend(send_slot)

    local selected_tracks = reaper.CountSelectedTracks(0)

    if selected_tracks == 0 then
        reaper.ShowMessageBox("Please select a track", "Error", 0)
        return false
    elseif selected_tracks > 1 then
        reaper.ShowMessageBox("Please select only one track", "Error", 0)
        return false
    else
        local track = reaper.GetSelectedTrack(0, 0) -- get selected track
        local send_track = reaper.BR_GetMediaTrackSendInfo_Track(track, 0, send_slot-1, 1) -- get 1st send track

        reaper.Undo_BeginBlock()

        if reaper.GetTrackNumSends(track, 0) > send_slot-1 then
            fx_count = reaper.TrackFX_GetCount(send_track) -- get number of inserts on FX track
            if fx_count ~= 0 then
                for i = 0, fx_count do
                    if not reaper.TrackFX_GetOpen(send_track, i) then -- UI closed?
                        reaper.TrackFX_SetOpen(send_track, i, true) -- open 3rd send UI
                    else
                        reaper.TrackFX_SetOpen(send_track, i, false) -- close 3rd send UI
                    end
                end
            else
                reaper.ShowMessageBox("The send in slot "..send_slot.." is either a Bus or has no insert FX", "Error", 0) 
                return false
            end
        else
            reaper.ShowMessageBox("The selected track has no send FX in slot "..send_slot, "Error", 0)
            return false
        end
        
        reaper.Undo_EndBlock("Toggle show UI of all FX in send slot "..send_slot, -1)
    end
end
-- @description Hide tracks without items and ignore folders (TCP)
-- @version 1.0
-- @changelog
--   initial release
-- @author Stephan Römer
-- @provides [main=main] .
-- @about
--    # Description
--    * this script hides all tracks in the TCP, that have no items but will ignore folder tracks
--    * This script works only in the arrangement
-- @link https://forums.cockos.com/showthread.php?p=1923923

tracks_amount = reaper.GetNumTracks()

for t = 0, tracks_amount-1 do
    track = reaper.GetTrack(0, t)
    items = reaper.CountTrackMediaItems(track)
    _, flags = reaper.GetTrackState(track) -- get folder state
    if items == 0 and flags&1 ~= 1 then -- does track have items and isn't folder?
        if reaper.GetMediaTrackInfo_Value(track, "B_SHOWINTCP") == 1.0 then -- is track visible?
            reaper.SetMediaTrackInfo_Value(track, "B_SHOWINTCP", 0) -- hide track
        end
    end
end

reaper.TrackList_AdjustWindows(false) 
reaper.UpdateArrange()
reaper.Main_OnCommand(40913, 0) -- scroll view to selected track
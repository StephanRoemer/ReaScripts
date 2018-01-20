-- @description sr_Toggle collapse selected folders 
-- @version 1.0    
-- @author Stephan Römer
-- @about
--    # Description
--    - this script will collapse or compact selected folder tracks
--
-- @link https://forum.cockos.com/showpost.php?p=1923094&postcount=124
--
-- @changelog
--     v1.0 (2018-01-21)
--     + initial release


reaper.Undo_BeginBlock()

reaper.PreventUIRefresh(1)
 
for i = 0, reaper.CountSelectedTracks(0)-1 do -- loop through all selected tracks
	track = reaper.GetSelectedTrack(0,i) -- save actual track to "track"
	if track ~= nil and reaper.GetMediaTrackInfo_Value(track, 'I_FOLDERDEPTH') == 1 then -- if selected track is folder and not nil
		if reaper.GetMediaTrackInfo_Value(track, 'I_FOLDERCOMPACT') ~= 2 then
			reaper.SetMediaTrackInfo_Value(track, 'I_FOLDERCOMPACT', 2)
		else 
			reaper.SetMediaTrackInfo_Value(track, 'I_FOLDERCOMPACT', 0)
		end
	end
end

reaper.PreventUIRefresh(-1)

reaper.Undo_EndBlock("Toggle collapse selected folders", 0)
		
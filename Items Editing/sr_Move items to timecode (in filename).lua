-- @description Move items to timecode (in filename)
-- @version 1.0
-- @author Stephan Römer
-- @about
--    # Description
--    - this script moves either all or selected items to their timecode position (written in the filename)
--	  - the timecode needs to be in the format xx.xx.xx.xx (Windows does not allow : in filenames)
--	  - this script is useful for audio formats, that can't carry BWF data in Reaper (FLAC for example)
--
-- @link https://forums.cockos.com/showthread.php?p=1923923
--
-- @provides [main=main] .
-- @changelog
--     v1.0 (2018-07-02)
--     + Initial release

if reaper.CountSelectedMediaItems(0) == 0 then 
	for i = 0, reaper.CountMediaItems(0)-1 do -- loop through all existing items
		item = reaper.GetMediaItem(0, i) -- get current media item
		take = reaper.GetActiveTake(item)  -- get active take in item
		takeName = reaper.GetTakeName(take)  -- get take name
		timecodeDot = string.match(takeName, '%d%d%.%d%d%.%d%d%.%d%d') -- match timecode
		timecode = string.gsub(timecodeDot, "%.", ":")  -- replace "." with ":"
		reaperTime = reaper.parse_timestr_len(timecode, 0, 5)  -- convert timecode to Reaper time
		projectStart = reaper.GetProjectTimeOffset(0, false) -- get project start
		newPosition = reaperTime - projectStart -- mind the project start and calculate new position!
		reaper.SetMediaItemPosition(item, newPosition, true)-- move item to timecode
	end
else	
	for i = 0, reaper.CountSelectedMediaItems(0)-1 do -- loop through all selected items
		selectedItem = reaper.GetSelectedMediaItem(0, i)  -- get current media item
		take = reaper.GetActiveTake(selectedItem)  -- get active take in item
		takeName = reaper.GetTakeName(take)  -- get take name
		timecodeDot = string.match(takeName, '%d%d%.%d%d%.%d%d%.%d%d') -- match timecode
		timecode = string.gsub(timecodeDot, "%.", ":")  -- replace "." with ":"
		reaperTime = reaper.parse_timestr_len(timecode, 0, 5)  -- convert timecode to Reaper time
		projectStart = reaper.GetProjectTimeOffset(0, false) -- get project start
		newPosition = reaperTime - projectStart -- mind the project start and calculate new position!
		reaper.SetMediaItemPosition(selectedItem, newPosition, true)-- move item to timecode
	end
end

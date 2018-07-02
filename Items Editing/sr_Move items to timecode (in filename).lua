-- @description Move items to timecode (in filename)
-- @version 1.1
-- @author Stephan Römer
-- @about
--    # Description
--    - this script moves either all or selected items to their timecode position (written in the filename)
--	  - the timecode needs to be in the format xx.xx.xx.xx (Windows does not allow : in filenames)
--	  - this script is useful for audio formats, where Reaper can't read the BWF chunk (FLAC for example)
--
-- @link https://forums.cockos.com/showthread.php?p=1923923
--
-- @provides [main=main] .
-- @changelog
--     v1.1 (2018-07-02)
--	   + added a case to ignore files with no timecode in the filename
--     v1.0 (2018-07-02)
--     + Initial release

if reaper.CountSelectedMediaItems(0) == 0 then 
	for i = 0, reaper.CountMediaItems(0)-1 do -- loop through all existing items
		item = reaper.GetMediaItem(0, i) -- get current media item
		take = reaper.GetActiveTake(item)  -- get active take in item
		takeName = reaper.GetTakeName(take)  -- get take name
		timecodeDot = string.match(takeName, '%d%d%.%d%d%.%d%d%.%d%d') -- match timecode
		if timecodeDot == nil then -- if there is no timecode in the filename, skip item
			i=i+1
		else -- if there is a timecode in the filename
			timecode = string.gsub(timecodeDot, "%.", ":")  -- replace "." with ":"
			reaperTime = reaper.parse_timestr_len(timecode, 0, 5)  -- convert timecode to Reaper time
			projectStart = reaper.GetProjectTimeOffset(0, false) -- get project start
			newPosition = reaperTime - projectStart -- mind the project start and calculate new position!
			reaper.SetMediaItemPosition(selectedItem, newPosition, true)-- move item to timecode
		end
	end
else	
	for i = 0, reaper.CountSelectedMediaItems(0)-1 do -- loop through all selected items
		selectedItem = reaper.GetSelectedMediaItem(0, i)  -- get current media item
		take = reaper.GetActiveTake(selectedItem)  -- get active take in item
		takeName = reaper.GetTakeName(take)  -- get take name
		timecodeDot = string.match(takeName, '%d%d%.%d%d%.%d%d%.%d%d') -- match timecode
		if timecodeDot == nil then -- if there is no timecode in the filename, skip item
			i=i+1 -- if there is a timecode in the filename
		else
			timecode = string.gsub(timecodeDot, "%.", ":")  -- replace "." with ":"
			reaperTime = reaper.parse_timestr_len(timecode, 0, 5)  -- convert timecode to Reaper time
			projectStart = reaper.GetProjectTimeOffset(0, false) -- get project start
			newPosition = reaperTime - projectStart -- mind the project start and calculate new position!
			reaper.SetMediaItemPosition(selectedItem, newPosition, true)-- move item to timecode
		end
	end
end

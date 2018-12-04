--  @noindex

function HumanQuantize(humanize)
	MIDIEditor = reaper.MIDIEditor_GetActive()
    
    for i = 0, reaper.CountSelectedMediaItems(0)-1 do -- loop through all selected items
		item = reaper.GetSelectedMediaItem(0, i) -- get current selected item
    
        for t = 0, reaper.CountTakes(item)-1 do -- loop through all takes within each selected item
			take = reaper.GetTake(item, t) -- get current take
    
            if reaper.TakeIsMIDI(take) then -- make sure, that take is MIDI
				_, notesCount, _, _ = reaper.MIDI_CountEvts(take) -- count notes and save amount to notes
			end
			
			if reaper.MIDI_EnumSelNotes(take, -1) ~= -1 then notesSelected = true end -- check, if there are selected notes, set notesSelected to true
			
			for n = 0, notesCount - 1 do -- loop through all notes
				_, selectedOut, _, startppqposOut, endppqposOut, _, _, _ = reaper.MIDI_GetNote(take, n) -- get selection status and pitch
    
                if MIDIEditor == nil then -- if user is in the Arrangement (MIDI Editor is closed), use project grid for quantize
					noteStart = reaper.MIDI_GetProjTimeFromPPQPos(take, startppqposOut) -- convert note start to seconds
					closestGrid = reaper.BR_GetClosestGridDivision(noteStart) -- get closest grid for current note (return value in seconds)
					closestGridPPQ = reaper.MIDI_GetPPQPosFromProjTime(take, closestGrid) -- convert closest grid to PPQ
    
                    if notesSelected == true then -- if there is a note selection
						if selectedOut == true then -- filter out selected notes to quantize
							if closestGridPPQ ~= startppqposOut then -- if notes are not on the grid
								reaper.MIDI_SetNote(take, n, nil, nil, startppqposOut+(closestGridPPQ-startppqposOut)*humanize/100, startppqposOut+(closestGridPPQ-startppqposOut)*humanize/100+endppqposOut-startppqposOut, nil, nil, nil, true) -- quantize selected notes
							end
						end
					else -- if there is no note selection
						if closestGridPPQ ~= startppqposOut then
						reaper.MIDI_SetNote(take, n, nil, nil, startppqposOut+(closestGridPPQ-startppqposOut)*humanize/100, startppqposOut+(closestGridPPQ-startppqposOut)*humanize/100+endppqposOut-startppqposOut, nil, nil, nil, true) -- quantize all notes
						end
					end
    
                else -- if user is in the MIDI editor, use the MIDI Editor grid
					editorGridQN = reaper.MIDI_GetGrid(take) -- get grid from MIDI Editor
					ticksPerBeat = reaper.SNM_GetIntConfigVar('miditicksperbeat', 0) -- get ticks per beat from Reaper project settings
					editorGridPPQ = ticksPerBeat * editorGridQN -- calculate grid steps in ticks
					int, frac = math.modf(startppqposOut / editorGridPPQ) -- math.modf just gives the whole and decimal parts of a number. Many thanks to Lokasenna! https://forums.cockos.com/showthread.php?t=208915 
					editorClosestGridPPQ = (math.floor( frac + 0.5 ) == 1 and int + 1 or int) * editorGridPPQ -- get closest grid. Simple rounding logic. If you can add 0.5 and it still rounds down (math.floor) to 0 then it should round down. If adding 0.5 causes it to round up to 1, then it was >= 0.5 and should round up. "int" is just the number of multiples of "editorGridPPQ" (snap) that we have, so we have to multiply snap back in.
    
                        if notesSelected == true then -- if there is a note selection
						if selectedOut == true then -- filter out selected notes to quantize
							if editorClosestGridPPQ ~= startppqposOut then -- if notes are not on the grid
								reaper.MIDI_SetNote(take, n, nil, nil, startppqposOut+(editorClosestGridPPQ-startppqposOut)*humanize/100, startppqposOut+(editorClosestGridPPQ-startppqposOut)*humanize/100+endppqposOut-startppqposOut, nil, nil, nil, true) -- quantize all notes
							end
						end
					else -- if there is no note selection, apply to all notes
						reaper.MIDI_SetNote(take, n, nil, nil, startppqposOut+(editorClosestGridPPQ-startppqposOut)*humanize/100, startppqposOut+(editorClosestGridPPQ-startppqposOut)*humanize/100+endppqposOut-startppqposOut, nil, nil, nil, true) -- quantize all notes
					end
				end
			end
		end
	end
	reaper.MIDI_Sort(take)
	reaper.UpdateArrange()
end
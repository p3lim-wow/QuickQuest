local _, addon = ...

local lastMovieID
function addon:PLAY_MOVIE(movieID)
	if not QuickQuestMoviesDB then
		QuickQuestMoviesDB = {}
	end

	if addon:IsPaused() then
		return
	end

	local skip = addon:GetOption('skipmovies')
	if skip == 3 or (skip == 2 and QuickQuestMoviesDB[movieID]) then
		if MovieFrame and MovieFrame:IsShown() then

			if pcall(MovieFrame.Hide, MovieFrame) then -- wrap just in case
				-- for some reason this event fires twice, so we'll add
				-- a simple check to avoid duplicate chat messages
				if lastMovieID ~= movieID then
					lastMovieID = movieID
					addon:Print('Skipped movie')
				else
					lastMovieID = nil
				end
			end
		end
	end

	QuickQuestMoviesDB[movieID] = true
end

function addon:CINEMATIC_START(canBeCancelled)
	if addon:IsPaused() then
		return
	end

	local skip = addon:GetOption('skipcinematics')
	if skip == 3 then
		if canBeCancelled then
			if pcall(StopCinematic) then -- wrap just in case
				addon:Print('Skipped cinematic')
			end
		elseif CanCancelScene() then
			if pcall(CancelScene) then -- wrap just in case
				addon:Print('Skipped cinematic')
			end
		end
	end
end

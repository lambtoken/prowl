local songNames = require 'src.sound.songs'
local gs = require('src.state.GameState'):getInstance()

local musicVolume = 0.3

local music = {}

local function randomSong()
    return songNames[math.ceil(gs.rng:get("general") * #songNames)]
end

local function playSong(songName)

	if music.currentSong then
		music.currentSong.source:stop()
	end

	music.currentSong = {}
	music.currentSong.songName = songName
	music.currentSong.source = love.audio.newSource("assets/music/" .. songName, "stream")
	music.currentSong.source:setVolume(musicVolume)
	music.currentSong.source:play()
end

music.changeSong = function()
    local songs = {}

	for index, value in ipairs(songNames) do
		if value ~= music.currentSong.songName then
			table.insert(songs, value)
		end
	end

	local songName = songs[math.ceil(gs.rng:get("general") * #songs)]

	playSong(songName)
end

music.load = function()
	playSong(randomSong())
end

music.update = function(dt)
	if not music.currentSong or not music.currentSong.source:isPlaying() then
		local songName = randomSong()
		playSong(songName)
	end
end

-- music.applyMusicVolumeChange = function()
-- 	music.currentSong:setVolume(GameState.settings.musicVolume)
-- end

return music
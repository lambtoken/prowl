local soundTable = require 'src.sound.soundTable'

local SoundManager = {}
SoundManager.__index = SoundManager
local instance = nil

function SoundManager:new()
    local o = {
        maxInstances = 4,
        cooldownTicks = 5,
        playingSounds = {}
    }
    setmetatable(o, self)
    self._index = self

    return o
end

function SoundManager:getInstance()
    if not instance then
        instance = SoundManager:new()
    end
    return instance
end

function SoundManager:updatePlayingSounds()
    for soundName, soundData in pairs(self.playingSounds) do
        local toRemove = {}

        for i = 1, #soundData.sources do
            if not soundData.sources[i]:isPlaying() then
                table.insert(toRemove, i)
            end
        end

        for i = #toRemove, 1, -1 do
            table.remove(soundData.sources, toRemove[i])
        end

        soundData.instances = #soundData.sources
    end
end

function SoundManager:playSound(soundName)
    local currentTime = love.timer.getTime()
    local dt = love.timer.getDelta()

    if not self.playingSounds[soundName] then
        local sound = love.audio.newSource("/assets/sounds/" .. soundTable[soundName].file, "static")
        sound:setVolume(soundTable[soundName].volume or 1)
        sound:setPitch(0.9 + math.random() * 0.2)
        sound:play()
        self.playingSounds[soundName] = {
            lastPlayed = -self.cooldownTicks * dt, 
            sources = { sound },
            instances = 1
        }

        return
    end

    local soundData = self.playingSounds[soundName]

    if soundData.instances >= self.maxInstances then
        return
    end

    if currentTime - soundData.lastPlayed < self.cooldownTicks * dt then
        return
    end

    self:updatePlayingSounds()

    local a = love.audio.newSource("/assets/sounds/" .. soundTable[soundName].file, "static")
    a:setVolume(soundTable[soundName].volume or 1)

    table.insert(soundData.sources, a)
    soundData.sources[#soundData.sources]:setPitch(0.9 + math.random() * 0.2)
    soundData.sources[#soundData.sources]:play()
    soundData.lastPlayed = currentTime
end

return SoundManager
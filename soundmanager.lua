
-- This class manages all music and sounds in the game

SoundManager = Core.class()

function SoundManager:init()
	self.music = Sound.new("music/racer.mp3")
end

function SoundManager:play()
	self.channel = self.music:play(0, math.huge)
end

function SoundManager:stop()
	local channel = self.channel
	if (channel) then
		channel:stop()
		channel = nil
	end
end
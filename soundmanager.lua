
SoundManager = Core.class()

function SoundManager:init()
	self.music = Sound.new("music/racer.mp3")
end

function SoundManager:play()
	self.channel = self.music:play(0, true)
end

function SoundManager:stop()
	local channel = self.channel
	if (channel) then
		channel:stop()
		channel = nil
	end
end
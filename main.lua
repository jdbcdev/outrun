
-- Outrun based game base on 
-- https://github.com/jakesgordon/javascript-racer/
-- http://codeincomplete.com/posts/2012/6/22/javascript_racer/

application:setKeepAwake(true)
application:setOrientation(Application.LANDSCAPE_LEFT)
--application:setBackgroundColor(0xff0000)

local track_length

-- Create a game scene child of stage
local scene = Scene.new()

Render = {}
Render.segments = {}
 
--[[
   fog: function(ctx, x, y, width, height, fog) {
    if (fog < 1) {
      ctx.globalAlpha = (1-fog)
      ctx.fillStyle = COLORS.FOG;
      ctx.fillRect(x, y, width, height);
      ctx.globalAlpha = 1;
    }
]]--

stage:addChild(scene)

local frame = 0
local timer = os.timer()
local floor = math.floor
--local fps = TextField.new(TTFont.new("fonts/Akashi.ttf", 13), "")

local function displayFps()
	frame = frame + 1
	if frame == 60 then
		local currentTimer = os.timer()
		print(floor(60 / (currentTimer - timer)))
		--fps:setText(floor(60 / (currentTimer - timer)))
		frame = 0
		timer = currentTimer	
	end
end

-- Game loop
function update()
	
	scene:increase()
	scene:update_background()
	scene:draw_road()
	scene:update_player()
	
	displayFps()
end

function onClick(event)
	local player = scene.player
	local centerX = application:getContentWidth() * 0.5
	local posX = player:getX()
	if (event.x < centerX) then
		posX = posX - 10
	else
		posX = posX + 10
	end
	
	player:setX(posX)
end

-- Add event listener for loop game
stage:addEventListener(Event.ENTER_FRAME, update)

-- stage:addEventListener(Event.MOUSE_DOWN, onClick)


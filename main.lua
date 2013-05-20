
-- Outrun based game base on 
-- https://github.com/jakesgordon/javascript-racer/
-- http://codeincomplete.com/posts/2012/6/22/javascript_racer/

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

-- Game loop
function update()
	
	scene:increase()
	scene:draw_road()
	scene:update_player()
	
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


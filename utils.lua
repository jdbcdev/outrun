

Utils = {}

local width = application:getContentWidth()
local height = application:getContentHeight()

function Utils.project(p, cameraX, cameraY, cameraZ, camera_depth, road_width)

	local ceil = math.ceil
	
	p.camera.x = (p.world.x or 0) - cameraX
	p.camera.y = (p.world.y or 0) - cameraY
	p.camera.z = (p.world.z or 0) - cameraZ
	
	local scale = camera_depth / p.camera.z
	p.screen.scale = scale
	p.screen.x = ceil((width / 2) + (scale * p.camera.x * width / 2))
	p.screen.y = ceil((height / 2) - (scale * p.camera.y * height / 2))
	p.screen.w = ceil(p.screen.scale * road_width * width/2)
	
end

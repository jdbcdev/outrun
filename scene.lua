
-- GameScene (backgrounds, road, player)

Scene = Core.class(Sprite)

-- Background speed
local sky_speed    = 0.001
local hill_speed   = 0.002
local tree_speed   = 0.003

local rumble_length = 3
local segment_length = 200
local position = 0 -- Camera position
local draw_distance = 100
local road_width = 1400
local field_of_view = 100

local camera_height = 900
local camera_depth = 1 / math.tan((field_of_view/2) * math.pi/180);

-- player position (Y is constant)
local playerX = 0
local playerY = 0
local playerZ = (camera_height * camera_depth)

local fog_density = 5 --(1-50)
local speed = 200

-- Background, hills and trees
local texture_sky = Texture.new("images/background/sky.png")
local bg_sky = Bitmap.new(texture_sky)

local texture_hills = Texture.new("images/background/hills.png")
local bg_hills = Bitmap.new(texture_hills)

local texture_trees = Texture.new("images/background/trees.png")
local bg_trees = Bitmap.new(texture_trees)

-- Player and cars
local texture_player = {Texture.new("images/sprites/player_straight.png"),
						Texture.new("images/sprites/player_right.png"),
						Texture.new("images/sprites/player_left.png"),
						Texture.new("images/sprites/player_uphill_straight.png"),
						Texture.new("images/sprites/player_uphill_right.png"),
						Texture.new("images/sprites/player_uphill_left.png")}

local COLORS = {
  SKY = "0x72D7EE",
  TREE = "0x005108",
  FOG = "0x005108",
  LIGHT = { road = "0x6B6B6B", grass = "0x10AA10", rumble = "0x555555", lane = "0xCCCCCC" },
  DARK = { road = "0x696969", grass = "0x009A00", rumble = "0xBBBBBB" },
  START = { road = "0xffffff", grass = "0xffffff", rumble = "0xffffff" },
  FINISH = { road = "0x000000", grass = "0x000000", rumble = "0x000000" }
}

local ROAD = {
  LENGTH = { NONE = 0, SHORT = 25, MEDIUM = 50, LONG = 100 },
  HILL =  { NONE = 0, LOW = 20, MEDIUM = 40, HIGH = 60 },
  CURVE = { NONE = 0, EASY = 2, MEDIUM = 4, HARD = 6 }
}

-- Constructor
function Scene:init()
	self.position = position
	self.road = Sprite.new()
	self:draw_background()
	self:reset_road()
	self:draw_player()
	
	local soundmanager = SoundManager.new()
	soundmanager:play()
end

-- Draws backgrounds of the game scene
function Scene:draw_background()
	self.bg_sky = bg_sky
	self:addChild(bg_sky)
	
	self.bg_hills = bg_hills
	self:addChild(bg_hills)
	
	self.bg_trees = bg_trees
	self:addChild(bg_trees)
end

function Scene:update_background()
	local bg_sky = self.bg_sky
	local bg_hills = self.bg_hills
	local bg_trees = self.bg_trees
	
	local curve = self.curve
	if (curve) then
		local sky_x = bg_sky:getX() - (sky_speed * curve * speed * 0.5)
		bg_sky:setX(sky_x)
		local hills_x = bg_hills:getX() - (hill_speed * curve * speed * 0.5)
		bg_hills:setX(hills_x)
		local trees_x = bg_trees:getX() - (tree_speed * curve * speed * 0.5)
		bg_trees:setX(trees_x)
	end
end

-- Draws player car
function Scene:draw_player()
		
	self.texture_player = texture_player[1] -- straight
	local player = Bitmap.new(self.texture_player)
	player:setScale(2)
	local posX = (application:getContentWidth() - player:getWidth()) * 0.5
	local posY = application:getContentHeight() - player:getHeight() - 5
	player:setPosition(posX, posY)
	self.player = player
	self:addChild(player)
end

-- Update player in the scene
function Scene:update_player()

	local player = self.player
	player:setTexture(self.texture_player)
	
	if (player and self:contains(player)) then
		self:removeChild(player)
		self:addChild(player)
	end
end

-- Returns previous Y point value
function Scene:lastY() 
  local segments = self.segments
  
  if (segments and #segments > 1) then
	local index = #segments -1
	return segments[index].p2.world.y
  else
	return 0
  end
end

-- This function 
function Scene:addRoad(enter, hold, leave, curve, y) 

	local start_y = self:lastY()
	local end_y = start_y + y * segment_length
	
	local total = enter + hold + leave
	for i=1, enter do
		self:addSegment(Utils.easeIn(0, curve, i / enter), Utils.easeInOut(start_y, end_y, i/total));
	end
	
	for i=1, hold do
		self:addSegment(curve, Utils.easeInOut(start_y, end_y, (enter + i) / total));
	end
	
	for i=1, leave do
		self:addSegment(Utils.easeInOut(curve, 0, i/leave), Utils.easeInOut(start_y, end_y, (enter + hold + i) / total));
	end
end

-- Add a set of segments in a straight road
function Scene:addStraight(num)
	local num = num or ROAD.LENGTH.MEDIUM;
    self:addRoad(num, num, num, 0, 0);
end
	
-- Add a set of segments in a curve road
function Scene:addCurve(num, curve, height) 
	local num = num or ROAD.LENGTH.MEDIUM
	local curve = curve or ROAD.CURVE.MEDIUM;
    local height = height or ROAD.HILL.NONE;
    self:addRoad(num, num, num, curve, height);
end

-- Add a set of segments in a hill
function Scene:addHill(num, height) 
    local num = num or ROAD.LENGTH.MEDIUM;
    local height = height or ROAD.HILL.MEDIUM;
    self:addRoad(num, num, num, 0, height);
end

function Scene:addLowRollingHills(num, height)
	local num = num or ROAD.LENGTH.SHORT
	local height = height or ROAD.HILL.LOW
	
	self:addRoad(num, num, num,  0,  height/2)
	self:addRoad(num, num, num,  0, -height)
	self:addRoad(num, num, num,  0,  height)
	self:addRoad(num, num, num,  0,  0)
	self:addRoad(num, num, num,  0,  height/2)
	self:addRoad(num, num, num,  0,  0)
end

function Scene:addDownhillToEnd(num)
    num = num or 200;
    self:addRoad(num, num, num, -ROAD.CURVE.EASY, -self:lastY() / segment_length);
end

function Scene:addSCurves()
    self:addRoad(ROAD.LENGTH.MEDIUM, ROAD.LENGTH.MEDIUM, ROAD.LENGTH.MEDIUM, -ROAD.CURVE.EASY, ROAD.HILL.NONE);
    self:addRoad(ROAD.LENGTH.MEDIUM, ROAD.LENGTH.MEDIUM, ROAD.LENGTH.MEDIUM, ROAD.CURVE.MEDIUM, ROAD.HILL.MEDIUM);
    self:addRoad(ROAD.LENGTH.MEDIUM, ROAD.LENGTH.MEDIUM, ROAD.LENGTH.MEDIUM, ROAD.CURVE.EASY, -ROAD.HILL.LOW);
    self:addRoad(ROAD.LENGTH.MEDIUM, ROAD.LENGTH.MEDIUM, ROAD.LENGTH.MEDIUM, -ROAD.CURVE.EASY, ROAD.HILL.MEDIUM);
    self:addRoad(ROAD.LENGTH.MEDIUM, ROAD.LENGTH.MEDIUM, ROAD.LENGTH.MEDIUM, -ROAD.CURVE.MEDIUM, -ROAD.HILL.MEDIUM);
end

function Scene:addBumps() 
    self:addRoad(10, 10, 10, 0, 5);
    self:addRoad(10, 10, 10, 0, -2);
    self:addRoad(10, 10, 10, 0, -5);
    self:addRoad(10, 10, 10, 0, 8);
    self:addRoad(10, 10, 10, 0, 5);
    self:addRoad(10, 10, 10, 0, -7);
    self:addRoad(10, 10, 10, 0, 5);
    self:addRoad(10, 10, 10, 0, -2);
end

-- Inits road segments
function Scene:reset_road() 
	
	local road_length = 1000 -- For the moment we use this value
	self.segments = {}
	
	local n = 1
	
	self:addStraight(100)
	self:addHill(ROAD.LENGTH.MEDIUM, ROAD.HILL.HIGH)
	--self:addSCurves()
	--self:addBumps();
	--self:addHill(ROAD.LENGTH.MEDIUM, ROAD.HILL.HIGH);
	self:addLowRollingHills()
	--self:addHill(ROAD.LENGTH.MEDIUM, ROAD.HILL.HIGH)
	self:addCurve(200, 6)
	self:addStraight(50)
	self:addCurve(100, -5)
	self:addStraight(100)
	--self:addDownhillToEnd();
		
	self.track_length = segment_length * #self.segments
end

-- Create a new segment with a given curve and y
function Scene:addSegment(curve, y)

	local n = #self.segments + 1
	local curve = curve or 0
	local y = y or 0
	
	local segment = {}
	segment.index = n
		
	local p1 = {}
	p1.world = { z = (n-1) * segment_length, y = self:lastY()}
	p1.camera = {}
	p1.screen = {}
	segment.p1 = p1
		
	local p2 = {}
	p2.world = { z = (n) * segment_length, y = y}
	p2.camera = {}
	p2.screen = {}
	segment.p2 = p2
	
	local color = math.floor(n/rumble_length) % 2
	if (color == 0) then
		segment.color = COLORS.DARK
	else
		segment.color = COLORS.LIGHT
	end
	
	segment.curve = curve
	segment.cars = {} -- cars on the road
	segment.sprites = {} -- trees... on side
	
	self.segments[n] = segment
end

-- Find segment including Z coordinate
function Scene:find_segment(z) 
	
	local segments = self.segments
	local num_segments = #segments
	local index = math.floor(z/segment_length) % num_segments
	
	return segments[index + 1]
end

-- Calculate new position (z value). Speed is a constant
function Scene:increase()
	
	local max = self.track_length
	local new_position = self.position + speed
	
	while (new_position >= max) do
		new_position = new_position - max
	end
	
	while (new_position < 0) do
		new_position = new_position + max
	end
	
	self.position = new_position
end

-- Draws all segments of the road
function Scene:draw_road()
	
	local position = self.position
	local road_width = road_width
	local old_road = self.road
	
	-- Redraw a new road sprite
	local road = Sprite.new()
	
	local segments = self.segments
	local base_segment = self:find_segment(self.position)
	
	self.curve = base_segment.curve -- used in parallax scrolling
	
	--local base_percent   = Utils.percentRemaining(position, segment_length);
	local player_percent = Utils.percentRemaining(position+playerZ, segment_length);
	playerY = Utils.interpolate(base_segment.p1.world.y, base_segment.p2.world.y, player_percent);
	local looped = base_segment.index < base_segment.index
	
	local climb = base_segment.p2.world.y - base_segment.p1.world.y
	if (climb > 0) then
		self.texture_player = texture_player[4]
	elseif(base_segment.curve > 0) then
		self.texture_player = texture_player[2]
	elseif (base_segment.curve < 0) then
		self.texture_player = texture_player[3]
	else
		self.texture_player = texture_player[1]
	end
	
	local maxy = application:getContentHeight()
	local num_segments = #segments
	
	--local t1= os.clock()
	
	local j = 1
	local x = 0
	local dx = 0
	
	for i = 1, draw_distance -1 do
		local index = (base_segment.index + i) % num_segments
		
		local segment = segments[index + 1]
		local p1 = segment.p1
		local p2 = segment.p2
		local curve = segment.curve
		local track_length = self.track_length
		
		-- Calculate project of p1 and p2 points that describes a segment
		Utils.project(p1, (playerX * road_width) - x, playerY + camera_height, position, camera_depth, road_width)
		Utils.project(p2, (playerX * road_width) - x -dx, playerY + camera_height, position, camera_depth, road_width)
		x = x + dx
		dx = dx + curve
		
		--print ("camera_depth ", camera_depth)
				
		if not (segment.p1.camera.z <= camera_depth or -- behind us
			segment.p2.screen.y >= segment.p1.screen.y or -- back face cull
			segment.p2.screen.y >= maxy) then       -- clip by (already rendered) segment
	
			--local t1= os.clock()
			
			local sprite_segment = Segment.new(
							p1.screen.x,
							p1.screen.y,
							p1.screen.w, 
							p2.screen.x,
							p2.screen.y,
							p2.screen.w,
							segment.fog,
							segment.color)
			road:addChild(sprite_segment)
			j = j + 1
			
			maxy = segment.p1.screen.y
			
			--local t2 = os.clock() - t1
			--print (t2)
		end
		
		--print ("i ", i)
		
	end
	
	self:addChild(road)
	
	-- Remove old road
	if (old_road and self:contains(old_road)) then
		self:removeChild(old_road)
	end
	
	self.road = road
	
	--print ("road children ", self.road:getNumChildren()) -- segments
	
	--local t2 = os.clock() - t1
	--print (t2)
end
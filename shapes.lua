
local lanes = 3

-- Simple shapes (rectangles and polygons)
Rectangle = Core.class(Mesh)

local width = application:getContentWidth()
local height = application:getContentHeight()

-- Constructor 
function Rectangle:init(x, y, width, height, color)
	
	local x1 = x + width
	local y1 = y + height
	
	self:setVertices(1, x, y,
					 2, x1, y,
					 3, x1, y1,
					 4, x, y1)
	
	self:setIndexArray(1, 2, 3,
					   1, 3, 4)
	
	self:setColorArray(color.grass,1, color.grass, 1, color.grass, 1, color.grass, 1)				
end

Polygon = Core.class(Mesh)

-- Constructor
function Polygon:init(x1, y1, x2, y2, x3, y3, x4, y4, color)
		
	self:setVertices(1, x1, y1,
					 2, x2, y2,
					 3, x3, y3,
					 4, x4, y4)
	
	self:setIndexArray(1, 2, 3,
					   1, 3, 4)
	
	self:setColorArray(color, 1, color, 1, color, 1, color, 1)
end


Segment = Core.class(Sprite) -- rectangles and polygons

-- Constructor
function Segment:init (x1, y1, w1, x2, y2, w2, fog, color) 
			
	--local t1= os.clock()
	
	local r1 = Segment.rumbleWidth(w1)
	local r2 = Segment.rumbleWidth(w2)
	local l1 = Segment.laneMarkerWidth(w1)
	local l2 = Segment.laneMarkerWidth(w2)
	
	--local t2 = os.clock() - t1
	--print (t2)
	
	--local width = application:getContentWidth()
	local rect = Rectangle.new(0, y2, width, y1 - y2, color)
	self:addChild(rect)
	
	local polygon1 = Polygon.new(x1-w1-r1, y1, x1-w1, y1, x2-w2, y2, x2-w2-r2, y2, color.rumble)
	self:addChild(polygon1)
	local polygon2 = Polygon.new(x1+w1+r1, y1, x1+w1, y1, x2+w2, y2, x2+w2+r2, y2, color.rumble)
	self:addChild(polygon2)
    local polygon3 = Polygon.new(x1-w1, y1, x1+w1, y1, x2+w2, y2, x2-w2, y2, color.road)
	self:addChild(polygon3)
	
	if (color.lane) then
		local lane_w1 = w1*2/lanes
		local lane_w2 = w2*2/lanes
		local lane_x1 = x1 - w1 + lane_w1
		local lane_x2 = x2 - w2 + lane_w2
		
		for lane =1, lanes-1 do
			local polygon_lane = Polygon.new(lane_x1 - l1/2, y1, lane_x1 + l1/2, y1, 
							lane_x2 + l2/2, y2, lane_x2 - l2/2, y2, color.lane)
			lane_x1 = lane_x1 + lane_w1
			lane_x2 = lane_x2 + lane_w2
			self:addChild(polygon_lane)
		end
		
	end
	
	return self
end

function Segment.rumbleWidth(projectedRoadWidth)
	return projectedRoadWidth/math.max(6, 2*lanes)
end

function Segment.laneMarkerWidth(projectedRoadWidth)
	return projectedRoadWidth/math.max(32, 8*lanes) 
end
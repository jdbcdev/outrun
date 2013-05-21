
local lanes = 3

-- Simple shapes (rectangles and polygons)
Rectangle = Core.class(Mesh)

local width = application:getContentWidth()
local height = application:getContentHeight()

Segment = Core.class(Mesh)

-- Constructor
function Segment:init (x1, y1, w1, x2, y2, w2, fog, color) 
			
	--local t1= os.clock()
	
	self.vertex_num = 0
	self.index_num = 0
	self.color_num = 0
	
	local r1 = Segment.rumbleWidth(w1)
	local r2 = Segment.rumbleWidth(w2)
	local l1 = Segment.laneMarkerWidth(w1)
	local l2 = Segment.laneMarkerWidth(w2)
	
	--local t2 = os.clock() - t1
	--print (t2)
	
	--local rect = Rectangle.new(0, y2, width, y1 - y2, color)
	--self:addChild(rect)
	
	self:set(0, y1, width,  y1, width, y2, 0, y2, color.grass)
	
	--[[
	local polygon1 = Polygon.new(x1-w1-r1, y1, x1-w1, y1, x2-w2, y2, x2-w2-r2, y2, color.rumble)
	self:addChild(polygon1)
	
	local polygon2 = Polygon.new(x1+w1+r1, y1, x1+w1, y1, x2+w2, y2, x2+w2+r2, y2, color.rumble)
	self:addChild(polygon2)
    local polygon3 = Polygon.new(x1-w1, y1, x1+w1, y1, x2+w2, y2, x2-w2, y2, color.road)
	self:addChild(polygon3)
	]]--
	
	self:set(x1-w1-r1, y1, x1-w1, y1, x2-w2, y2, x2-w2-r2, y2, color.rumble)
	self:set(x1+w1+r1, y1, x1+w1, y1, x2+w2, y2, x2+w2+r2, y2, color.rumble)
	self:set(x1-w1, y1, x1+w1, y1, x2+w2, y2, x2-w2, y2, color.road)
	
	if (color.lane) then
		local lane_w1 = w1*2/lanes
		local lane_w2 = w2*2/lanes
		local lane_x1 = x1 - w1 + lane_w1
		local lane_x2 = x2 - w2 + lane_w2
		
		for lane =1, lanes-1 do
			--local polygon_lane = Polygon.new(lane_x1 - l1/2, y1, lane_x1 + l1/2, y1, 
							--lane_x2 + l2/2, y2, lane_x2 - l2/2, y2, color.lane)
			self:set(lane_x1 - l1/2, y1, lane_x1 + l1/2, y1, 
							lane_x2 + l2/2, y2, lane_x2 - l2/2, y2, color.lane)
			lane_x1 = lane_x1 + lane_w1
			lane_x2 = lane_x2 + lane_w2
			--self:addChild(polygon_lane)
		end
	end
	
	return self
end

function Segment:set(x1, y1, x2, y2, x3, y3, x4, y4, color)
	
	-- Vertices
	local i = self.vertex_num + 1
	self:setVertices(i, x1, y1,
					 i + 1, x2, y2,
					 i + 2, x3, y3,
					 i + 3, x4, y4)
	
	self.vertex_num = i + 3
	
	-- Indices
	local j = self.index_num + 1
	
	self:setIndex(j, i)
	self:setIndex(j + 1, i + 1)
	self:setIndex(j + 2, i + 2)
	self:setIndex(j + 3, i)
	self:setIndex(j + 4, i + 2)
	self:setIndex(j + 5, i + 3)
	
	self.index_num = j + 5
	
	-- Colors
	local k = self.color_num + 1
	self:setColor(k, color, 1)
	self:setColor(k + 1, color, 1)
	self:setColor(k + 2, color, 1)
	self:setColor(k + 3, color, 1)
	
	self.color_num = k + 3
	
	--self:setIndexArray(1, 2, 3,
		--			   1, 3, 4)
	
	--self:setColorArray(color, 1, color, 1, color, 1, color, 1)
end

function Segment.rumbleWidth(projectedRoadWidth)
	return projectedRoadWidth/math.max(6, 2*lanes)
end

function Segment.laneMarkerWidth(projectedRoadWidth)
	return projectedRoadWidth/math.max(32, 8*lanes) 
end
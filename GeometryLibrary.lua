-- Math start --
function XTMap(value, min1, max1, min2, max2)
    return min2 + (value - min1) * (max2 - min2) / (max1 - min1)
end

function XTClamp(value, min, max)
    return math.max(min, math.min(value, max))
end

-- Math end --
-- Geometry start --
function XTLine(p1,p2)
	local line = {}
	line.p1 = p1
	line.p2 = p2
	
	function line:draw(color)
		XTSetScreenColor(color)
		screen.drawLine(self.p1.x, self.p1.y, self.p2.x, self.p2.y)
	end
	
	return line
end

function XTTriangle(p1,p2,p3)
	local triangle = {}
	triangle.p1 = p1
	triangle.p2 = p2
	triangle.p3 = p3
	
	function triangle:drawFilled(color)
		XTSetScreenColor(color)
		screen.drawTriangleF(self.p1.x, self.p1.y, self.p2.x, self.p2.y, self.p3.x, self.p3.y)
	end
	
	function triangle:drawOutline(color)
		XTSetScreenColor(color)
		screen.drawTriangleF(self.p1.x, self.p1.y, self.p2.x, self.p2.y, self.p3.x, self.p3.y)
	end
	
	return triangle
end

function XTConvexPolygon(pointArray)
	local polygon = {}
	polygon.pointArray = pointArray or {}
	
	function polygon:drawOutline(color)
		for i = 1, #self.pointArray do
		    local first = self.pointArray[i]
		    local second = self.pointArray[i % #self.pointArray + 1]
		    XTDrawLine(first, second, color)
		end
	end
	
	function polygon:drawFilled(color)
		setColorRGB(color)
		for i = 2, #self.pointArray - 1 do
		    XTDrawFilledTriangle(
		    	self.pointArray[1],
		    	self.pointArray[i],
		    	self.pointArray[i+1]
    		)
		end	
	end
	
	return polygon
end

function XTRectangle(origin, width, height)
	local rectangle = {}
    rectangle.origin = origin or XTPoint(0,0)
    rectangle.width = width or 0
    rectangle.height = height or 0

    function rectangle:drawOutline(color)
		XTSetScreenColor(color)
		screen.drawRect(self.origin.x, self.origin.y, self.width, self.height)
    end

	function rectangle:drawFilled(color)
		XTSetScreenColor(color)
		screen.drawRectF(self.origin.x, self.origin.y, self.width, self.height)
	end
	
	function rectangle:drawGradient(colorStart, colorEnd)
		for i = 0, width, 1 do
		    currentColor = XTColor(
		    	colorStart.r + i*(colorEnd.r-colorStart.r)/self.width,
		    	colorStart.g + i*(colorEnd.g-colorStart.g)/self.width,
		    	colorStart.b + i*(colorEnd.b-colorStart.b)/self.width,
		    	colorStart.a + i*(colorEnd.a-colorStart.a)/self.width
	    	)
	    	XTSetScreenColor(currentColor)
	    	screen.drawRectF(self.origin.x+i, self.origin.y, 1, self.height)
		end	
	end
    
    return rectangle
end

function XTCircle(origin, radius)
	local circle = {}
    circle.origin = origin or XTPoint(0,0)
    circle.radius = radius or 0
    
    local innerSector = XTSector(origin, radius, 0, 360)
    
    function circle:drawOutline(color)
    	innerSector:drawOutline(color)
    end
    
    function circle:drawFilled(color)
    	innerSector:drawFilled(color)
    end

    return circle
end

function XTSector(origin, radius, startAngle, endAngle)
	local sector = {}
    sector.origin = origin or XTPoint(0,0)
    sector.radius = radius or 0
    sector.startAngle = startAngle or 0
    sector.endAngle = endAngle or 0
    
    local function innerDrawStepByStep(drawFunction)
    	local step = 9
		if(sector.startAngle > sector.endAngle) 
		then sector.startAngle, sector.endAngle = sector.endAngle, sector.startAngle
		end
	
		local function getPointOnCircumferenceAt(angleInDegrees)
			local angleInRadians = math.rad(angleInDegrees)
		    local x = origin.x + radius * math.cos(angleInRadians)
		    local y = origin.y + radius * math.sin(angleInRadians)
		    return XTPoint(x,y)
		end
		
		local previousPoint = getPointOnCircumferenceAt(sector.startAngle)
		for i = sector.startAngle + step, sector.endAngle, step do
			local currentPoint = getPointOnCircumferenceAt(i)
			
			drawFunction(previousPoint, currentPoint)

			previousPoint = currentPoint
		end
		
		local lastPoint = getPointOnCircumferenceAt(sector.endAngle)
		drawFunction(previousPoint, lastPoint)
    end
    
    function sector:drawOutline(color)
    	local function innerDrawOutline(point1, point2)
    		XTLine(point1, point2):draw(color)
    	end
    	
    	innerDrawStepByStep(innerDrawOutline)
    end

	function sector:drawFilled(color)
    	local function innerDrawFilled(point1, point2)
    		XTTriangle(origin, point1, point2):drawFilled(color)
    	end
    	
    	innerDrawStepByStep(innerDrawFilled)
	end
	
    return sector
end

-- Geometry end --
-- Colors start --

function XTColor(r, g, b, a)
    local color = {}
    color.r = r or 0
    color.g = g or 0
    color.b = b or 0
    color.a = a or 255
    
    function color:withAlpha(newA)
		return XTColor(self.r, self.g, self.b, newA)
	end
    
    return color
end

function XTSetScreenColor(color)
	screen.setColor(color.r, color.g, color.b, color.a)
end

-- Colors end --
-- Point start --

function XTPoint(x,y)
    local point = {}
    point.x = x or 0
    point.y = y or 0
    
    function point:rotate(pivot, angleInDegrees)
    	local angleInRadians = angleInDegrees * math.pi / 180
		local s = math.sin(angleInRadians);
		local c = math.cos(angleInRadians);
		rotatedX = ((self.x - pivot.x) * c - (self.y - pivot.y) * s) + pivot.x;
		rotatedY = ((self.x - pivot.x) * s + (self.y - pivot.y) * c) + pivot.y;
		return XTPoint(rotatedX, rotatedY)
	end
    
    return point
end

-- Point end

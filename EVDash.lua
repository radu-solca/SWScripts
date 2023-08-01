-- Tick function that will be executed every logic tick
function onTick()
	speedInKmH = math.floor(input.getNumber(6) * 3.6 + 0.5)
	batteryPercent = math.floor(input.getNumber(7) * 100 +0.5)
	gear = input.getNumber(8)
end


-- Draw function that will be executed when this script renders to a screen
function onDraw()
	
	colorBackground = XTColor(10,10,10)
	colorBarFull = XTColor(150, 150, 255)
	colorBarEmpty = XTColor(150, 150, 255, 20)
	colorText = XTColor(200,200,255)

	-- background -- 

	XTRectangle(XTPoint(0, 0), screen.getWidth() * 0.333, screen.getHeight())
		:drawGradient(colorBackground, colorBackground:withAlpha(0))
	
	XTRectangle(XTPoint(screen.getWidth() * 0.666, 0), screen.getWidth() * 0.333, screen.getHeight())
		:drawGradient(colorBackground:withAlpha(0), colorBackground)
	
	-- gauges --
	
	Gauge(
		XTSector(
			XTPoint(screen.getHeight()*0.333, screen.getHeight()*0.666),
			screen.getHeight()*0.5,
			45,
			-135
		),
		"KmH",
		0,
		150,
		speedInKmH,
		colorBackground,
		colorBarFull,
		colorText,
		colorBarEmpty
	):draw()

	Gauge(
		XTSector(
			XTPoint(screen.getWidth() - screen.getHeight()*0.333, screen.getHeight()*0.666),
			screen.getHeight()*0.5,
			135,
			315
		),
		"BAT",
		0,
		100,
		batteryPercent,
		colorBackground,
		colorBarFull,
		colorText,
		colorBarEmpty
	):draw()

	-- gear selector --

	local p1 = XTPoint(screen.getWidth()*0.29, screen.getHeight()*0.9)
	local p2 = p1:addY(-8)
	local p3 = p1:addY(-16)
	local p1_ = p1:addX(3)
	local p2_ = p2:addX(3)
	local p3_ = p3:addX(3)
	
	XTLine(p1,p3):draw(colorBackground)
	XTLine(p1,p1_):draw(colorBackground)
	XTLine(p2,p2_):draw(colorBackground)
	XTLine(p3,p3_):draw(colorBackground)
	
	XTRectangle(p1_:addX(2):addY(-2.5),5,5):drawTextBox("R", gear == -1 and colorText or colorBackground)
	XTRectangle(p2_:addX(2):addY(-2.5),5,5):drawTextBox("N", gear == 0 and colorText or colorBackground)
	XTRectangle(p3_:addX(2):addY(-2.5),5,5):drawTextBox("D", gear == 1 and colorText or colorBackground)
	
end

function Gauge(sector, label, min, max, value, colorBG, colorText, colorBarFull, colorBarEmpty)
	local gauge = {}
	gauge.sector = sector
	gauge.label = label
	gauge.min = min
	gauge.max = max
	gauge.value = value
	gauge.colorBG = colorBG
	gauge.colorText = colorText
	gauge.colorBarFull = colorBarFull
	gauge.colorBarEmpty = colorBarEmpty

	function gauge:draw()
		
		local sAng, eAng, org, radius = self.sector.startAngle, self.sector.endAngle, self.sector.origin, self.sector.radius
		local barAngle = sAng + (self.value - self.min) * (eAng - sAng) / (self.max - self.min)
		
		XTCircle(org, radius):drawFilled(self.colorBG)
		XTSector(org,radius-1,sAng,eAng):drawFilled(self.colorBarEmpty)
		XTSector(org,radius-1,sAng,barAngle):drawFilled(self.colorBarFull)

		XTCircle(org, radius*0.75):drawFilled(self.colorBG)
		XTRectangle(XTPoint(org.x-16, org.y-5), 32, 5)
			:drawTextBox(self.value .. "\n" .. self.label, self.colorText)
	end
		
	return gauge
end

----------------------- Library ---------------------------------------------------------------
function XTPoint(x,y)
    local point = {}
    point.x = x or 0
    point.y = y or 0
    
    function point:rotate(pivot, angle)
    	local radians = angle * math.pi / 180
		local s = math.sin(radians);
		local c = math.cos(radians);
		rX = ((self.x - pivot.x) * c - (self.y - pivot.y) * s) + pivot.x;
		rY = ((self.x - pivot.x) * s + (self.y - pivot.y) * c) + pivot.y;
		return XTPoint(rX, rY)
    end

	function point:addX(deltaX)
		return XTPoint(self.x + deltaX, self.y)
	end
	
	function point:addY(deltaY)
		return XTPoint(self.x, self.y + deltaY)
	end
    
    return point
end

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

	return triangle
end

function XTRectangle(origin, width, height)
	local rectangle = {}
    rectangle.origin = origin or XTPoint(0,0)
    rectangle.width = width or 0
    rectangle.height = height or 0
	
	function rectangle:drawTextBox(text, color)
		XTSetScreenColor(color)
		screen.drawTextBox(self.origin.x, self.origin.y, self.width, self.height, text, 0)
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

function XTColor(r, g, b, a)
    local color = {}
    color.r = r or 255
    color.g = g or 255
    color.b = b or 255
    color.a = a or 255
    
    function color:withAlpha(newA)
		return XTColor(self.r, self.g, self.b, newA)
	end
    
    return color
end

function XTSetScreenColor(color)
	screen.setColor(color.r, color.g, color.b, color.a)
end


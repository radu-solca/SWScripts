-- Tick function that will be executed every logic tick
function onTick()
	speedInKmH = math.floor(input.getNumber(6) * 3.6 + 0.5)
	batteryPercent = math.floor(input.getNumber(7) * 100 +0.5)
	gear = input.getNumber(8)
	RPM = math.floor(input.getNumber(9) * 60)
	tempInCelsius = input.getNumber(10)
	fuelRatio = input.getNumber(11)
end


-- Draw function that will be executed when this script renders to a screen
function onDraw()
	
	colorBackground = XTColor(10,10,10)
	colorBackgroundDark = XTColor(8,8,8)
	colorPrimary = XTColor(150, 150, 255)
	colorSecondary = XTColor(50, 50, 80)
	colorHighlight = XTColor(255, 0, 0)
	
	screenScale = math.min(screen.getWidth(), screen.getHeight())

	drawLeftSide()	
end

function drawLeftSide()
	local origin = XTPoint(0,0)
	local speedoCenter = origin:addX(2):addY(screenScale - 3)
	local outerCircle = XTCircle(speedoCenter, screenScale - 7)
	local innerCircle = XTCircle(speedoCenter, screenScale - 7 - 3)
	
	local startAngle = XTMap(speedInKmH, 0, 200, 0, -90)
	outerCircle:drawSectorOutline(startAngle,0, colorHighlight)
	
	XTLine(
		outerCircle:pointAtAngle(0),
		innerCircle:pointAtAngle(0)
	):draw(colorPrimary)


	outerCircle:pointAtAngle(-22.5):draw(colorPrimary)

	XTLine(
		outerCircle:pointAtAngle(-45),
		innerCircle:pointAtAngle(-45)
	):draw(colorPrimary)

	outerCircle:pointAtAngle(-67.5):draw(colorPrimary)

	XTLine(
		outerCircle:pointAtAngle(-90),
		innerCircle:pointAtAngle(-90)
	):draw(colorPrimary)


	XTRectangle(origin:addX(2):addY(screenScale - 15),15,7):drawFilled(colorBackgroundDark):drawTextBox(speedInKmH, colorPrimary)
	XTRectangle(origin:addX(2):addY(screenScale - 9),15,7):drawTextBox("KMH", colorPrimary)
	
	local gearTable = {
	    [-1] = "R",
	    [0] = "N",
	    [1] = "1",
	    [2] = "2",
	    [3] = "3",
	    [4] = "4",
	    [5] = "5",
	}
	XTRectangle(origin:addX(20):addY(3),10,5):drawFilled(colorBackgroundDark):drawTextBox(gearTable[gear], colorPrimary)
end

----------------------- Library ---------------------------------------------------------------

function XTMap(value, min1, max1, min2, max2)
    return min2 + (value - min1) * (max2 - min2) / (max1 - min1)
end

function XTClamp(value, min, max)
    return math.max(min, math.min(value, max))
end

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
	
	function point:draw(color)
		XTSetScreenColor(color)
		screen.drawRectF(self.x,self.y,1,1)
		return self
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
		return self
	end
	
	return line
end

function XTRectangle(origin, width, height)
	local rectangle = {}
    rectangle.origin = origin or XTPoint(0,0)
    rectangle.width = width or 0
    rectangle.height = height or 0

    function rectangle:drawOutline(color)
		XTSetScreenColor(color)
		screen.drawRect(self.origin.x, self.origin.y, self.width, self.height)
		return self
    end

	function rectangle:drawFilled(color)
		XTSetScreenColor(color)
		screen.drawRectF(self.origin.x, self.origin.y, self.width, self.height)
		return self
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
		return self
	end
	
	function rectangle:drawTextBox(text, color, alignment)
		alignment = alignment or 0
		XTSetScreenColor(color)
		screen.drawTextBox(self.origin.x, self.origin.y, self.width, self.height, text, alignment)
		return self
	end
    
    return rectangle
end

function XTCircle(origin, radius)
	local circle = {}
	circle.origin = origin or XTPoint(0,0)
	circle.radius = radius or 0

	function circle:pointAtAngle(angleInDegrees)
		local angleInRadians = angleInDegrees * math.pi / 180
		local x = self.origin.x + self.radius * math.cos(angleInRadians)
		local y = self.origin.y + self.radius * math.sin(angleInRadians)
		return XTPoint(x, y)
	end
	
	function circle:drawSectorOutline(startAngle, endAngle, color)
    	local step = 9
		if(startAngle > endAngle) 
		then startAngle, endAngle = endAngle, startAngle
		end

		local previousPoint = self:pointAtAngle(startAngle)
		for i = startAngle + step, endAngle, step do
			local currentPoint = self:pointAtAngle(i)
			
			XTLine(previousPoint, currentPoint):draw(color)

			previousPoint = currentPoint
		end
		
		local lastPoint = self:pointAtAngle(endAngle)
		XTLine(previousPoint, lastPoint):draw(color)
		
		return self
    end

	return circle
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


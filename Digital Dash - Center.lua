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

	drawCenterSide()
end


function drawCenterSide()
	local origin = XTPoint(screen.getWidth()/3, 0)
	
	
	local fuelMid = origin:addX(screenScale/2):addY(screenScale - 3)
	
	local fuelEmpty = fuelMid:addX(-screenScale/2 + 1)
	local fuelQuarter = fuelMid:addX(-screenScale/4)
	local fuelThreeQuarters = fuelMid:addX(screenScale/4)
	local fuelFull = fuelMid:addX(screenScale/2 - 1)
	
	XTLine(fuelEmpty, fuelEmpty:addY(-4)):draw(colorPrimary)
	XTLine(fuelQuarter, fuelQuarter:addY(-2)):draw(colorPrimary)
	XTLine(fuelMid, fuelMid:addY(-3)):draw(colorPrimary)
	XTLine(fuelThreeQuarters, fuelThreeQuarters:addY(-2)):draw(colorPrimary)
	XTLine(fuelFull, fuelFull:addY(-4)):draw(colorPrimary)
	
	
	local fuelIndicator = fuelEmpty:addX(XTMap(fuelRatio, 0, 1, 1, fuelFull.x - fuelEmpty.x - 1))
	XTLine(fuelIndicator, fuelIndicator:addY(-4)):draw(colorHighlight)
	
	XTLine(fuelEmpty, fuelFull):draw(colorPrimary)
	XTRectangle(fuelEmpty:addX(-1):addY(-9),5,5):drawTextBox("E", colorPrimary)
	XTRectangle(fuelFull:addX(-3):addY(-9),5,5):drawTextBox("F", colorPrimary)
	
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


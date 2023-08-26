function XTStopWatch()
    local stopWatch = {}
    stopWatch.running = false
    stopWatch.ticks = 0
    stopWatch.previousTime = "00:00"
    
    function stopWatch:Tick()
    	if(not self.running) then return end
    	self.ticks = self.ticks + 1
    end
    
    function stopWatch:Toggle()
    	self.running = not self.running
    end
    
    function stopWatch:Reset()
    	self.previousTime = self:GetTimeAsText()
    	self.ticks = 0
    end

	function stopWatch:GetSeconds()
		return math.floor(self.ticks/60)%60
	end
	
	function stopWatch:GetMinutes()
		return math.floor(self.ticks/60/60)%100
	end
	
	function stopWatch:GetTimeAsText()
		local s = self:GetSeconds()
		local m = self:GetMinutes()
		return ""..(m<10 and "0"..m or m)..":"..(s<10 and "0"..s or s)
	end
    
    return stopWatch
end

function XTTouch()
	local touch = {}
	touch.pressed = input.getBool(1)
	touch.width = input.getNumber(1)
	touch.height = input.getNumber(2)
    touch.x = input.getNumber(3)
    touch.y = input.getNumber(4)
    
    return touch
end

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
	
	function rectangle:drawTextBox(text,color,alingment)
		alingment = alingment or 0
		XTSetScreenColor(color)
		screen.drawTextBox(self.origin.x,self.origin.y+(self.height/2)-2.5,self.width,self.height,text,alingment)
		return self
	end
	
	function rectangle:IsTouched(touch)
		
		if(not touch.pressed) then return false end
		
		return touch.x > self.origin.x 
			and touch.x < self.origin.x + self.width
			and touch.y > self.origin.y
			and touch.y < self.origin.y + self.height
	end
	
	rectangle.actionExecuted = false
	function rectangle:OnTouch(touch, action)
		
		if(not self:IsTouched(touch)) then
			self.actionExecuted = false
			return 
		end
		
		if(self.actionExecuted == true) then
			return
		end
		
		action()
		self.actionExecuted = true
	end
	
	return rectangle
end

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

-- LIBRARY --

stopWatch = XTStopWatch()

colorBackground = XTColor(10,10,10)
colorBackgroundDark = XTColor(8,8,8)
colorPrimary = XTColor(150,150,255)
colorSecondary = XTColor(50,50,80)

width, height = 32, 32
buttonWidth, buttoneHeight = 27, 7
timeWidth = 27

oldTimeBox = XTRectangle(XTPoint(width/2-buttonWidth/2,height-buttoneHeight-23), timeWidth, buttoneHeight)
timeBox = XTRectangle(XTPoint(width/2-buttonWidth/2,height-buttoneHeight-17), timeWidth, buttoneHeight)
toggleBox = XTRectangle(XTPoint(width/2-buttonWidth/2,height-buttoneHeight*2-2), buttonWidth, buttoneHeight) 
resetBox = XTRectangle(XTPoint(width/2-buttonWidth/2,height-buttoneHeight-2), buttonWidth, buttoneHeight)

function onTick()
	local reset = input.getBool(32)
	
	if(reset) then stopWatch:Reset() end
    stopWatch:Tick()
    
    touch = XTTouch()
    toggleBox:OnTouch(touch, function() stopWatch:Toggle() end)
    resetBox:OnTouch(touch, function() stopWatch:Reset() end)
end

function onDraw()

	XTRectangle(XTPoint(0,0), width-1, height-1):drawFilled(colorBackground):drawOutline(colorPrimary)
	
	oldTimeBox
        :drawFilled(colorBackgroundDark)
        :drawTextBox(stopWatch.previousTime, colorSecondary)
	
	timeBox
        :drawFilled(colorBackgroundDark)
        :drawTextBox(stopWatch:GetTimeAsText(), colorPrimary)

	toggleBox
        :drawFilled(toggleBox:IsTouched(touch) and colorPrimary or colorBackgroundDark)
		:drawTextBox(stopWatch.running and "STOP" or "START",toggleBox:IsTouched(touch) and colorBackgroundDark or colorPrimary)
		:drawOutline(colorSecondary)

	resetBox
        :drawFilled(resetBox:IsTouched(touch) and colorPrimary or colorBackgroundDark)
		:drawTextBox("RESET",resetBox:IsTouched(touch) and colorBackgroundDark or colorPrimary)
		:drawOutline(colorSecondary)

end


function onTick()
	local a = property.getNumber("rps channel")
	RPM = math.floor(input.getNumber(a) * 60)
	local b = property.getNumber("temperature channel")
	tempInCelsius = math.floor(input.getNumber(b))
end
function onDraw()
	colorBackground = XTColor(10,10,10)
	colorBackgroundDark = XTColor(8,8,8)
	colorPrimary = XTColor(150,150,255)
	colorSecondary = XTColor(50,50,80)
	colorHighlight = XTColor(255,0,0)
	colorGood = XTColor(0,80,0)
	colorBad = XTColor(80,0,0)
	screenScale = math.min(screen.getWidth(),screen.getHeight())
	drawRightSide()
end
function drawRightSide()
	local c = XTPoint(screen.getWidth() / 3 * 2,0)
	local d = c:addX(2):addY(screenScale - 9)
	
	local boxWidth = screenScale - 5
	local boxHeight = screenScale / 4 - 2
	
	local tempRectangle = XTRectangle(d,boxWidth, boxHeight)
	
	tempRectangle:drawGradient(colorGood, colorBad)
	
	local tempMaskWidth = boxWidth * XTClamp(XTMap(tempInCelsius, 20, 115, 1, 0), 0, 1)
	local tempMaskOffset = boxWidth - tempMaskWidth
	
	XTRectangle(d:addX(tempMaskOffset),tempMaskWidth, boxHeight):drawFilled(colorBackgroundDark)
	
	XTRectangle(d:addY(1),boxWidth, boxHeight):drawTextBox(tempInCelsius .. "C",colorPrimary)
	local e = d:addY(- 7)
	XTRectangle(e:addY(1),boxWidth, boxHeight):drawTextBox("Tmp",colorPrimary)
	local f = e:addY(- 7)
	
	tempRectangle:drawOutline(colorPrimary)
	
	local rpmRectangle = XTRectangle(f,boxWidth, boxHeight)
	
	rpmRectangle:drawGradient(colorGood, colorBad)
	
	local rpmMaskWidth = boxWidth * XTClamp(XTMap(RPM, 0, 1500, 1, 0), 0, 1)
	local rpmMaskOffset = boxWidth - rpmMaskWidth
	XTRectangle(f:addX(rpmMaskOffset),rpmMaskWidth, boxHeight):drawFilled(colorBackgroundDark)
	
	rpmRectangle:drawOutline(colorPrimary)
	
	XTRectangle(f:addY(1),boxWidth, boxHeight):drawTextBox(RPM,colorPrimary)
	local g = f:addY(- 7)
	XTRectangle(g:addY(1),boxWidth, boxHeight):drawTextBox("RPM",colorPrimary)
end




function XTMap(h,i,j,k,l)
	return k + (h - i) * (l - k) / (j - i)
end
function XTClamp(h,m,n)
	return math.max(m,math.min(h,n))
end
function XTPoint(o,p)
	local q = {}
	q.x = o or 0
	q.y = p or 0
	function q:rotate(r,s)
		local t = s * math.pi / 180
		local u = math.sin(t)
		local v = math.cos(t)
		rX = (self.x - r.x) * v - (self.y - r.y) * u + r.x
		rY = (self.x - r.x) * u + (self.y - r.y) * v + r.y
		return XTPoint(rX,rY)
	end
	function q:addX(w)
		return XTPoint(self.x + w,self.y)
	end
	function q:addY(x)
		return XTPoint(self.x,self.y + x)
	end
	function q:draw(y)
		XTSetScreenColor(y)
		screen.drawRectF(self.x,self.y,1,1)
		return self
	end
	return q
end
function XTLine(z,A)
	local B = {}
	B.p1 = z
	B.p2 = A
	function B:draw(y)
		XTSetScreenColor(y)
		screen.drawLine(self.p1.x,self.p1.y,self.p2.x,self.p2.y)
		return self
	end
	return B
end
function XTRectangle(c,C,D)
	local E = {}
	E.origin = c or XTPoint(0,0)
	E.width = C or 0
	E.height = D or 0
	function E:drawOutline(y)
		XTSetScreenColor(y)
		screen.drawRect(self.origin.x,self.origin.y,self.width,self.height)
		return self
	end
	function E:drawFilled(y)
		XTSetScreenColor(y)
		screen.drawRectF(self.origin.x,self.origin.y,self.width,self.height)
		return self
	end
	function E:drawGradient(F,G)
		for H=0, C, 1 do
			currentColor = XTColor(F.r + H * (G.r - F.r) / self.width,F.g + H * (G.g - F.g) / self.width,F.b + H * (G.b - F.b) / self.width,F.a + H * (G.a - F.a) / self.width)
			XTSetScreenColor(currentColor)
			screen.drawRectF(self.origin.x + H,self.origin.y,1,self.height)
		end
		return self
	end
	function E:drawTextBox(I,y,J)
		J = J or 0
		XTSetScreenColor(y)
		screen.drawTextBox(self.origin.x,self.origin.y,self.width,self.height,I,J)
		return self
	end
	return E
end
function XTColor(K,L,M,N)
	local y = {}
	y.r = K or 255
	y.g = L or 255
	y.b = M or 255
	y.a = N or 255
	function y:withAlpha(O)
		return XTColor(self.r,self.g,self.b,O)
	end
	return y
end
function XTSetScreenColor(y)
	screen.setColor(y.r,y.g,y.b,y.a)
end
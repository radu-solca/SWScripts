-- warning: mapping not found --

function onTick()
end
function onDraw()
	colorBackground = XTColor(10,10,10)
	colorBackgroundDark = XTColor(8,8,8)
	colorPrimary = XTColor(150,150,255)
	colorSecondary = XTColor(50,50,80)
	colorHighlight = XTColor(255,0,0)
	screenScale = math.min(screen.getWidth(),screen.getHeight())
	drawBackground()
end
function drawBackground()
	XTRectangle(XTPoint(1,1),screen.getWidth() / 3 - 2,screen.getHeight() - 3):drawFilled(colorBackground):drawOutline(colorSecondary)
	XTRectangle(XTPoint(1 + screen.getWidth() / 3 * 2,1),screen.getWidth() / 3 - 3,screen.getHeight() - 3):drawFilled(colorBackground):drawOutline(colorSecondary)
	XTRectangle(XTPoint(0,0),screen.getWidth() - 1,screen.getHeight() - 1):drawOutline(colorPrimary)
end
function XTPoint(a,b)
	local c = {}
	c.x = a or 0
	c.y = b or 0
	function c:rotate(d,e)
		local f = e * math.pi / 180
		local g = math.sin(f)
		local h = math.cos(f)
		rX = (self.x - d.x) * h - (self.y - d.y) * g + d.x
		rY = (self.x - d.x) * g + (self.y - d.y) * h + d.y
		return XTPoint(rX,rY)
	end
	function c:addX(i)
		return XTPoint(self.x + i,self.y)
	end
	function c:addY(j)
		return XTPoint(self.x,self.y + j)
	end
	function c:draw(k)
		XTSetScreenColor(k)
		screen.drawRectF(self.x,self.y,1,1)
		return self
	end
	return c
end
function XTRectangle(l,m,n)
	local o = {}
	o.origin = l or XTPoint(0,0)
	o.width = m or 0
	o.height = n or 0
	function o:drawOutline(k)
		XTSetScreenColor(k)
		screen.drawRect(self.origin.x,self.origin.y,self.width,self.height)
		return self
	end
	function o:drawFilled(k)
		XTSetScreenColor(k)
		screen.drawRectF(self.origin.x,self.origin.y,self.width,self.height)
		return self
	end
	function o:drawGradient(p,q)
		for r=0, m, 1 do
			currentColor = XTColor(p.r + r * (q.r - p.r) / self.width,p.g + r * (q.g - p.g) / self.width,p.b + r * (q.b - p.b) / self.width,p.a + r * (q.a - p.a) / self.width)
			XTSetScreenColor(currentColor)
			screen.drawRectF(self.origin.x + r,self.origin.y,1,self.height)
		end
		return self
	end
	function o:drawTextBox(s,k,t)
		t = t or 0
		XTSetScreenColor(k)
		screen.drawTextBox(self.origin.x,self.origin.y,self.width,self.height,s,t)
		return self
	end
	return o
end
function XTColor(u,v,w,x)
	local k = {}
	k.r = u or 255
	k.g = v or 255
	k.b = w or 255
	k.a = x or 255
	function k:withAlpha(y)
		return XTColor(self.r,self.g,self.b,y)
	end
	return k
end
function XTSetScreenColor(k)
	screen.setColor(k.r,k.g,k.b,k.a)
end
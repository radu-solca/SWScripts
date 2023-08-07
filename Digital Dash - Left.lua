-- warning: mapping not found --

function onTick()
	local a = property.getNumber("speed channel")
	speedInKmH = math.abs(math.floor(input.getNumber(a) * 3.6 + 0.5))
	local rpsChannel = property.getNumber("rps channel")
	rps = input.getNumber(rpsChannel)
	local b = property.getNumber("gear channel")
	gear = input.getNumber(b)
end
function onDraw()
	colorBackground = XTColor(10,10,10)
	colorBackgroundDark = XTColor(8,8,8)
	colorPrimary = XTColor(150,150,255)
	colorSecondary = XTColor(50,50,80)
	colorHighlight = XTColor(255,0,0)
	screenScale = math.min(screen.getWidth(),screen.getHeight())
	drawLeftSide()
end
function drawLeftSide()
	local c = XTPoint(0,0)
	local d = c:addX(2):addY(screenScale - 3)
	local e = XTCircle(d,screenScale - 7)
	local f = XTCircle(d,screenScale - 7 - 3)
	local g = XTClamp(XTMap(speedInKmH,0,220,0,- 90),- 90,0)
	e:drawSectorOutline(g,0,colorHighlight)
	XTLine(e:pointAtAngle(0),f:pointAtAngle(0)):draw(colorPrimary)
	e:pointAtAngle(- 22.5):draw(colorPrimary)
	XTLine(e:pointAtAngle(- 45),f:pointAtAngle(- 45)):draw(colorPrimary)
	e:pointAtAngle(- 67.5):draw(colorPrimary)
	XTLine(e:pointAtAngle(- 90),f:pointAtAngle(- 90)):draw(colorPrimary)
	XTRectangle(c:addX(2):addY(screenScale - 15),15,7):drawFilled(colorBackgroundDark):drawTextBox(speedInKmH,colorPrimary)
	XTRectangle(c:addX(2):addY(screenScale - 9),15,7):drawTextBox("KMH",colorPrimary)
	
	local h = {[- 1]="R",[0]="N",[1]="1",[2]="2",[3]="3",[4]="4",[5]="5"}
	XTRectangle(c:addX(20):addY(3),10,5):drawFilled(colorBackgroundDark):drawTextBox(h[gear],colorPrimary)
	
	if(rps > 20 and gear ~= 5 and gear ~= -1) then
		c:addX(20):addY(3):draw(colorHighlight)
	end
end
function XTMap(i,j,k,l,m)
	return l + (i - j) * (m - l) / (k - j)
end
function XTClamp(i,n,o)
	return math.max(n,math.min(i,o))
end
function XTPoint(p,q)
	local r = {}
	r.x = p or 0
	r.y = q or 0
	function r:rotate(s,t)
		local u = t * math.pi / 180
		local v = math.sin(u)
		local w = math.cos(u)
		rX = (self.x - s.x) * w - (self.y - s.y) * v + s.x
		rY = (self.x - s.x) * v + (self.y - s.y) * w + s.y
		return XTPoint(rX,rY)
	end
	function r:addX(x)
		return XTPoint(self.x + x,self.y)
	end
	function r:addY(y)
		return XTPoint(self.x,self.y + y)
	end
	function r:draw(z)
		XTSetScreenColor(z)
		screen.drawRectF(self.x,self.y,1,1)
		return self
	end
	return r
end
function XTLine(A,B)
	local C = {}
	C.p1 = A
	C.p2 = B
	function C:draw(z)
		XTSetScreenColor(z)
		screen.drawLine(self.p1.x,self.p1.y,self.p2.x,self.p2.y)
		return self
	end
	return C
end
function XTRectangle(c,D,E)
	local F = {}
	F.origin = c or XTPoint(0,0)
	F.width = D or 0
	F.height = E or 0
	function F:drawOutline(z)
		XTSetScreenColor(z)
		screen.drawRect(self.origin.x,self.origin.y,self.width,self.height)
		return self
	end
	function F:drawFilled(z)
		XTSetScreenColor(z)
		screen.drawRectF(self.origin.x,self.origin.y,self.width,self.height)
		return self
	end
	function F:drawGradient(G,H)
		for I=0, D, 1 do
			currentColor = XTColor(G.r + I * (H.r - G.r) / self.width,G.g + I * (H.g - G.g) / self.width,G.b + I * (H.b - G.b) / self.width,G.a + I * (H.a - G.a) / self.width)
			XTSetScreenColor(currentColor)
			screen.drawRectF(self.origin.x + I,self.origin.y,1,self.height)
		end
		return self
	end
	function F:drawTextBox(J,z,K)
		K = K or 0
		XTSetScreenColor(z)
		screen.drawTextBox(self.origin.x,self.origin.y,self.width,self.height,J,K)
		return self
	end
	return F
end
function XTCircle(c,L)
	local M = {}
	M.origin = c or XTPoint(0,0)
	M.radius = L or 0
	function M:pointAtAngle(N)
		local O = N * math.pi / 180
		local p = self.origin.x + self.radius * math.cos(O)
		local q = self.origin.y + self.radius * math.sin(O)
		return XTPoint(p,q)
	end
	function M:drawSectorOutline(g,P,z)
		local Q = 9
		if g > P then
			g, 			P = P, g
		end
		local R = self:pointAtAngle(g)
		for I=g + Q, P, Q do
			local S = self:pointAtAngle(I)
			XTLine(R,S):draw(z)
			R = S
		end
		local T = self:pointAtAngle(P)
		XTLine(R,T):draw(z)
		return self
	end
	return M
end
function XTColor(U,V,W,X)
	local z = {}
	z.r = U or 255
	z.g = V or 255
	z.b = W or 255
	z.a = X or 255
	function z:withAlpha(Y)
		return XTColor(self.r,self.g,self.b,Y)
	end
	return z
end
function XTSetScreenColor(z)
	screen.setColor(z.r,z.g,z.b,z.a)
end
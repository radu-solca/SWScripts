-- Tick function that will be executed every logic tick
function onTick()
	local PORTRealRotChannel = property.getNumber("PORT Real Rotation Channel")
	local STBDRealRotChannel = property.getNumber("STBD Real Rotation Channel")
	
	PORTRealRot = input.getNumber(PORTRealRotChannel) * 90 * 4
	STBDRealRot = input.getNumber(STBDRealRotChannel) * 90 * 4
end


-- Draw function that will be executed when this script renders to a screen
function onDraw()
	setConstants()
	
	drawPORTPodInfo(PORTRealRot, 0)
	drawSTBDPodInfo(STBDRealRot, 0)
end

----------------------- Constants ---------------------------------------------------------------

function setConstants() --TODO see if you can do this only ONCE. Those are called constants for a reason.
	Constants = {}
	Constants.Colors = {
		debugWhite = {255, 255, 255},
		debugGreen = {0, 255, 0},
		debugRed = {255, 0, 0}
	}
	
	Constants.ScreenWidth = screen.getWidth()
	Constants.ScreenHeight = screen.getHeight()
	
	Constants.PodInfoRadius = Constants.ScreenHeight / 2 * 0.9
	Constants.BarHeight = Constants.PodInfoRadius*0.9
	
	Constants.PORTCenter = { 
		x = Constants.PodInfoRadius*1.2, 
		y = Constants.ScreenHeight / 2
	}
	Constants.PORTDegreePoints = getDegreePoints(Constants.PORTCenter)
	Constants.PORTFWDBarPoints = getFWDBarPoints(Constants.PORTCenter)
	Constants.PORTREVBarPoints = getREVBarPoints(Constants.PORTCenter)
	
	Constants.STBDCenter = { 
		x = Constants.ScreenWidth - Constants.PodInfoRadius*1.1, 
		y = Constants.ScreenHeight / 2
	}
	Constants.STBDDegreePoints = getDegreePoints(Constants.STBDCenter)
	Constants.STBDFWDBarPoints = getFWDBarPoints(Constants.STBDCenter)
	Constants.STBDREVBarPoints = getREVBarPoints(Constants.STBDCenter)
end

function getFWDBarPoints(centerPoint)
	return {
		{
			x = centerPoint.x - Constants.PodInfoRadius*0.15, 
			y = centerPoint.y - Constants.BarHeight*0.9
		},
		{
			x = centerPoint.x, 
			y = centerPoint.y - Constants.BarHeight
		},
		{
			x = centerPoint.x + Constants.PodInfoRadius*0.15, 
			y = centerPoint.y - Constants.BarHeight*0.9
		},
		{
			x = centerPoint.x + Constants.PodInfoRadius*0.15, 
			y = centerPoint.y
		},
		{
			x = centerPoint.x - Constants.PodInfoRadius*0.15, 
			y = centerPoint.y
		}
	}
end

function getREVBarPoints(centerPoint)
	return rotatePoints(getFWDBarPoints(centerPoint), centerPoint, 180)
end

function getDegreePoints(centerPoint)
	local firstInner = { x = centerPoint.x + Constants.PodInfoRadius, y = centerPoint.y}
	local firstOuter = { x = centerPoint.x + Constants.PodInfoRadius*1.05, y = centerPoint.y}
	local degreePoints = {}
	for i = 0, 360, 30 do
		degreePoints[i/30] = rotatePoints({firstInner, firstOuter}, centerPoint, i)
	end
	return degreePoints
end

----------------------- Drawing ---------------------------------------------------------------
	
function drawPORTPodInfo(rotationInDegrees, throttle)
	
	setColorRGB(Constants.Colors.debugWhite)
	screen.drawCircle(Constants.PORTCenter.x, Constants.PORTCenter.y, Constants.PodInfoRadius)
	
	drawDegreeMarkings(Constants.PORTDegreePoints)
	
	drawPolygonF(rotatePoints(Constants.PORTFWDBarPoints, Constants.PORTCenter, rotationInDegrees), Constants.Colors.debugGreen)
	drawPolygonF(rotatePoints(Constants.PORTREVBarPoints, Constants.PORTCenter, rotationInDegrees), Constants.Colors.debugRed)
	
	
end

function drawSTBDPodInfo(rotationInDegrees, throttle)
	
	setColorRGB(Constants.Colors.debugWhite)
	screen.drawCircle(Constants.STBDCenter.x, Constants.STBDCenter.y, Constants.PodInfoRadius)
	
	drawDegreeMarkings(Constants.STBDDegreePoints)
	
	drawPolygonF(rotatePoints(Constants.STBDFWDBarPoints, Constants.STBDCenter, rotationInDegrees), Constants.Colors.debugGreen)
	drawPolygonF(rotatePoints(Constants.STBDREVBarPoints, Constants.STBDCenter, rotationInDegrees), Constants.Colors.debugRed)
end

function drawDegreeMarkings(pointPairs)
	for i, pointPair in ipairs(pointPairs) do
		drawLineBetween(pointPair[1], pointPair[2], Constants.Colors.debugWhite)
	end
end

----------------------- Utils ---------------------------------------------------------------

function setColorRGB(rgbArray)
	screen.setColor(rgbArray[1], rgbArray[2], rgbArray[3])
end
	
function drawLineBetween(_start, _end, color)
	setColorRGB(color)
	screen.drawLine(_start.x, _start.y, _end.x, _end.y)
end

function drawPolygon(pointArray, color)
	for i = 1, #pointArray do
	    local first = pointArray[i]
	    local second = pointArray[i % #pointArray + 1]
	    drawLineBetween(first, second, color)
	end
end

function drawPolygonF(pointArray, color)
	-- divide the polygon into triangles
	setColorRGB(color)
	for i = 2, #pointArray - 1 do
	    screen.drawTriangleF(pointArray[1].x, pointArray[1].y, pointArray[i].x, pointArray[i].y, pointArray[i+1].x, pointArray[i+1].y)
	end	
end

function rotatePoint(point, pivot, angleInDegrees)
	local angleInRadians = angleInDegrees * math.pi / 180
	local s = math.sin(angleInRadians);
	local c = math.cos(angleInRadians);
	local rotated = {}
	rotated.x = ((point.x - pivot.x) * c - (point.y - pivot.y) * s) + pivot.x;
	rotated.y = ((point.x - pivot.x) * s + (point.y - pivot.y) * c) + pivot.y;
	return rotated
end

function rotatePoints(pointArray, pivot, angleInDegrees)
	local rotatedPointArray = {}
	for i, v in ipairs(pointArray) do
	    rotatedPointArray[i] = rotatePoint(v, pivot, angleInDegrees)
	end
	return rotatedPointArray
end

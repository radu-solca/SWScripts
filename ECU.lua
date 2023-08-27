function map(value, min1, max1, min2, max2)
    return min2 + (value - min1) * (max2 - min2) / (max1 - min1)
end

function clamp(value, min, max)
    return math.max(min, math.min(value, max))
end

function PIDController(kP,kI,kD)
	local PID = {}
	PID.kP = kP or 0
	PID.kI = kI or 0
	PID.kD = kD or 0
	
	PID.prevError = 0
	PID.prevIntegral = 0
	
	function PID:run(setpoint, processVariable)
		local error = setpoint - processVariable
		local integral = self.prevIntegral + error
		local derivative = error - self.prevError
		
		self.prevError = error
		self.prevIntegral = integral
		
		return self.kP*error + self.kI*integral + self.kD*derivative
	end
	
    return PID
end

function AirFuelController(
	idleRPS, maxRPS,
	rpsKP,rpsKI,rpsKD,
	afrKP,afrKI,afrKD)

	local CTRL = {}
	local idleRPS, maxRPS = idleRPS, maxRPS
	local rpsPID = PIDController(
		rpsKP,
		rpsKI,
		rpsKD
	)
	local afrPID = PIDController(
		afrKP,
		afrKI,
		afrKD
	)

	local function getManifoldThrottle(throttle, currentRPS)

		local targetRPS = map(throttle, 0, 1, idleRPS, maxRPS)
		local throttle = rpsPID:run(targetRPS, currentRPS)
		
		return clamp(throttle, 0, 1)
	end
	
	local previousAirFuelBias = 0
	local function getAirFuelBias(airVolume, fuelVolume, temp)
	
		local targetAFR = 13.6 + clamp(temp*0.004,0,0.4)
		local currentAFR = (airVolume*1000 + 0.0000001)/(fuelVolume*1000 + 0.0000001)
	
		local newAirFuelBias = clamp(
			previousAirFuelBias + afrPID:run(targetAFR, currentAFR), 
			-1, 1
		)
	
		previousAirFuelBias = newAirFuelBias
		return newAirFuelBias
	end
		
	function CTRL:run(throttle, currentRPS, airVolume, fuelVolume, temp)
		local manifoldThrottle = getManifoldThrottle(throttle, currentRPS)
		local airFuelBias = getAirFuelBias(airVolume, fuelVolume, temp)

		local airThrottle = manifoldThrottle * clamp(1+airFuelBias, 0.1, 1)
		local fuelThrottle = manifoldThrottle * clamp(1-airFuelBias, 0.1, 1)

		return airThrottle, fuelThrottle
	end

    return CTRL
end

local constants = {
	rpsKP = property.getNumber("rps p"),
	rpsKI = property.getNumber("rps i"),
	rpsKD = property.getNumber("rps d"),

	afrKP = property.getNumber("afr p"),
	afrKI = property.getNumber("afr i"),
	afrKD = property.getNumber("afr d"),

	idleRPS = property.getNumber("idle rps"),
	maxRPS = property.getNumber("max rps"),

	targetTemp = property.getNumber("target temperature"),
	shutdownTemp = property.getNumber("shutdown temperature")
}

local airFuelController = AirFuelController(
	constants.idleRPS, constants.maxRPS,
	constants.rpsKP, constants.rpsKI, constants.rpsKD,
	constants.afrKP, constants.afrKI, constants.afrKD
)

function onTick()
	
	local inputs = {
		engineOn = input.getBool(1),
		currentRPS = input.getNumber(1),
		throttle = clamp(input.getNumber(2), 0, 1),
		airVolume = input.getNumber(3),
		fuelVolume = input.getNumber(4),
		temp = input.getNumber(5)
	}

	local airThrottle, fuelThrottle = airFuelController:run(
		inputs.throttle, 
		inputs.currentRPS,
		inputs.airVolume, 
		inputs.fuelVolume, 
		inputs.temp
	)

	local shouldEngineRun = inputs.engineOn and inputs.temp < constants.shutdownTemp

	airThrottle, fuelThrottle = shouldEngineRun 
	and airThrottle, fuelThrottle
	or 0, 0
		
	local starterOn = shouldEngineRun and (inputs.currentRPS < 3)

	local coolingOn = inputs.temp > constants.targetTemp
	
	output.setBool(1, starterOn)
	output.setBool(2, coolingOn)
	output.setNumber(1, airThrottle)
	output.setNumber(2, fuelThrottle)	
end
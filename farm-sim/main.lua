windSimulatorUsb = require 'windSimulatorUsb'

--source is used for telling the giants engine to import these files, it is sort of equivalent to when you would use the lua function "require"
local directory = g_currentModDirectory
local modName = g_currentModName

WindSimulator = {}

--Fetch some variables from the moddesc file, to be used when writing out load statements
local modDesc = loadXMLFile("modDesc", g_currentModDirectory .. "modDesc.xml")
WindSimulator.version = getXMLString(modDesc, "modDesc.version")
WindSimulator.modName = modName
WindSimulator.author = getXMLString(modDesc, "modDesc.author")
WindSimulator.title = getXMLString(modDesc, "modDesc.title.en")

--Behavior-related state.
WindSimulator.vehicle = nil

--Set the modname to use when outputting to the log through FS_Debug
FS_Debug.mod_name = WindSimulator.title
--Set the max log level for FS_Debug. Error = 0, Warning = 1, Info = 2, Debug = 3 and so on for even more debug info.
FS_Debug.log_level_max = 3

--#######################################################################################
--### New in FS19. Used to register all of the event listeners. In FS17 you just had to 
--### have the functions present. But now you need to register the ones you need aswell
--### And it looks like this function is run upon each vehicletype getting loaded.
--#######################################################################################
function WindSimulator.registerEventListeners(vehicleType)
	FS_Debug.info("registerEventListeners")
	--Table holding all the events, makes it a bit easier to read the code
	local events = { "onLoad", 
					  "onUpdate", 
					  "onEnterVehicle", 
					  "onLeaveVehicle", }
	--Register the events we want our spec to react to. Make sure that you have functions with the same name
	--defined as the this list
	for _,event in pairs(events) do
		SpecializationUtil.registerEventListener(vehicleType, event, WindSimulator)
	end
end

function WindSimulator.prerequisitesPresent(specializations)
  return true
end

--#######################################################################################
--### Runs when a vehicle with the specialization is loaded. Usefull if you want to
--### fx. expose something that other mods should be able to use in their own onPostLoad
--#######################################################################################
function WindSimulator:onLoad(savegame)
	FS_Debug.info("onload" .. FS_Debug.getIdentity(self))
end

--#######################################################################################
--### This runs on each frame of the game. So if your framerate is a 100 fps, then this
--### runs a 100 times per second. The dt argument supplies the the frametime since the
--### last frame. So use this to make your code not be framerate dependent.
--#######################################################################################
function WindSimulator:onUpdate(dt, isActiveForInput, isSelected)
  if WindSimulator.vehicle == nil then
    return
  end
  --Update wind speed.
  FS_Debug.info("vehicleSpeed" .. WindSimulator.vehicle:getLastSpeed())
	windSimulatorUsb.transmitSpeed(WindSimulator.vehicle:getLastSpeed())
end

--#######################################################################################
--### This is run when someone enters the vehicle.
--#######################################################################################
function WindSimulator:onEnterVehicle()
	FS_Debug.info("onEnterVehicle" .. FS_Debug.getIdentity(self))
  WindSimulator.vehicle = self
end

function WindSimulator:onLeaveVehicle()
	FS_Debug.info("onLeaveVehicle" .. FS_Debug.getIdentity(self))
  WindSimulator.vehicle = nil
end

--#######################################################################################
--### If anything special has to happen after the register of the mod, then this function 
--### runs when the map is loading. For example if we wanted to check how many vehicles
--### the specialization was attached to.
--#######################################################################################
function WindSimulator:loadMap(name)
	print("Loaded " .. self.title .. " version " .. self.version .. " made by " .. self.author);
end;

--#######################################################################################
--### Runs when the map is deleted. Which only happens when exiting to the menu. If using 
--### alt+f4 to quit the game or anything similar. Then this will not run.
--#######################################################################################
function WindSimulator:deleteMap()
	print("Unloaded " .. self.title .. " version " .. self.version .. " made by " .. self.author);
end;

--#######################################################################################
--### This is responsible for checking if the
--### WindSimulator class was included properly and is accessible. And then it goes
--### through the registered vehicletypes and checks if they meet certain criteria like
--### being drivable, before adding the WindSimulator specialization.
--#######################################################################################

function validateVehicleTypes(vehicleTypeManager)
	FS_Debug.info("Running spec function: " .. modName .. " : " .. directory)
	g_specializationManager:addSpecialization("windSimulator", "WindSimulator", Utils.getFilename("main.lua", directory), nil)
	for typeName, typeDef in pairs(g_vehicleTypeManager:getVehicleTypes()) do
		if typeDef ~= nil then
			if SpecializationUtil.hasSpecialization(Drivable, typeDef.specializations) and 
				SpecializationUtil.hasSpecialization(Motorized, typeDef.specializations) and
				SpecializationUtil.hasSpecialization(Enterable, typeDef.specializations) then
					FS_Debug.info("Attached specialization '" .. modName .. ".windSimulator" .. "' to vehicleType '" .. tostring(typeName) .. "'")
					g_vehicleTypeManager:addSpecialization(typeName, modName .. ".windSimulator")
			end
		end
	end
end

VehicleTypeManager.validateVehicleTypes = Utils.prependedFunction(VehicleTypeManager.validateVehicleTypes, validateVehicleTypes)

--#######################################################################################
--### Adds eventlisteners for any specified events. We don't really have any for the 
--### register script apart from the map load stuff. Which just outputs a little message
--### to the console/log
--#######################################################################################
addModEventListener(WindSimulator);
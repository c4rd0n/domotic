-- ingests tables: otherdevices,otherdevices_svalues
-- 
-- otherdevices and otherdevices_svalues are two item array for all devices: 
--   otherdevices['yourotherdevicename']="On"
--	otherdevices_svalues['yourotherthermometer'] = string of svalues
--
-- Based on your logic, fill the commandArray with device commands. Device name is case sensitive. 
--
-- Always, and I repeat ALWAYS start by checking for a state.
-- If you would only specify commandArray['AnotherDevice']='On', every time trigger (e.g. every minute) will switch AnotherDevice on.
--
-- The print command will output lua print statements to the domoticz log for debugging.
-- List all otherdevices states for debugging: 
--   for i, v in pairs(otherdevices) do print("index : "..i.."; valeur : ".. v) end
-- List all otherdevices svalues for debugging: 
--   for i, v in pairs(otherdevices_svalues) do print("index : "..i.."; valeur : ".. v) end

local function getValeur(nom)
	local handle = io.popen("vclient -h localhost:3002 -c "..nom.."  | sed -n '2p' | cut -d ' ' -f 1")
	local num = handle:read("*a")
	handle:close()
	return (num:gsub("%s+", ""))
end -- end getValeur

local function getNumber(nom)
	local handle = io.popen("vclient -h localhost:3002 -c "..nom.." | cut -d ' ' -f 1 | grep -E ^[0-9]+\\.?[0-9]*$")
	local num = handle:read("*a")
	handle:close()
	return (num:gsub("%s+", ""))
end -- end getNumber

local function getDeviceValue(value)
	if (type(value)=="table") then
		if (value.param ~= nil and value.param ~= "") then
			return value.fonction(value.param)
		else
			return value.fonction()
		end -- end if
	else
		return value
	end -- end if
end -- end getDeviceValue

local minutes = tonumber(os.time()/60)
local nbrMAJ = 4
local devices = {
	{
		["deviceId"] = 7,
		["nvalue"] = 0,
		["svalue"] = {
			["fonction"] = getNumber,
			["param"] = "getTempExt"
		}
	},
        {
                ["deviceId"] = 8,
                ["nvalue"] = 0,
                ["svalue"] = {
                        ["fonction"] = getNumber,
                        ["param"] = "getTempIntCC2"
                }
        },
        {
                ["deviceId"] = 21,
                ["nvalue"] = 0,
                ["svalue"] = {
                        ["fonction"] = getNumber,
                        ["param"] = "getTempDepCC2"
                }
        },
        {
                ["deviceId"] = 18,
                ["nvalue"] = {
                        ["fonction"] = getNumber,
                        ["param"] = "getStatutPompeECS"
                },
                ["svalue"] = 0
        },
	{
                ["deviceId"] = 19,
                ["nvalue"] = {
                        ["fonction"] = getNumber,
                        ["param"] = "getEcoModeCC2"
                },
                ["svalue"] = 0
        },
	{
		["deviceId"] = 20,
                ["nvalue"] = {
                        ["fonction"] = getNumber,
                        ["param"] = "getRecModeCC2"
                },
                ["svalue"] = 0
        },
        {
                ["deviceId"] = 22,
                ["nvalue"] = {
                        ["fonction"] = getValeur,
                        ["param"] = "getStatutPompeECS"
                },
                ["svalue"] = 0
        },
        {
                ["deviceId"] = 23,
                ["nvalue"] = 0,
                ["svalue"] = {
                        ["fonction"] = getValeur,
                        ["param"] = "getTempFume"
                }
        },
        {
                ["deviceId"] = 24,
                ["nvalue"] = 0,
                ["svalue"] = {
                        ["fonction"] = getValeur,
                        ["param"] = "getTempECS"
                }
        },
        {
                ["deviceId"] = 25,
                ["nvalue"] = 0,
                ["svalue"] = {
                        ["fonction"] = getValeur,
                        ["param"] = "getTempChaudiere"
                }
        },
        {
                ["deviceId"] = 26,
		["name"] = "Chauffage - Pompe de circulation",
                ["nvalue"] = {
                        ["fonction"] = function() return getValeur("getPompeStatutCC2") end
                },
		["svalue"] = 0
        },
        {
                ["deviceId"] = 27,
                ["name"] = "Chaudière - Eau Chaude Sanitaire",
                ["value"] = {
                        ["fonction"] = function ()
			        local mode = tonumber(getValeur("getModeCC2"))
			        if mode == 1 or mode == 2 then
			                return "On"
			        else
			                return "Off"
			        end -- end if
			end -- end getECSStatut
                }
        },
        {
                ["deviceId"] = 28,
		["name"] = "Chaudière - Chauffage",
                ["value"] = {
                        ["fonction"] = function()
				local mode = tonumber(getValeur("getModeCC2"))
			        if mode > 1 then
			                return "On"
			        else
			                return "Off"
			        end -- end if
			end -- end function
                }
        }
}

commandArray = {}

local nbrDevices = #devices
local nbrLots = math.ceil(nbrDevices / nbrMAJ)
local i_min = ( minutes % nbrLots ) * nbrMAJ + 1
local i_max = i_min + nbrMAJ - 1

-- i_min = 10
-- i_max = 13

for i, device in pairs(devices) do
	if(i >= i_min and i <= i_max) then
		if (device.deviceId~=nil and device.nvalue~=nil and device.svalue~=nil) then
			print("Mise à jour du device "..device.deviceId)
			commandArray[i]={["UpdateDevice"] = device.deviceId.."|"..getDeviceValue(device.nvalue).."|"..getDeviceValue(device.svalue)}
		elseif (device.name~=nil and device.value~=nil) then
                        print("Mise à jour du device "..device.name)
			local value = getDeviceValue(device.value)
			if (otherdevices[device.name]~=value) then -- On ne met à jour le device que si nécessaire
				-- print("DEBUG - commandArray["..device.name.."] = "..value)
				commandArray[device.name] = value
			end -- end if
		end -- end if
	end -- end if
end -- end for

return commandArray

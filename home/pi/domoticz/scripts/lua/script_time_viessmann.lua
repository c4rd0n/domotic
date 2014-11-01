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
--   for i, v in pairs(otherdevices) do print(i, v) end
-- List all otherdevices svalues for debugging: 
--   for i, v in pairs(otherdevices_svalues) do print(i, v) end

print("Mise à jour des devices de la chaudière")

local function getValeur(nom)
	local handle = io.popen("vclient -h localhost:3002 -c "..nom.."  | sed -n '2p' | cut -d ' ' -f 1")
	local num = handle:read("*a")
	handle:close()
	return num:gsub("%s+", "")
end -- end getValeur

local function getNumber(nom)
	local handle = io.popen("vclient -h localhost:3002 -c "..nom.." | cut -d ' ' -f 1 | grep -E ^[0-9]+\\.?[0-9]*$")
	local num = handle:read("*a")
	handle:close()
	return num:gsub("%s+", "")
end -- end getNumber

local function getDeviceValue(value)
	if (type(value)=="table") then
		return value.fonction(value.param)
	else
		return value
	end
end

local t1 = os.time()
local minutes = tonumber(t1/60)
local nbrMAJ = 3
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
        }
}

commandArray = {}

local nbrDevices = #devices
local nbrLots = math.ceil(nbrDevices / nbrMAJ)
local i_min = ( minutes % nbrLots ) * nbrMAJ + 1
local i_max = i_min + nbrMAJ - 1

for i, device in pairs(devices) do
	if(i >= i_min and i <= i_max) then
		commandArray[i]={["UpdateDevice"] = device.deviceId.."|"..getDeviceValue(device.nvalue).."|"..getDeviceValue(device.svalue)}
	end -- end if
end -- end for

return commandArray

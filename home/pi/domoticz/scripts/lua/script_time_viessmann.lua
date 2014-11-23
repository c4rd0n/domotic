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

-- getValeur va chercher la valeur retournée par la commande "nom"
local function getValeur(nom)
	local handle = io.popen("vclient -h localhost:3002 -c "..nom.."  | sed -n '2p' | cut -d ' ' -f 1")
	local num = handle:read("*a")
	handle:close()
	return (num:gsub("%s+", ""))
end -- end getValeur

-- Obsolète : getNumber fait comme getValeur.
local function getNumber(nom)
	local handle = io.popen("vclient -h localhost:3002 -c "..nom.." | cut -d ' ' -f 1 | grep -E ^[0-9]+\\.?[0-9]*$")
	local num = handle:read("*a")
	handle:close()
	return (num:gsub("%s+", ""))
end -- end getNumber

-- retourne la valeur du device passée en paramètre
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

-- Calcule le taux d'activation d'un brûleur
local function getTauxBruleur(param)
	local commandeVControl = param[1] -- commande d'interrogation de la chaudière
	local UVnbrHeure = param[2] -- Nom de la variable utilisateur contenant le dernier relevé du nombre d'heure d'activité du brûleur
	local UVnbrHeureLastCheck = param[3] -- Nom de la variable utilisateur contenant le date du dernier relevé
	local newHeure = tonumber(getValeur(commandeVControl))
	local oldHeure = tonumber(uservariables[UVnbrHeure])
        local updateTime = tonumber(uservariables[UVnbrHeureLastCheck])
        local currentTime = os.time()
        -- print("DEBUG - oldHeure : "..oldHeure.." -> newHeure : "..newHeure)
        -- print("DEBUG - lastUpdate : "..updateTime.." -> currentTime : "..currentTime)
        commandArray["Variable:"..UVnbrHeureLastCheck] = tostring(currentTime)
        if newHeure ~= oldHeure then
	        -- Le brûleur a été actif depuis la dernière mise à jour
                local tempsOn = (newHeure - oldHeure) * 3600
                local diffTime = (os.difftime(currentTime,updateTime))
                commandArray["Variable:"..UVnbrHeure]= tostring(newHeure)
                local pourcentage = (tempsOn*100/diffTime)
                -- plafonnement du pourcentage pour éviter des valeurs hors norme
                if pourcentage > 100 then
        	        print ("Pourcentage calculé erroné : "..pourcentage)
                        pourcentage = 100
                elseif pourcentage < 0 then
                        print ("Pourcentage calculé erroné : "..pourcentage)
                        pourcentage = 0
                end -- end if
                return pourcentage
	else
                return 0
        end -- end if
end -- end getTauxBruleur

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
		["name"] = "Chauffage - Mode économique",
                ["value"] = {
                        ["fonction"] = function ()
                                local mode = tonumber(getValeur("getEcoModeCC2"))
                                if mode == 1 or mode == 2 then
                                        return "On"
                                else
                                        return "Off"
                                end -- end if
                        end -- end getECSStatut
		}
        },
	{
		["deviceId"] = 20,
                ["name"] = "Chauffage - Mode réception",
                ["value"] = {
                        ["fonction"] = function ()
                                local mode = tonumber(getValeur("getRecModeCC2"))
                                if mode == 1 or mode == 2 then
                                        return "On"
                                else
                                        return "Off"
                                end -- end if
                        end -- end getECSStatut
                }
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
                ["svalue"] = 0,
                ["nvalue"] = {
                        ["fonction"] = function ()
			        local mode = tonumber(getValeur("getModeCC2"))
			        if mode == 1 or mode == 2 then
			                return 1
			        else
			                return 0
			        end -- end if
			end -- end getECSStatut
                }
        },
        {
                ["deviceId"] = 28,
		["name"] = "Chaudière - Chauffage",
                ["svalue"] = 0,
                ["nvalue"] = {
                        ["fonction"] = function()
				local mode = tonumber(getValeur("getModeCC2"))
			        if mode > 1 then
			                return 1
			        else
			                return 0
			        end -- end if
			end -- end function
                }
        },
        {
                ["deviceId"] = 29,
                ["name"] = "Chaudière - Brûleur 1",
		["nvalue"] = 0,
                ["svalue"] = {
                        ["fonction"] = getTauxBruleur,
			["param"] = {"getBruleur1Heure","Chaudiere - NbrHeureBruleur1","Chaudiere - NbrHeureBruleur1LastCheck"}
                }
        },
        {
                ["deviceId"] = 30,
                ["name"] = "Chaudière - Brûleur 2",
                ["nvalue"] = 0,
                ["svalue"] = {
                        ["fonction"] = getTauxBruleur,
                        ["param"] = {"getBruleur2Heure","Chaudiere - NbrHeureBruleur2","Chaudiere - NbrHeureBruleur2LastCheck"}
                }
        }
}

commandArray = {}

local nbrDevices = #devices
local nbrLots = math.ceil(nbrDevices / nbrMAJ)
local i_min = ( minutes % nbrLots ) * nbrMAJ + 1
local i_max = i_min + nbrMAJ - 1

-- Pour imposer la mise à jour d'un device précis :
-- i_min = 12
-- i_max = 13

for i, device in pairs(devices) do
	if(i >= i_min and i <= i_max) then
		if (device.deviceId~=nil and device.nvalue~=nil and device.svalue~=nil) then
			-- print("Mise à jour du device "..device.deviceId)
			-- print ("DEBUG - commandArray[i]={[\"UpdateDevice\"] = "..device.deviceId.."|"..getDeviceValue(device.nvalue).."|"..getDeviceValue(device.svalue).."}")
			commandArray[i]={["UpdateDevice"] = device.deviceId.."|"..getDeviceValue(device.nvalue).."|"..getDeviceValue(device.svalue)}
		elseif (device.name~=nil and device.value~=nil) then
                        -- print("Mise à jour du device "..device.name)
			local value = getDeviceValue(device.value)
			if (otherdevices[device.name]~=value) then -- On ne met à jour le device que si nécessaire
				-- print("DEBUG - commandArray["..device.name.."] = "..value)
				commandArray[device.name] = value
				
			end -- end if
		end -- end if
	end -- end if
end -- end for

return commandArray

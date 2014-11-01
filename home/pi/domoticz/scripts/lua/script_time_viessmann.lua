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

print('Mise à jour des devices de la chaudière')

local function getValeur(nom)
	local fichierTMP = '/var/tmp/'..os.time()
	os.execute = ('echo "\\$1" > '..fichierTMP)
	local handle = io.popen('vclient -h localhost:3002 -t '..fichierTMP..' -c '..nom)
	local num = handle:read("*a")
	handle:close()
	return num
end -- end getValeur

local function getNumber(nom)
	local handle = io.popen('vclient -h localhost:3002 -c '..nom..' | cut -d " " -f 1 | grep -E ^[0-9]+\\.?[0-9]*$')
	local num = handle:read("*a")
	handle:close()
	return num
end -- end getNumber

local t1 = os.time()
local minutes = t1/60
commandArray = {}

if (tonumber(minutes)%2 == 0) then -- On met à jour les données toutes les cinq minutes
	commandArray[1]={['UpdateDevice'] = '7|0|'..getNumber('getTempExt')}
	commandArray[2]={['UpdateDevice'] = '8|0|'..getNumber('getTempIntCC2')}
	commandArray[3]={['UpdateDevice'] = '21|0|'..getNumber('getTempDepCC2')}
elseif ((tonumber(minutes)+1)%2 == 0) then
	commandArray[1]={['UpdateDevice'] = '18|'..getNumber('getStatutPompeECS')..'|0'}
	commandArray[2]={['UpdateDevice'] = '19|'..getNumber('getEcoModeCC2')..'|0'}
	commandArray[3]={['UpdateDevice'] = '20|0|'..getNumber('getRecModeCC2')}
end 

return commandArray

-- demo device script
-- script names have three name components: script_trigger_name.lua
-- trigger can be 'time' or 'device', name can be any string
-- domoticz will execute all time and device triggers when the relevant trigger occurs
-- 
-- copy this script and change the "name" part, all scripts named "demo" are ignored. 
--
-- Make sure the encoding is UTF8 of the file
--
-- ingests tables: devicechanged, otherdevices,otherdevices_svalues
--
-- device changed contains state and svalues for the device that changed.
--   devicechanged['yourdevicename']=state 
--   devicechanged['svalues']=svalues string 
--
-- otherdevices and otherdevices_svalues are arrays for all devices: 
--   otherdevices['yourotherdevicename']="On"
--	otherdevices_svalues['yourotherthermometer'] = string of svalues
--
-- Based on your logic, fill the commandArray with device commands. Device name is case sensitive. 
--
-- Always, and I repeat ALWAYS start by checking for the state of the changed device.
-- If you would only specify commandArray['AnotherDevice']='On', every device trigger will switch AnotherDevice on, which will trigger a device event, which will switch AnotherDevice on, etc. 
--
-- The print command will output lua print statements to the domoticz log for debugging.
-- List all otherdevices states for debugging: 
--   for i, v in pairs(otherdevices) do print(i, v) end
-- List all otherdevices svalues for debugging: 
--   for i, v in pairs(otherdevices_svalues) do print(i, v) end
--
-- TBD: nice time example, for instance get temp from svalue string, if time is past 22.00 and before 00:00 and temp is bloody hot turn on fan. 

commandArray = {}

-- Mode Réception
if (devicechanged['Chauffage - Mode réception'] == 'On') then
        os.execute("vclient -h localhost:3002 -c \"setRecModeCC2 1\"")
elseif (devicechanged['Chauffage - Mode réception'] == 'Off') then
        os.execute("vclient -h localhost:3002 -c \"setRecModeCC2 0\"")
end

-- Mode Economique
if (devicechanged['Chauffage - Mode économique'] == 'On') then
	os.execute("vclient -h localhost:3002 -c \"setEcoModeCC2 1\"")
elseif (devicechanged['Chauffage - Mode économique'] == 'Off') then
        os.execute("vclient -h localhost:3002 -c \"setEcoModeCC2 0\"")
end

-- Mode chauffage
if (devicechanged['Chaudière - Chauffage'] == 'On') then
        os.execute("vclient -h localhost:3002 -c \"setModeCC2 2\"")
elseif (devicechanged['Chaudière - Chauffage'] == 'Off') then
	if(otherdevices['Chaudière - Eau Chaude Sanitaire'] == 'On') then
		os.execute("vclient -h localhost:3002 -c \"setModeCC2 1\"")
	else
		os.execute("vclient -h localhost:3002 -c \"setModeCC2 0\"")
	end -- end if
end

-- Mode ECS
if (devicechanged['Chaudière - Eau Chaude Sanitaire'] == 'On') then
	if(otherdevices['Chaudière - Chauffage'] == 'On') then
	        os.execute("vclient -h localhost:3002 -c \"setModeCC2 2\"")
	else
                os.execute("vclient -h localhost:3002 -c \"setModeCC2 1\"")
 	end
elseif (devicechanged['Chaudière - Eau Chaude Sanitaire'] == 'Off') then
        os.execute("vclient -h localhost:3002 -c \"setModeCC2 0\"")
end

return commandArray

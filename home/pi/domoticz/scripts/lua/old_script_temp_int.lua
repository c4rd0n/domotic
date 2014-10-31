-- demo time script
-- script names have three name components: script_trigger_name.lua
-- trigger can be 'time' or 'device', name can be any string
-- domoticz will execute all time and device triggers when the relevant trigger occurs
--
-- copy this script and change the "name" part, all scripts named "demo" are ignored.
--
-- Make sure the encoding is UTF8 of the file
--
-- ingests tables: otherdevices,otherdevices_svalues
--
-- otherdevices and otherdevices_svalues are two item array for all devices:
-- otherdevices['yourotherdevicename']="On" -- otherdevices_svalues['yourotherthermometer'] = string of svalues
--
-- Based on your logic, fill the commandArray with device commands. Device name is case sensitive.
--
-- Always, and I repeat ALWAYS start by checking for a state.
-- If you would only specify commandArray['AnotherDevice']='On', every time trigger (e.g. every minute) will switch AnotherDevice on.
--
-- The print command will output lua print statements to the domoticz log for debugging.
-- List all otherdevices states for debugging:
-- for i, v in pairs(otherdevices) do print(i, v) end
-- List all otherdevices svalues for debugging:
-- for i, v in pairs(otherdevices_svalues) do print(i, v) end

print('Exécution du script script_time_temp_interieure.lua')

temp = tonumber(otherdevices_svalues['CPU Raspberry'])

commandArray = {}

-- commandArray[1]={['UpdateDevice'] = '8|0|'..(temp - 34.2 + 19.8)}
-- commandArray[2]={['UpdateDevice'] = '7|0|'..(temp - 34.2 + 14)}

return commandArray

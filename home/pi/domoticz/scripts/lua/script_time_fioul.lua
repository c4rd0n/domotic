-- ~/domoticz/scripts/lua/script_device_fuel.lua
-- Script assumes that the boiler switch will never turn on when it is on or turn off then it is off
--    i.e. an off always follows an on
-- for i, v in pairs(otherdevices_svalues) do print("index : "..i.."; valeur : ".. v) end
-- for i, v in pairs(otherdevices_lastupdate) do print("index : "..i.."; valeur : ".. v) end

burner1 = "Chaudière - Brûleur 1"
burner2 = "Chaudière - Brûleur 2"
-- Work out fuel used over some period and input here to per second
fuelpersecond = 5.67 / 3600.0
-- Provide name and id of virtual RFXmeter counter to display total fuel usage
fueldisplay = "Chaudière - Consommation Fioul"
fueldisplayid = 256

function timedifference(s)
   year = string.sub(s, 1, 4)
   month = string.sub(s, 6, 7)
   day = string.sub(s, 9, 10)
   hour = string.sub(s, 12, 13)
   minutes = string.sub(s, 15, 16)
   seconds = string.sub(s, 18, 19)
   t1 = os.time()
   t2 = os.time{year=year, month=month, day=day, hour=hour, min=minutes, sec=seconds}
   difference = os.difftime (t1, t2)
   return difference
end

function fuelUsed(burnerName,fuelpersecond)
    -- Calculate time since boiler was switch on
   difference = timedifference(otherdevices_lastupdate[burnerName])
    -- Calculate amount of fuel used in this boiler burn
   return (fuelpersecond * difference * tonumber(string.match(otherdevices_svalues[fueldisplay], "%d+%.*%d*")) / 100)
end

commandArray = {}

-- Retrieve previous total fuel used from meter
fueltotal = tonumber(string.match(otherdevices_svalues[fueldisplay], "%d+%.*%d*"))
-- Add previous amount of fuel used to this burn amount
fueltotal = fueltotal + fuelUsed(burner1,fuelpersecond) + fuelUsed(burner2,fuelpersecond)
-- Return new cumulative burn amount to meter
commandArray['UpdateDevice'] = fueldisplayid .. "|0|" .. fueltotal

return commandArray

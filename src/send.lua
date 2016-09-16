local args = {...}
local modem = peripheral.wrap("left")
local x, y, z = gps.locate()
--print(x)
--print(y)
--print(z)
--print(args[1])
local geepus = {x, y, z, args[1]}
modem.transmit(8,1,textutils.serialize(geepus))


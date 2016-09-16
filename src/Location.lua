--location API for holding variables and
--constants for turtle gps location and tracking

--constants
NORTH = 1
SOUTH = 2
EAST = 3
WEST = 4
UP = 5
DOWN = 6
LEFT = 7
RIGHT = 8
UTURN = 9

--global variable for holding the current location/facing
currentLocation = {x = 0, y = 0, z = 0, f = 0}

--sends the current location over wireless
function send(channel)
  --shell.run("logDebug", "Location.send()")
  local modem = peripheral.wrap("left")--this requires all wireless modem to be on the left
  local msg = textutils.serialize(currentLocation)
  modem.transmit(8, 1, msg)
end

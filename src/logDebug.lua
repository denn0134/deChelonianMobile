local args = {...}
--print(args[1])
local logFile = fs.open("Debug.log", "a")
local logMsg = os.day()..":"..os.time().." - "..args[1]
--print(logMsg)
logFile.writeLine(logMsg)
logFile.close()

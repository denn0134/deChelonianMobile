--this program will attempt to determine
--the facing (north, south, east or west)
--of the turtle using movement and GPS readings

--logs a debug message to a file
function debug(msg)
  print(msg)
  shell.run("logDebug", msg)
end--end debug()

--calculates the facing based on the GPS delta,
--axis of movement, and direction of movement
--dx: the delta of the x coordinates - (x1 - x2)
--dz: the delta of the z coordinates - (z1 - z2)
--turn: true if the turtle made a turn prior to movement
--reverse: true if the move was forward; false if back
--post: global facing variable will be set
function calcFacing(dx, dz, turn, reverse)
  --if we are moving backward reverse the deltas
  if reverse then
    dx = dx * -1
    dz = dz * -1
  end--end if reverse
  
  local swap
  if turn  then
    swap = dx
    dx = dz
    dz = swap
  end--end if turn
  
  if dx == 0 then
    --either north or south
    if dz > 0 then
      findFacing_Facing = "north"
    else
      findFacing_Facing = "south"
    end
  else
    --either east or west
    if dx > 0 then
      findFacing_Facing  = "west"
    else
      findFacing_Facing = "east"
    end
  end--end if dx/dz
end--end calcFacing()

--this function will attempt to move the turtle
--forward or back and thereby calculate the
--facing based on the GPS change
--turned: this defines whether the turtle has turned
--        to avoid an obstacle
--Returns true if the move was successful
function attemptMove(turned)
  local x1, x2, y1, y2, z1, z2
  x1, y1, z1 = gps.locate()

  if turtle.forward() then
    --calculate the facing and then move back
    x2, y2, z2 = gps.locate()
    calcFacing(x1 - x2, z1 - z2, turned, false)
    turtle.back()
    return true
  else
    --try backwards instead
    if turtle.back() then
      --calculate the facing and then move back
      x2, y2, z2 = gps.locate()
      calcFacing(x1 - x2, z1 - z2, turned, true)
      turtle.forward()
      return true
    else
      return false
    end--end if back
  end--end if forward
end--end attempMove()

--this function tries all possible movements
--on this level without moving up or down to
--avoid obstacles
--Returns true if the level was successfully searched
function searchLevel()
  local success = false

  --try to move and calc
  if attemptMove(false) then
    --facing was calculated
    success = true
  else
    --try turning left and moving that way
    if turtle.turnRight() and attemptMove(true) then
      success = true
    end--end if turn left and move
    
    --turn back
    turtle.turnLeft()
  end--end if attemptMove
  
  return success
end--searchLevel()

--this function will try to move from one level to another
--startLevel: this is the level the trutle is starting from
--endLevel: this is the level to move the turtle to
--returns true if the turtle was able to move all the way to the target
function tryChangeLevel(startLevel, endLevel)
  local vector = endLevel - startLevel
  local success = true
  if vector > 0 then
    for i = 1, vector do
      if turtle.up() then
        findFacing_Level = findFacing_Level + 1
      else
        success = false
        break
      end--end up
    end--end for i
  else
    vector = math.abs(vector)
    for i = 1, vector do
      if turtle.down() then
        findFacing_Level = findFacing_Level - 1
      else
        success = false
        break
      end--end down
    end--end for i
  end--end if vector
  
  return success
end--end tryChangeLevel()

--this function attempt to move the turtle up and/or
--down to the next level for searching
--the turtle start at a level we will call 0
--the next level it should try would be level 1
--then it should try level -1
--then level 2, -2, 3, -3, etc
--this function may detect a stuck turtle
function nextLevel()
  --first determine the target level to move to
  local target = 0
  local secTarget = 0
  local success = false
  
  if findFacing_Level > 0 then
    --find target
    if findFacing_CanGoDown then
      target = findFacing_Level * -1
    else
      if findFacing_CanGoUp then
        target = findFacing_Level + 1
      else
        target = 0
      end--end UP
    end--end DOWN
    
    --find secondary target
    if findFacing_CanGoUp then
      secTarget = findFacing_Level + 1
    else
      secTarget = 0
    end--end UP
  else
    --find target
    if findFacing_CanGoUp then
      target = findFacing_Level * -1 + 1
    else
      if findFacing_CanGoDown then
        target = findFacing_Level - 1
      else
        target = 0
      end--end DOWN
    end--end UP
    
    --find secondary target
    if findFacing_CanGoDown then
      secTarget = findFacing_Level - 1
    else
      secTarget = 0
    end--end DOWN
  end--end if level > 0
  
  
  local direction = target - findFacing_Level
  if direction == 0 then
    --if the direction is 0 we are stuck
    shell.run("send", "stuck")
    --shell.run("shutdown")
  else
    --try to move to the primary target
    if tryChangeLevel(findFacing_Level, target) then
      success = true
    else
      --mark the direction as not possible
      if direction > 0 then
        findFacing_CanGoUp = false
      else
        findFacing_CanGoDown = false
      end--end mark direction
      
      --try to move to the secondary target
      if tryChangeLevel(findFacing_Level, secTarget) then
        success = true
      else
        -- mark the direction as not possible
        if direction > 0 then
          findFacing_CanGoUp = false
        else
          findFacing_CanGoDown = false
        end--end mark direction
        
        --we are probably stuck - move back to level zero
        tryChangeLevel(findFacing_Level, 0)
      end--end secondary
    end--end primary
  end--end stuck check
end--end nextLevel()


sleep(5)

findFacing_Facing = ""
findFacing_Level = 0
findFacing_CanGoUp = true
findFacing_CanGoDown = true
local haveFacing = false

if searchLevel() == false then
  while haveFacing == false do
    nextLevel()
    haveFacing = searchLevel()
  end--end while
end--end searchLevel

tryChangeLevel(findFacing_Level, 0)

shell.run("send", findFacing_Facing)

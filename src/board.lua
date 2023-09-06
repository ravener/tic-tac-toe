local Object = require('libs.classic')
local lume = require('libs.lume')
local Board = Object:extend()

function Board:new()
  -- 3x3 grid, 0s are empty, 1s are Xs and 2s are Os
  self.grid = {{0, 0, 0}, {0, 0, 0}, {0, 0, 0}}
end

function Board:reset()
  self.grid = {{0, 0, 0}, {0, 0, 0}, {0, 0, 0}}
end

function Board:play(y, x, action)
  if self.grid[y][x] == 0 then
    self.grid[y][x] = action
    return true
  end

  return false
end

function Board:check()
  -- easier typing
  local grid = self.grid

  -- Win by horizontal line in any row
  for y = 1, 3 do
    if grid[y][1] ~= 0 and grid[y][1] == grid[y][2] and grid[y][2] == grid[y][3] then
      return grid[y][1]
    end
  end

  -- Win by vertical line in any column
  for x = 1, 3 do
    if grid[1][x] ~= 0 and grid[1][x] == grid[2][x] and grid[2][x] == grid[3][x] then
      return grid[1][x]
    end
  end

  -- Win by left diagonal cross
  if grid[1][1] ~= 0 and grid[1][1] == grid[2][2] and grid[2][2] == grid[3][3] then
    return grid[1][1]
  end

  -- Win by right diagonal cross
  if grid[1][3] ~= 0 and grid[1][3] == grid[2][2] and grid[2][2] == grid[3][1] then
    return grid[1][3]
  end

  return false
end

-- Check if the board is full, useful for detecting a draw
function Board:full()
  for y = 1, 3 do
    for x = 1, 3 do
      -- If any slot is empty we are not full yet.
      if self.grid[y][x] == 0 then
        return false
      end
    end
  end

  -- No empty slots found, board is full.
  return true
end

-- Play AI's turn. For now it's a random empty slot
function Board:playAI(value)
  local empty = {}
  for y = 1, 3 do
    for x = 1, 3 do
      if self.grid[y][x] == 0 then
        table.insert(empty, {y, x})
      end
    end
  end

  local choice = lume.randomchoice(empty)
  self:play(choice[1], choice[2], value)
end

return Board

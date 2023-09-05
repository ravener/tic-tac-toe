-- Utility functions
local utils = {}
local push = require('libs.push')
local lume = require('libs.lume')

-- Check if the given x/y coordinates overlaps a box of w/h at sx/sy
function utils.overlaps(x, y, sx, sy, w, h)
  return (x >= sx and x <= sx + w) and (y >= sy and y <= sy + h)
end

function utils.renderFPS()
  local x, y = love.window.getSafeArea()
  local count = collectgarbage('count')
  local memory = count > 1024 and lume.round(count / 1024, 2) .. " MB" or math.floor(count) .. " KB"
  love.graphics.print("FPS: " .. love.timer.getFPS() .. '\nMemory: ' .. memory, x, y)
end

function utils.drawHover(x, y, w, h)
  -- Ignore this on Android where a mouse hover is not available.
  if love.system.getOS() == 'Android' then return end

  local mx, my = love.mouse.getPosition()
  local dx, dy = push:toGame(mx, my)

  if utils.overlaps(dx, dy, x, y, w, h) then
    love.graphics.setColor(101/255, 64/255, 83/255, 0.7)
    love.graphics.rectangle('fill', x, y, w, h)
    love.graphics.setColor(1, 1, 1, 1)
  end
end

return utils

local Object = require('libs.classic')
local GameState = Object:extend()

function GameState:new()
  self.screen = nil
  self.stack = {}
  self.assets = {}
end

function GameState:push(screen)
  table.insert(self.stack, screen)
  self.screen = screen
  self.screen:show()
end

function GameState:pop()
  self.screen:dispose()
  table.remove(self.stack, #self.stack)
  self.screen = self.stack[#self.stack]
end

function GameState:switch(screen)
  if #self.stack > 0 then self:pop() end
  self:push(screen)
end


-- Propagate events to the current active screen.

function GameState:update(dt)
  return self.screen:update(dt)
end

function GameState:draw()
  return self.screen:draw()
end

function GameState:keypressed(key, scancode, isrepeat)
  return self.screen:keypressed(key, scancode, isrepeat)
end

function GameState:keyreleased(key, scancode)
  return self.screen:keyreleased(key, scancode)
end

function GameState:mousepressed(x, y, button, istouch, presses)
  return self.screen:mousepressed(x, y, button, istouch, presses)
end

function GameState:mousereleased(x, y, button, istouch, presses)
  return self.screen:mousereleased(x, y, button, istouch, presses)
end

return GameState

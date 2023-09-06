local Object = require('libs.classic')
local Screen = Object:extend()

-- A basic screen template with placeholders for the events.

function Screen:new(game)
  -- The GameState
  self.game = game
end

function Screen:show() end
function Screen:dispose() end
function Screen:update(dt) end
function Screen:draw() end
function Screen:drawRaw() end
function Screen:keypressed(key, scancode, isrepeat) end
function Screen:keyreleased(key, scancode) end
function Screen:mousepressed(x, y, button, istouch, presses) end
function Screen:mousereleased(x, y, button, istouch, presses) end


return Screen

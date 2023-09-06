local Screen = require('screen')
local push = require('libs.push')
local utils = require('utils')
local overlaps = utils.overlaps
local drawHover = utils.drawHover
local GameScreen = require('screens.game')
local flux = require('libs.flux')
local MenuScreen = Screen:extend()


function MenuScreen:new(game)
  MenuScreen.super.new(self, game)

  -- For drawing the additional menu prompt when play is clicked.
  -- This starts at completely transparent and then we tween it to visible
  -- when the menu is supposed to be opened.
  self.alpha = 0

  local assets = self.game.assets

  if not assets.sheet then
    local sheet = love.graphics.newImage('assets/sprites.png')
    assets.sheet = sheet

    if not assets.menu then
      local sw, sh = sheet:getPixelDimensions()
      assets.menu = love.graphics.newQuad(3, 3, 64, 113, sw, sh)
      assets.playMenu = love.graphics.newQuad(69, 35, 54, 40, sw, sh)
      assets.vsAI = love.graphics.newQuad(69, 17, 25, 7, sw, sh)
      assets.pvp = love.graphics.newQuad(69, 27, 25, 7, sw, sh)
    end
  end

  if not assets.click then
    assets.click = love.audio.newSource('assets/click.wav', 'static')
  end
end


function MenuScreen:draw()
  local assets = self.game.assets

  love.graphics.draw(assets.sheet, assets.menu, 0, 0)

  local x, y = love.mouse.getPosition()
  local dx, dy = push:toGame(x, y)

  drawHover(21, 55, 23, 6)
  drawHover(21, 65, 23, 6)

  love.graphics.setColor(1, 1, 1, self.alpha)
  love.graphics.draw(assets.sheet, assets.playMenu, 5, 40, 0, 1, 1)
  love.graphics.draw(assets.sheet, assets.vsAI, 19, 52, 0)
  love.graphics.draw(assets.sheet, assets.pvp, 19, 62)
  love.graphics.setColor(1, 1, 1, 1)

  if self.alpha == 1 then
    drawHover(19, 52, 25, 7)
    drawHover(19, 62, 25, 7)
  end
end

function MenuScreen:keyreleased(key)
  if key == 'escape' then
    if self.alpha == 1 then
      flux.to(self, 0.3, { alpha = 0 })
    else
      love.event.quit()
    end
  end
end

function MenuScreen:mousereleased(x, y, button)
  if button ~= 1 then return end
  self.game.assets.click:play()

  dx, dy = push:toGame(x, y)

  -- PLAY button
  if self.alpha == 0 and overlaps(dx, dy, 21, 55, 23, 6) then
    -- self.game:push(GameScreen(self.game))
    flux.to(self, 0.3, { alpha = 1 })
    return
  end

  if not overlaps(dx, dy, 5, 40, 54, 40) then
    if self.alpha == 1 then
      flux.to(self, 0.3, { alpha = 0 })
      return
    end
  end

  if self.alpha == 0 and overlaps(dx, dy, 21, 65, 23, 6) then
    love.event.quit()
  end

  if self.alpha == 1 then
    if overlaps(dx, dy, 19, 52, 25, 7) then
      self.game:push(GameScreen(self.game, 'ai'))
      flux.to(self, 0.3, { alpha = 0 })
    elseif overlaps(dx, dy, 19, 62, 25, 7) then
      self.game:push(GameScreen(self.game, 'pvp'))
      flux.to(self, 0.3, { alpha = 0 })
    end
  end
end

return MenuScreen

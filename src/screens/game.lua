local Screen = require('screen')
local Board = require('board')
local utils = require('utils')
local push = require('libs.push')
local log = require('libs.log')
local flux = require('libs.flux')
local drawHover = utils.drawHover
local overlaps = utils.overlaps
local GameScreen = Screen:extend()


function GameScreen:new(game, mode)
  GameScreen.super.new(self, game)
  self.mode = mode
  self.board = Board()
  self.alpha = 0
  self.winner = 0
  self.start = 0

  -- Current player's turn, 1 is X, 2 is O
  -- This is consistent with the board treatment of values
  -- So we can easily place the right value on the board.
  self.current = 1

  local assets = self.game.assets
  if not assets.game then
    local sw, sh = assets.sheet:getPixelDimensions()
    assets.game = love.graphics.newQuad(125, 3, 64, 113, sw, sh)
    assets.x = love.graphics.newQuad(192, 97, 16, 16, sw, sh)
    assets.o = love.graphics.newQuad(211, 97, 16, 16, sw, sh)
    assets.xTurn = love.graphics.newQuad(192, 80, 26, 7, sw, sh)
    assets.oTurn = love.graphics.newQuad(192, 87, 26, 7, sw, sh)
    assets.play = love.graphics.newQuad(191, 17, 25, 7, sw, sh)
    assets.quit = love.graphics.newQuad(191, 27, 25, 7, sw, sh)

    -- The asset pack is not perfect and hardcoded the winner
    -- So this file is my custom edit.
    assets.win = love.graphics.newImage('assets/win.png')
    assets.draw = love.graphics.newImage('assets/draw.png')
    assets.smallX = love.graphics.newQuad(192, 80, 4, 7, sw, sh)
    assets.smallO = love.graphics.newQuad(192, 87, 4, 7, sw, sh)

    assets.winSound = love.audio.newSource('assets/victory.wav', 'static')
    assets.loseSound = love.audio.newSource('assets/lose.wav', 'static')
  end
end

function GameScreen:drawGrid(x, y, gy, gx)
  local value = self.board.grid[gy][gx]
  local assets = self.game.assets

  if value == 0 then return end
  love.graphics.draw(assets.sheet, value == 1 and assets.x or assets.o, x, y)
end

function GameScreen:draw()
  local assets = self.game.assets
  love.graphics.draw(assets.sheet, assets.game, 0, 0)

  if self.mode == 'pvp' then
    love.graphics.draw(assets.sheet, self.current == 1 and assets.xTurn or assets.oTurn, 19, 21)
  end

  if self.alpha == 0 then
    drawHover(5, 36, 16, 16)
    drawHover(24, 36, 16, 16)
    drawHover(43, 36, 16, 16)

    drawHover(5, 55, 16, 16)
    drawHover(24, 55, 16, 16)
    drawHover(43, 55, 16, 16)

    drawHover(5, 74, 16, 16)
    drawHover(24, 74, 16, 16)
    drawHover(43, 74, 16, 16)
  end

  self:drawGrid(5, 36, 1, 1)
  self:drawGrid(24, 36, 1, 2)
  self:drawGrid(43, 36, 1, 3)

  self:drawGrid(5, 55, 2, 1)
  self:drawGrid(24, 55, 2, 2)
  self:drawGrid(43, 55, 2, 3)

  self:drawGrid(5, 74, 3, 1)
  self:drawGrid(24, 74, 3, 2)
  self:drawGrid(43, 74, 3, 3)

  love.graphics.setColor(1, 1, 1, self.alpha)
  love.graphics.draw(self.winner == 'draw' and assets.draw or assets.win, 5, 40)
  if self.winner ~= 'draw' then
    love.graphics.draw(assets.sheet, self.winner == 1 and assets.smallX or assets.smallO, 19, 40)
  end
  love.graphics.draw(assets.sheet, assets.play, 19, 52)
  love.graphics.draw(assets.sheet, assets.quit, 19, 62)
  love.graphics.setColor(1, 1, 1, 1)

  if self.alpha == 1 then
    drawHover(19, 52, 25, 7)
    drawHover(19, 62, 25, 7)
  end
end


function GameScreen:handleGrid(dx, dy, x, y, w, h, gy, gx)
  if overlaps(dx, dy, x, y, w, h) then
    if self.board:play(gy, gx, self.current) then
      self.game.assets.click:play()
      self.current = self.current == 1 and 2 or 1
    end
  end
end

function GameScreen:keyreleased(key)
  if key == 'escape' then
    self.game:pop()
    return
  end
end

function GameScreen:checkWinner()
  self.winner = self.board:check()
  if self.winner then
    if self.mode == 'ai' then
      if self.winner == 1 then
        self.game.assets.winSound:play()
      else
        self.game.assets.loseSound:play()
      end
    else
      self.game.assets.winSound:play()
    end

    log.debug('Player ' .. self.winner .. ' Won!')
    flux.to(self, 0.3, { alpha = 1 })
    return true
  elseif self.board:full() then
    self.winner = 'draw'
    log.debug('Match draw!')
    flux.to(self, 0.3, { alpha = 1 })
    return true
  end

  return false
end

function GameScreen:mousereleased(x, y)
  local dx, dy = push:toGame(x, y)

  if self.alpha == 0 then
    self:handleGrid(dx, dy, 5, 36, 16, 16, 1, 1)
    self:handleGrid(dx, dy, 24, 36, 16, 16, 1, 2)
    self:handleGrid(dx, dy, 43, 36, 16, 16, 1, 3)

    self:handleGrid(dx, dy, 5, 55, 16, 16, 2, 1)
    self:handleGrid(dx, dy, 24, 55, 16, 16, 2, 2)
    self:handleGrid(dx, dy, 43, 55, 16, 16, 2, 3)

    self:handleGrid(dx, dy, 5, 74, 16, 16, 3, 1)
    self:handleGrid(dx, dy, 24, 74, 16, 16, 3, 2)
    self:handleGrid(dx, dy, 43, 74, 16, 16, 3, 3)

    if not self:checkWinner() and self.mode == 'ai' and self.current == 2 then
      self.board:playAI(self.current)
      self.current = 1
      -- Recheck winner after AI's move.
      self:checkWinner()
    end
  end

  if self.alpha == 1 then
    if overlaps(dx, dy, 19, 52, 25, 7) then
      -- In the next round the first turn goes to the loser.
      -- In case there is no winner (draw) it changes players anyway.
      -- This only applies to pvp, in AI mode the player is always X
      self.current = self.mode == 'ai' and 1 or (self.board:check() or self.start) == 1 and 2 or 1
      self.start = current
      self.board:reset()
      flux.to(self, 0.3, { alpha = 0 })
    elseif overlaps(dx, dy, 19, 62, 25, 7) then
      self.game:pop()
    end
  end
end

return GameScreen

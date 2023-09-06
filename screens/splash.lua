local Screen = require('screen')
local MenuScreen = require('screens.menu')
local log = require('libs.log')
local flux = require('libs.flux')
local SplashScreen = Screen:extend()

function SplashScreen:new(game)
  SplashScreen.super.new(self, game)
  self.alpha = 0.01
  self.skip = false

  if not self.game.assets.logo then
    self.game.assets.logo = love.graphics.newImage('assets/logo.png')
    self.game.assets.love = love.graphics.newImage('assets/love.png')
  end
end

function SplashScreen:show()
  if not self.game.assets.music then
    log.debug('Loading music...')
    local music = love.audio.newSource('assets/music.ogg', 'stream')
    music:setLooping(true)
    music:setVolume(0.5)
    music:play()
    self.game.assets.music = music
  end

  -- Gradually fade in the logo then fade out.
  flux.to(self, 2, { alpha = 1 }):after(self, 1, { alpha = 0 })
end

function SplashScreen:update(dt)
  -- When the text completely faded out, switch to menu screen.
  if self.alpha == 0 then
    log.debug('Splash Screen Done.')
    self.game:switch(MenuScreen(self.game))
  elseif self.skip then
    -- avoid repeating this logic
    self.skip = false
    -- If they press to skip, do a faster transition.
    flux.to(self, 0.3, { alpha = 0 }):oncomplete(function ()
      log.debug('Splash screen skipped')
      self.game:switch(MenuScreen(self.game))
    end)
  end
end

function SplashScreen:draw()
  love.graphics.clear(101/255, 64/255, 83/255)
  love.graphics.setColor(1, 1, 1, self.alpha)
  love.graphics.draw(self.game.assets.logo, 15, 52)
  love.graphics.draw(self.game.assets.love, 11, 98)
end

function SplashScreen:keypressed()
  self.skip = true
end

function SplashScreen:mousepressed()
  self.skip = true
end


return SplashScreen

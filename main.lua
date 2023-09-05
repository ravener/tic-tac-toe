-- Use nearest filtering for smooth pixel art scaling.
love.graphics.setDefaultFilter('nearest', 'nearest')

local GameState = require('state')
local SplashScreen = require('screens.splash')
local push = require('libs.push')
local log = require('libs.log')
local flux = require('libs.flux')
local utils = require('utils')
local debug = false

local gameWidth, gameHeight = 64, 113 --fixed game resolution

if love.system.getOS() == 'Android' then
  -- On Android take up the whole screen in fullscreen.
  local windowWidth, windowHeight = love.window.getDesktopDimensions()

  -- Portrait mode is slightly buggy in LOVE
  -- This appears to make it a little better.
  if windowWidth > windowHeight then
    windowWidth, windowHeight = windowHeight, windowWidth
  end

  push:setupScreen(gameWidth, gameHeight, windowWidth, windowHeight, {
    fullscreen = true,
    resizable = false
  })
else
  -- On desktop start in resizable windowed mode
  local windowWidth, windowHeight = 320, 565
  push:setupScreen(gameWidth, gameHeight, windowWidth, windowHeight, {
    fullscreen = false,
    resizable = true,
  })
end

-- Add a brown border color that matches the game's background.
-- This gives a consistent feeling when the scaling introduces black bars
-- Since those bars will now blend in nicely with our background.
push:setBorderColor(101/255, 64/255, 83/255)

local game = GameState()

function love.load()
  -- Additional measures to ensure android screen is set properly.
  if love.system.getOS() == 'Android' then
    love.window.setFullscreen(true)
  end

  -- Set custom cursor.
  local cursorImage = love.image.newImageData('assets/cursor.png')
  local cursor = love.mouse.newCursor(cursorImage)
  love.mouse.setCursor(cursor)

  log.debug('Initialized, loading splash screen...')
  game:switch(SplashScreen(game))
end

function love.update(dt)
  flux.update(dt)
  game:update(dt)
end

function love.draw()
  push:start()
  game:draw()
  push:finish()

  if debug then utils.renderFPS() end
end

function love.keypressed(key, scancode, isrepeat)
  game:keypressed(key, scancode, isrepeat)
end

function love.keyreleased(key, scancode)
  -- Toggle debug info
  if key == 'tab' then debug = not debug end
  game:keyreleased(key, scancode)
end

function love.mousepressed(x, y, button, istouch, presses)
  game:mousepressed(x, y, button, istouch, presses)
end

function love.mousereleased(x, y, button, istouch, presses)
  game:mousereleased(x, y, button, istouch, presses)
end

function love.resize(w, h)
  -- ditto
  if w > h then w, h = h, w end
  push:resize(w, h)
end

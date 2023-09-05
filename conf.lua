
function love.conf(t)
  -- Disable modules we don't need.
  t.modules.physics = false
  t.modules.video = false
  t.modules.joystick = false

  -- Window configuration
  t.window.title = 'Tic Tac Toe'
  t.window.icon = 'assets/icon.png'
  t.window.width = 320
  t.window.height = 565
  t.window.minwidth = 64
  t.window.minheight = 113
  t.window.resizable = true
end

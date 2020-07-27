local composer = require'composer'

display.setStatusBar(display.HiddenStatusBar)

math.randomseed(os.time())
system.activate("multitouch")
composer.isDebug = true 

composer.gotoScene'menu'

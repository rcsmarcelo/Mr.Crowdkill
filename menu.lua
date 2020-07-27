-----------------------------------------------------------------------------------------
--
-- menu.lua
--
-----------------------------------------------------------------------------------------
local composer = require"composer"
local menuMusic
local scene = composer.newScene()

-- -----------------------------------------------------------------------------------
-- Composer functions
-- -----------------------------------------------------------------------------------
local function gotoGame()
	audio.stop(1)
	audio.dispose(menuMusic)
	composer.gotoScene('stage1', {time = 2000, efffect = crossfade})
end

-- -----------------------------------------------------------------------------------
-- Scene event functions
-- -----------------------------------------------------------------------------------
function scene:create()
	local sceneGroup = self.view
	-- Code here runs when the scene is first created but has not yet appeared on screen

	local Background = display.newImageRect(sceneGroup, "Sprites/Menu/background.png", 500, 198)
	Background.x = display.contentCenterX
	Background.y = display.contentCenterY
	Background:scale(1.7, 1.7)

	local Title = display.newImageRect(sceneGroup, "Sprites/Menu/logo.png", 300, 150)
	Title.x = display.contentCenterX - 100
	Title.y = 150

	local playButton = display.newImageRect(sceneGroup, "Sprites/Menu/play.png", 100, 50)
	playButton.x = display.contentCenterX + 150
	playButton.y = display.contentCenterY - 50
	playButton:setFillColor(0.80, 0.1, 1)
	playButton:addEventListener('tap', gotoGame)

	local highscoresButton = display.newText(sceneGroup, 'Highscores',
		display.contentCenterX, 810, native.systemFont, 44)
	highscoresButton.x = display.contentCenterX + 150
	highscoresButton.y = display.contentCenterY + 30
	highscoresButton:setFillColor(0.75, 0.78, 1)
	highscoresButton:scale(0.7, 0.7)
	--highscoresButton:addEventListener('tap', gotoHighScores)
end

-- show()
function scene:show(event)
	local sceneGroup = self.view
	local phase = event.phase

	if (phase == "will" ) then
		menuMusic = audio.loadStream("Sounds/Furtive Monologue.mp3")
		audio.setVolume(0.3, { channel=1 })
		audio.seek(45000, menuMusic)
		audio.play(menuMusic)
	end
end


-- hide()
function scene:hide( event )

	local sceneGroup = self.view
	local phase = event.phase

	if ( phase == "will" ) then
		-- Code here runs when the scene is on screen (but is about to go off screen)

	elseif ( phase == "did" ) then
		-- Code here runs immediately after the scene goes entirely off screen

	end
end


-- destroy()
function scene:destroy( event )

	local sceneGroup = self.view
	-- Code here runs prior to the removal of scene's view

end


-- -----------------------------------------------------------------------------------
-- Scene event function listeners
-- -----------------------------------------------------------------------------------
scene:addEventListener( "create", scene )
scene:addEventListener( "show", scene )
scene:addEventListener( "hide", scene )
scene:addEventListener( "destroy", scene )
-- -----------------------------------------------------------------------------------

return scene

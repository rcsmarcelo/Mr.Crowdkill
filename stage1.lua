-- -----------------------------------------------------------------------------------
--
-- stage 1
--
-- -----------------------------------------------------------------------------------
local composer = require'composer'
local scene = composer.newScene()

local physics = require'physics'
physics.start()
physics.setGravity(10, 10)

--control variables
local Lives = 5
local Health = 100
local Score = 0
local Cash = 0
local Kills = 0
local Died = false

--game variables
local Enemies = {}
local Player

--ui variables
local HealthUI
local LivesUI
local ScoreUI
local KillsUI
local CashUI
local EnemyHealthUI
local ControlUpUI
local ControlDownUI
local ControlLeftUI
local ControlRightUI

--scene variables
local BackGroup
local UIGroup
local MainGroup

--sound variables
local PunchSound
local GruntSound
local BGMusic
local BreakSound

-- -----------------------------------------------------------------------------------
-- Scene event functions
-- -----------------------------------------------------------------------------------

function scene:create(event)
	local sceneGroup = self.view
	-- Code here runs when the scene is first created but has not yet appeared on screen
	physics.pause()

	--create subgroups
	BackGroup = display.newGroup()
	sceneGroup:insert(BackGroup)

	MainGroup = display.newGroup()
	sceneGroup:insert(MainGroup)

	UIGroup = display.newGroup()
	sceneGroup:insert(UIGroup)

	--load background
	local background = display.newImageRect(BackGroup, 'Sprites/BGs/City2/Bright/City2.png', 1400, 800)
	background.x = display.contentCenterX
	background.y = display.contentCenterY
	background:scale(0.4, 0.4)

	--add ui text
	LivesText = display.newText(UIGroup, 'Lives: ' .. Lives, display.contentCenterX - 210,
							display.contentCenterY - 130, native.systemFont, 36)
	LivesText:scale(0.8, 0.8)
	ScoreText = display.newText(UIGroup, 'Score: ' .. Score, display.contentCenterX - 210,
							display.contentCenterY - 90, native.systemFont, 36)
	ScoreText:scale(0.8, 0,8)

	--add controls
	ControlUpUI = display.newImageRect(UIGroup, 'Sprites/UI/joyup.png', 133, 186)
	ControlUpUI:scale(0.3, 0.3)
	ControlUpUI.x = display.contentCenterX - 220
	ControlUpUI.y = display.contentCenterY + 75
	ControlUpUI.alpha = 0.6
	ControlUpUI:addEventListener('touch', move)

	ControlLeftUI = display.newImageRect(UIGroup, 'Sprites/UI/joyleft.png', 170, 134)
	ControlLeftUI:scale(0.3, 0.3)
	ControlLeftUI.x = display.contentCenterX - 250
	ControlLeftUI.y = display.contentCenterY + 105
	ControlLeftUI.alpha = 0.6
	ControlLeftUI:addEventListener('touch', move)

	ControlDownUI = display.newImageRect(UIGroup, 'Sprites/UI/joyup.png', 133, 186)
	ControlDownUI:scale(0.3, 0.3)
	ControlDownUI:rotate(180)
	ControlDownUI.x = display.contentCenterX - 220
	ControlDownUI.y = display.contentCenterY + 130
	ControlDownUI.alpha = 0.6
	ControlDownUI:addEventListener('touch', move)

	ControlRightUI = display.newImageRect(UIGroup, 'Sprites/UI/joyright.png', 170, 134)
	ControlRightUI:scale(0.3, 0.3)
	ControlRightUI.x = display.contentCenterX - 190
	ControlRightUI.y = display.contentCenterY + 105
	ControlRightUI.alpha = 0.6
	ControlRightUI:addEventListener('touch', move)


	--create player and it's movements
	local sheetOptions = 	{
		width = 64,
		height = 64,
		numFrames = 126
	}
	local PlayerSheet = graphics.newImageSheet('Sprites/Player/Char_3_No_Armor.png', sheetOptions)
	local PlayerSequences = {
		{
			name = "walk",
			frames = {30, 31, 32, 33, 34, 35},
			time = 700,
			loopCount = 0
		}
	}

	Player = display.newSprite(MainGroup, PlayerSheet, PlayerSequences)
	Player.x = display.contentCenterX - 200
	Player.y = display.contentCenterY + 110
end

function scene:show(event)
	physics.start()
	physics.setGravity(0, 0)
	Player:play()
end

-- -----------------------------------------------------------------------------------
-- Event listeners
-- -----------------------------------------------------------------------------------

function move(event)
	if (event.target == ControlUpUI) then
		if (event.phase == 'began') then
			Player.y = Player.y - 0.1
		elseif (event.phase == 'ended') then
			Player.y = Player.y
		end
	elseif (event.target == ControlDownUI) then
		if (event.phase == 'began') then
			Player.y = Player.y + 0.1
		elseif (event.phase == 'ended') then
			Player.y = Player.y
		end
	elseif (event.target == ControlRightUI) then
		if (event.phase == 'began') then
			Player.x = Player.x + 0.1
		elseif (event.phase == 'ended') then
			Player.x = Player.x
		end
	elseif (event.target == ControlLeftUI) then
		if (event.phase == 'began') then
			Player.x = Player.x - 0.1
		elseif (event.phase == 'ended') then
			Player.x = Player.x
		end
	end
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

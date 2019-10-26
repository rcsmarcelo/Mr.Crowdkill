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
local SpeedX = 0
local SpeedY = 0
local BackgroundSpeed = 0

--game variables
local Enemies = {}
local Player
local Background
local PlayableArea = {}
local vertices = {}
local BGMove = false

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
-- Auxiliar functions
-- -----------------------------------------------------------------------------------
function editPlayableArea()
	for i = 0, #vertices do
		if (i % 2 ~= 0) then
			vertices[i] = vertices[i] + BackgroundSpeed
		end
	end
end

function isInArea(x, y, vertices)
	local polyX = {}
	local polyY = {}
	local j = #vertices/2
	local result = false
	for i, xy in ipairs(vertices) do
		if (i % 2 == 0) then
			table.insert(polyY, xy)
		else
			table.insert(polyX, xy)
		end
	end

	for i = 1, #vertices/2 do
		if ( (polyY[i] < y and polyY[j] >= y)
				or (polyY[j] < y and polyY[i] >= y)
				and (polyX[i] <= x or polyX[j] <= x)) then
			if (polyX[i] + (y - polyY[i]) / (polyY[j] - polyY[i])
			 		* (polyX[j] - polyX[i]) < x) then
				result = not result
			end
		end
		j = i
	end
	return result
end

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
	Background = display.newImageRect(BackGroup, 'Sprites/BGs/City2/Bright/City2.png', 5240, 1080)
	Background.x = display.contentCenterX
	Background.y = display.contentCenterY
	Background:scale(0.3, 0.3)

	--create PlayableArea
	vertices = {-29, 203, 45, 203, 45, 233, 149, 233, 175, 216, 365, 214, 365, 232, 430,
		232, 429, 189, 481, 189, 481, 200, 616, 200, 616, 297, -29, 297}
	PlayableArea = display.newPolygon(Background.x + 50, display.contentCenterY + 100,
		vertices)
	PlayableArea.Vertices = vertices
	PlayableArea.alpha = 0.5

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
	ControlUpUI:addEventListener('touch', moveCalc)

	ControlLeftUI = display.newImageRect(UIGroup, 'Sprites/UI/joyleft.png', 170, 134)
	ControlLeftUI:scale(0.3, 0.3)
	ControlLeftUI.x = display.contentCenterX - 250
	ControlLeftUI.y = display.contentCenterY + 105
	ControlLeftUI.alpha = 0.6
	ControlLeftUI:addEventListener('touch', moveCalc)

	ControlDownUI = display.newImageRect(UIGroup, 'Sprites/UI/joyup.png', 133, 186)
	ControlDownUI:scale(0.3, 0.3)
	ControlDownUI:rotate(180)
	ControlDownUI.x = display.contentCenterX - 220
	ControlDownUI.y = display.contentCenterY + 130
	ControlDownUI.alpha = 0.6
	ControlDownUI:addEventListener('touch', moveCalc)

	ControlRightUI = display.newImageRect(UIGroup, 'Sprites/UI/joyright.png', 170, 134)
	ControlRightUI:scale(0.3, 0.3)
	ControlRightUI.x = display.contentCenterX - 190
	ControlRightUI.y = display.contentCenterY + 105
	ControlRightUI.alpha = 0.6
	ControlRightUI:addEventListener('touch', moveCalc)
	Runtime:addEventListener('enterFrame', move)


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
			time = 500,
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
end

-- -----------------------------------------------------------------------------
-- Event listeners
-- -----------------------------------------------------------------------------
function move(event)
	if (not isInArea(Player.x, Player.y, PlayableArea.Vertices)) then
		if (isInArea(Player.x, Player.y + 10, PlayableArea.Vertices)) then
			Player.y = Player.y + 1
		elseif (isInArea(Player.x, Player.y - 10, PlayableArea.Vertices)) then
			Player.y = Player.y - 1
		elseif (isInArea(Player.x + 10, Player.y, PlayableArea.Vertices)) then
			Player.x = Player.x + 1
		elseif (isInArea(Player.x - 10, Player.y, PlayableArea.Vertices)) then
			Player.x = Player.x - 1
		else
			SpeedX = 0
			SpeedY = 0
		end
	end
	if (Player.x >= 280) then BGMove = true end
	if (Background.x <= 30 and Background.x % 90 == 0) then BGMove = false end
	if (BGMove) then
		Background.x = Background.x + BackgroundSpeed
		PlayableArea.x = PlayableArea.x + BackgroundSpeed
		display.remove(PlayableArea)
		editPlayableArea()
		PlayableArea = display.newPolygon(Background.x + 50, display.contentCenterY + 100,
			vertices)
		PlayableArea.Vertices = vertices
		PlayableArea.alpha = 0.1
		if (SpeedX > 0) then SpeedX = -0.8 end
	elseif (SpeedX == -0.8) then
			SpeedX = 0
			Player:pause()
	end
	Player.x = Player.x + SpeedX
	Player.y = Player.y + SpeedY
end

function moveCalc(event)
	if (event.target == ControlUpUI) then
		if (event.phase == 'began') then
			Player:play()
			SpeedX = 0
			SpeedY = -1
		elseif (event.phase == 'ended') then
			Player:pause()
			SpeedX = 0
			SpeedY = 0
		end
	elseif (event.target == ControlDownUI) then
		if (event.phase == 'began') then
			Player:play()
			SpeedX = 0
			SpeedY = 1
		elseif (event.phase == 'ended') then
			Player:pause()
			SpeedX = 0
			SpeedY = 0
		end
	elseif (event.target == ControlRightUI) then
		if (event.phase == 'began') then
			Player:play()
			Player.xScale = 1
			SpeedX = 1
			SpeedY = 0
			BackgroundSpeed = - 1
		elseif (event.phase == 'ended') then
			Player:pause()
			SpeedX = 0
			SpeedY = 0
			BackgroundSpeed = 0
		end
	elseif (event.target == ControlLeftUI) then
		if (event.phase == 'began') then
			Player:play()
			Player.xScale = -1
			SpeedX = -1
			SpeedY = 0
		elseif (event.phase == 'ended') then
			Player:pause()
			SpeedX = 0
			SpeedY = 0
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

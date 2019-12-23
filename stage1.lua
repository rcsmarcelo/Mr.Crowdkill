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
local BGMove = false
local AreaClear = false

--game variables
local Enemies = {}
local ClosestEnemy
local Player
local Background
local PlayableArea = {}
local vertices = {}

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
local ButtonRedUI

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

function getDistance(obj1X, obj1Y, obj2X, obj2Y)
	return math.sqrt(math.pow((obj2X - obj1X), 2)
		+ math.pow((obj2Y - obj1Y), 2))
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

function setClosestEnemy()
	local distance = math.huge
	local enemy
	for i, en in ipairs(Enemies) do
		if (getDistance(Player.x, Player.y, en.x, en.y) < distance) then
			distance = getDistance(Player.x, Player.y, en.x, en.y)
			enemy = en
		end
	end
	ClosestEnemy = enemy
end

--placeholder name
function moveCollisionChecker()
	if (not isInArea(Player.x, Player.y, PlayableArea.Vertices)) then
		if (SpeedX > 0) then
			Player.x = Player.x - 1
		elseif (SpeedX > 0) then
			Player.x = Player.x + 1
		elseif (SpeedY > 0) then
			Player.y = Player.y - 1
		elseif (SpeedY < 0) then
			Player.y = Player.y + 1
		end
		SpeedX = 0
		SpeedY = 0
	end
	if (ClosestEnemy and getDistance(Player.x, Player.y,
			ClosestEnemy.x, ClosestEnemy.y) < 20) then
			if (SpeedX > 0) then
				Player.x = Player.x - 1
			elseif (SpeedX > 0) then
				Player.x = Player.x + 1
			elseif (SpeedY > 0) then
				Player.y = Player.y - 1
			elseif (SpeedY < 0) then
				Player.y = Player.y + 1
			end
		SpeedX = 0
		SpeedY = 0
	end
end

function moveBackgroundChecker()
	if (Player.x <= 90) then BGMove = false
	elseif (Player.x >= 280 and AreaClear) then BGMove = true end
	if (BGMove) then
		Background.x = Background.x + BackgroundSpeed
		PlayableArea.x = PlayableArea.x + BackgroundSpeed
		display.remove(PlayableArea)
		editPlayableArea()
		PlayableArea = display.newPolygon(Background.x + 280,
			display.contentCenterY + 100, vertices)
		PlayableArea.Vertices = vertices
		PlayableArea.alpha = 0
		if (SpeedX > 0) then SpeedX = -0.7 end
		elseif (SpeedX == -0.7) then
			SpeedX = 1
	end
	if (Player.x <= -29) then
		SpeedX = 0
		Player.x = Player.x + 1
	elseif (Player.x >= 480) then
		SpeedX = 0
		Player.x = Player.x - 1
	end
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
	Background = display.newImageRect(BackGroup,
			'Sprites/BGs/City2/Bright/City2.png', 5240, 1080)
	Background.x = display.contentCenterX
	Background.y = display.contentCenterY
	Background:scale(0.3, 0.3)

	--create PlayableArea
	vertices = {-29, 203, 45, 203, 45, 233, 149, 233, 175, 214, 365, 214,
			365, 232, 430,232, 429, 189, 481, 189, 481, 203, 521, 203, 620, 203,
			620, 233, 725, 233, 750, 214, 935, 214, 935, 232, 1020, 232, 1020,
			189, 1051, 189, 1051, 200, 1080, 200, 1080, 297, -29, 297}

	PlayableArea = display.newPolygon(Background.x + 280,
			display.contentCenterY + 100,	vertices)
	PlayableArea.Vertices = vertices
	PlayableArea.alpha = 0

	--add ui text
	LivesText = display.newText(UIGroup, 'Lives: ' .. Lives,
			display.contentCenterX - 210, display.contentCenterY - 130,
			native.systemFont, 36)
	LivesText:scale(0.8, 0.8)
	ScoreText = display.newText(UIGroup, 'Score: ' .. Score,
			display.contentCenterX - 210, display.contentCenterY - 90,
			native.systemFont, 36)
	ScoreText:scale(0.8, 0,8)

	--add controls
	ButtonRedUI = display.newImageRect(UIGroup,
			'Sprites/UI/buttons.png', 133, 133)
	ButtonRedUI.x = display.contentCenterX + 220
	ButtonRedUI.y = display.contentCenterY + 75
	ButtonRedUI.alpha = 0.6
	ButtonRedUI:addEventListener('tap', attack)

	ControlUpUI = display.newImageRect(UIGroup,
			'Sprites/UI/joyup.png', 133, 186)
	ControlUpUI:scale(0.3, 0.3)
	ControlUpUI.x = display.contentCenterX - 220
	ControlUpUI.y = display.contentCenterY + 75
	ControlUpUI.alpha = 0.6
	ControlUpUI:addEventListener('touch', moveCalc)

	ControlLeftUI = display.newImageRect(UIGroup,
			'Sprites/UI/joyleft.png', 170, 134)
	ControlLeftUI:scale(0.3, 0.3)
	ControlLeftUI.x = display.contentCenterX - 250
	ControlLeftUI.y = display.contentCenterY + 105
	ControlLeftUI.alpha = 0.6
	ControlLeftUI:addEventListener('touch', moveCalc)

	ControlDownUI = display.newImageRect(UIGroup, 'Sprites/UI/joyup.png',
			133, 186)
	ControlDownUI:scale(0.3, 0.3)
	ControlDownUI:rotate(180)
	ControlDownUI.x = display.contentCenterX - 220
	ControlDownUI.y = display.contentCenterY + 130
	ControlDownUI.alpha = 0.6
	ControlDownUI:addEventListener('touch', moveCalc)

	ControlRightUI = display.newImageRect(UIGroup,
			'Sprites/UI/joyright.png', 170, 134)
	ControlRightUI:scale(0.3, 0.3)
	ControlRightUI.x = display.contentCenterX - 190
	ControlRightUI.y = display.contentCenterY + 105
	ControlRightUI.alpha = 0.6
	ControlRightUI:addEventListener('touch', moveCalc)

	Runtime:addEventListener('enterFrame', move)
	Runtime:addEventListener('enterFrame', checkArea)
	Runtime:addEventListener('enterFrame', checkHealth)
	Runtime:addEventListener('enterFrame', setClosestEnemy)


	--create player and it's movements
	local sheetOptions = 	{
		width = 64,
		height = 64,
		numFrames = 126
	}
	local PlayerSheet = graphics.
			newImageSheet('Sprites/Player/Char_3_No_Armor.png', sheetOptions)
	local PlayerSequences = {
		{
			name = 'idle',
			frames = {1},
			time = 1,
			loopCount = 0
		},
		{
			name = 'walk',
			frames = {30, 31, 32, 33, 34, 35},
			time = 500,
			loopCount = 0
		},
		{
			name = 'punch1',
			frames = {37, 38, 39},
			time = 400,
			loopCount = 1
		},
		{
			name = 'death',
			frames = {60, 62},
			time = 300,
			loopCount = 1
		},
		{
			name = 'punched',
			frames = {58},
			time = 100,
			loopCount = 1,
		}
	}

	Player = display.newSprite(MainGroup, PlayerSheet, PlayerSequences)
	Player.x = display.contentCenterX - 200
	Player.y = display.contentCenterY + 110
	Player.health = 100
	Player:addEventListener('sprite', endAttackAnimation)

	for i = 0, 0 do
		local Enemy = display.newSprite(MainGroup, PlayerSheet, PlayerSequences)
		Enemy.x = display.contentCenterX + 20*i
		Enemy.y = display.contentCenterY + 110 - 2*i
		Enemy.xScale = -1
		Enemy.health = 100
		table.insert(Enemies, Enemy)
	end

end

function scene:show(event)
	physics.start()
	physics.setGravity(0, 0)
end

-- -----------------------------------------------------------------------------
-- Event listeners
-- -----------------------------------------------------------------------------
function checkHealth()
	--if player dead then do things
	for i, en in ipairs(Enemies) do
		if (en.health == 0) then
			en:setSequence('death')
			en:play()
			timer.performWithDelay(4000, function()
				transition.blink(en, {time = 500})
			end)
			timer.performWithDelay(5000, function()
				display.remove(en)
			end)
			table.remove(Enemies, table.indexOf(Enemies, en))
		end
	end
end

function endAttackAnimation(event)
	local obj = event.target
	if (event.phase == 'ended' and obj.sequence == 'punch1') then
		obj:pause()
		obj:setSequence('idle')
		obj:play()
		if (ClosestEnemy) then
			ClosestEnemy:setSequence('idle')
			ClosestEnemy:play()
		end
	end
end

function attack(event)
		Player:setSequence('punch1')
		Player:play()
		if (ClosestEnemy and getDistance(Player.x, Player.y,
				ClosestEnemy.x, ClosestEnemy.y) <= 25) then
			ClosestEnemy.health = ClosestEnemy.health - 10
			ClosestEnemy:setSequence('punched')
			ClosestEnemy:play()
		end
end

function checkArea(event)
	if table.getn(Enemies) > 0 then
			AreaClear = false
		else
			AreaClear = true
		end
end

function move(event)
	setClosestEnemy()
	moveCollisionChecker()
	moveBackgroundChecker()
	Player.x = Player.x + SpeedX
	Player.y = Player.y + SpeedY
end

function moveCalc(event)
	Player:setSequence('walk')
	if (event.target == ControlUpUI) then
		if (event.phase == 'began') then
			Player:play()
			SpeedX = 0
			SpeedY = -1
		else
			Player:pause()
			Player:setSequence('idle')
			Player:play()
			SpeedX = 0
			SpeedY = 0
		end
	elseif (event.target == ControlDownUI) then
		if (event.phase == 'began') then
			Player:play()
			SpeedX = 0
			SpeedY = 1
		else
			Player:pause()
			Player:setSequence('idle')
			Player:play()
			SpeedX = 0
			SpeedY = 0
		end
	elseif (event.target == ControlRightUI) then
		if (event.phase == 'began') then
			Player:play()
			Player.xScale = 1
			SpeedX = 1
			SpeedY = 0
			BackgroundSpeed = - 1.7
		else
			Player:pause()
			Player:setSequence('idle')
			Player:play()
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
		else
			Player:pause()
			Player:setSequence('idle')
			Player:play()
			SpeedX = 0
			SpeedY = 0
		end
	end
end

-- -----------------------------------------------------------------------------------
-- Scene event function listeners
-- -----------------------------------------------------------------------------------
scene:addEventListener( 'create', scene )
scene:addEventListener( 'show', scene )
scene:addEventListener( 'hide', scene )
scene:addEventListener( 'destroy', scene )

-- -----------------------------------------------------------------------------------
return scene

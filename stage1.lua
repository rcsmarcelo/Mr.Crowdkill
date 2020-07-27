-- -----------------------------------------------------------------------------------
--
-- stage 1
--
-- -----------------------------------------------------------------------------------
local composer = require'composer'
local BT = require'BT.behaviour_tree'
local scene = composer.newScene()

--control variables
local SpeedX = 0
local SpeedY = 0
local BackgroundSpeed = 0
local BGMove = false
local AreaClear = false
local AreaCode = 1
local AreaCanMove = false
local LevelEnd = false

--game variables
local Enemies = {}
local ClosestEnemy
local Player
local Boss
local Background = {}
local PlayableArea = {}
local vertices = {}

--ui variables
local HealthUI = {}
local Controls = {}

--scene variables
local BackGroup
local UIGroup
local MainGroup

--sound variables
local Music = {}
local SoundFX = {}

-- -----------------------------------------------------------------------------------
-- Scene event functions
-- -----------------------------------------------------------------------------------
	-- Code here runs when the scene is first created but has not yet appeared on screen
function scene:create(event)
	local sceneGroup = self.view
	local phase = event.phase

	--create subgroups
	BackGroup = display.newGroup()
	sceneGroup:insert(BackGroup)

	MainGroup = display.newGroup()
	sceneGroup:insert(MainGroup)

	UIGroup = display.newGroup()
	sceneGroup:insert(UIGroup)

	--load audio
	Music.Stage1Music = audio.loadStream("Sounds/Cheyne Stokes.mp3")
	audio.setVolume(0.4, {channel = 1})

	SoundFX.punch = audio.loadSound("Sounds/PUNCH.mp3")
	audio.setVolume(0.4, {channel = 2})
	audio.setVolume(0.4, {channel = 3})

	--load background
	Background[1] = display.newImageRect(BackGroup,
			'Sprites/BGs/City2/Bright/City2.png', 1920, 1080)
	Background[1].x = display.contentCenterX
	Background[1].y = display.contentCenterY
	Background[1]:scale(0.3, 0.3)

	--create PlayableArea polygon
	vertices = {-25, 203, -20, 203, -20, 233, 89, 233, 105, 214, 295, 214,
			295, 232, 360,232, 360, 189, 411, 189, 411, 203, 550, 203,
			550, 295, -25, 295}

	PlayableArea[1] = display.newPolygon(Background[1].x,
			display.contentCenterY,	vertices)
	PlayableArea[1].vertices = vertices
	PlayableArea[1].alpha = 0

	-- create green health bar
	HealthUI.green = display.newRect(UIGroup, 0, -45, 100, 10)
	HealthUI.green:setFillColor(000/255, 255/255, 0/255)
	HealthUI.green.strokeWidth = 1
	HealthUI.green:setStrokeColor(255, 255, 255, .5)
	HealthUI.green.x = display.contentCenterX - 220
	HealthUI.green.y = display.contentCenterY - 125

-- create red damage bar
	HealthUI.red = display.newRect(UIGroup, 0, -45, 0, 10)
	HealthUI.red:setFillColor(255/255, 0/255, 0/255)
	HealthUI.red.x = display.contentCenterX - 170
	HealthUI.red.y = display.contentCenterY - 125

	--add controls
	Controls.ButtonYUI = display.newImageRect(UIGroup,
			'Sprites/UI/buttony.png', 133, 133)
	Controls.ButtonYUI.x = display.contentCenterX + 200
	Controls.ButtonYUI.y = display.contentCenterY + 100
	Controls.ButtonYUI.alpha = 0.6
	Controls.ButtonYUI.name = 'punchbutton'
	Controls.ButtonYUI:scale(0.4, 0.4)
	Controls.ButtonYUI:addEventListener('tap', attack)

	Controls.ButtonPUI = display.newImageRect(UIGroup,
			'Sprites/UI/buttonp.png', 133, 133)
	Controls.ButtonPUI.x = display.contentCenterX + 240
	Controls.ButtonPUI.y = display.contentCenterY + 60
	Controls.ButtonPUI.alpha = 0.6
	Controls.ButtonPUI.name = 'kickbutton'
	Controls.ButtonPUI:scale(0.4, 0.4)
	Controls.ButtonPUI:addEventListener('tap', attack)

	Controls.ControlUpUI = display.newImageRect(UIGroup,
			'Sprites/UI/joyup.png', 133, 186)
	Controls.ControlUpUI:scale(0.3, 0.3)
	Controls.ControlUpUI.x = display.contentCenterX - 220
	Controls.ControlUpUI.y = display.contentCenterY + 75
	Controls.ControlUpUI.alpha = 0.6
	Controls.ControlUpUI:addEventListener('touch', moveCalc)

	Controls.ControlLeftUI = display.newImageRect(UIGroup,
			'Sprites/UI/joyleft.png', 170, 134)
	Controls.ControlLeftUI:scale(0.3, 0.3)
	Controls.ControlLeftUI.x = display.contentCenterX - 250
	Controls.ControlLeftUI.y = display.contentCenterY + 105
	Controls.ControlLeftUI.alpha = 0.6
	Controls.ControlLeftUI:addEventListener('touch', moveCalc)

	Controls.ControlDownUI = display.newImageRect(UIGroup, 'Sprites/UI/joyup.png',
			133, 186)
	Controls.ControlDownUI:scale(0.3, 0.3)
	Controls.ControlDownUI:rotate(180)
	Controls.ControlDownUI.x = display.contentCenterX - 220
	Controls.ControlDownUI.y = display.contentCenterY + 130
	Controls.ControlDownUI.alpha = 0.6
	Controls.ControlDownUI:addEventListener('touch', moveCalc)

	Controls.ControlRightUI = display.newImageRect(UIGroup,
			'Sprites/UI/joyright.png', 170, 134)
	Controls.ControlRightUI:scale(0.3, 0.3)
	Controls.ControlRightUI.x = display.contentCenterX - 190
	Controls.ControlRightUI.y = display.contentCenterY + 105
	Controls.ControlRightUI.alpha = 0.6
	Controls.ControlRightUI:addEventListener('touch', moveCalc)

	--create player and it's movements
	local sheetOptions = 	{
		width = 64,
		height = 64,
		numFrames = 126
	}
	local SpriteSheet = graphics.
			newImageSheet('Sprites/Player/Char_3_No_Armor.png', sheetOptions)
	local Sequences = {
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
			time = 500,
			loopCount = 1,
		},
		{
			name = 'kick',
			frames = {46, 47},
			time = 800,
			loopCount = 1,
		},
		{
			name = 'punched',
			frames = {58},
			time = 300,
			loopCount = 1,
		},
		{
			name = 'death',
			frames = {60, 62},
			time = 300,
			loopCount = 1,
		},
		{
			name = 'special',
			frames = {82, 83, 84, 85},
			time = 500,
			loopCount = 1,
		},
	}

	Player = display.newSprite(MainGroup, SpriteSheet, Sequences)
	Player.x = display.contentCenterX - 200
	Player.y = display.contentCenterY + 110
	Player.health = 100
	Player.isDead = false
	Player.isPlayer = true
	Player.canAttack = true
	Player:addEventListener('sprite', endAttackAnimation)
	Player.SpriteSheet = SpriteSheet
	Player.Sequences = Sequences
	Player:scale(1.21, 1.2)

	spawnEnemies()
end

function scene:show(event)
	if (event.phase == 'did') then
		local beginsplash = display.newImageRect(UIGroup, 'Sprites/UI/begin.png', 632, 168)
		beginsplash.x = display.contentCenterX - 400
		beginsplash.y = 150
		beginsplash:scale(0.6, 0.6)
		transition.to(beginsplash, {time = 300, transtion=easing.inElastic,
			x = display.contentCenterX})
		timer.performWithDelay(2500, function()
			transition.to(beginsplash, {time = 300, transtion=easing.outElastic,
				x = display.contentCenterX + 700})
			end)
		audio.play(Music.Stage1Music, {loops = -1})
		Runtime:addEventListener('enterFrame', move)
		Runtime:addEventListener('enterFrame', checkArea)
		Runtime:addEventListener('enterFrame', checkHealth)
		Runtime:addEventListener('enterFrame', setClosestEnemy)
		Runtime:addEventListener('enterFrame', runAI)
		Runtime:addEventListener('enterFrame', checkAggro)
		Runtime:addEventListener('enterFrame', checkEnemySpawn)
		Runtime:addEventListener('enterFrame', checkLevelEnd)
	end
end

-- -----------------------------------------------------------------------------
-- Event listeners
-- -----------------------------------------------------------------------------
function checkLevelEnd()
	if (Boss ~= nil and Boss.health <= 0 and not LevelEnd) then
		local endsplash = display.newImageRect(UIGroup, 'Sprites/UI/gg.png', 632, 168)
		endsplash.x = display.contentCenterX - 400
		endsplash.y = 150
		endsplash:scale(0.6, 0.6)
		transition.to(endsplash, {time = 300, transtion=easing.inElastic,
			x = display.contentCenterX})
		timer.performWithDelay(2500, function()
			transition.to(endsplash, {time = 300, transtion=easing.outElastic,
				x = display.contentCenterX + 400})
			end)
		timer.performWithDelay(5000, function ()
			composer.gotoScene('menu', {time = 1000, efffect = crossfade})
			end)
		LevelEnd = true
	end
end

function checkEnemySpawn()
	if (AreaCanMove and not BGMove) then
		spawnEnemies()
		spawnBoss()
		AreaCanMove = false
	end
end

function runAI()
	for _, en in pairs(Enemies) do
		if (en.health > 0) then
			en.brain:run()
		end
	end
end

function checkAggro()
	for _, en in pairs(Enemies) do
		if (en.health > 0) then
			if (canSeePlayer(en)) then
				en.isAggro = true
				en.isWandering = false
			else
				en.isAggro = false
			end
		end
	end
end

function checkHealth()
	if (Player.health <= 0 and not Player.isDead) then
		Player:setSequence('death')
		Player:play()
		timer.performWithDelay(2000, function()
			composer.gotoScene('over', {time = 2000, efffect = 'fade'});
		end)
		Player.isDead = true
		return
	end
	for i, en in ipairs(Enemies) do
		if (en.health == 0) then
			en:setSequence('death')
			en:play()
			timer.performWithDelay(1000, function()
				transition.blink(en, {time = 500})
			end)
			timer.performWithDelay(2000, function()
				display.remove(en)
			end)
			table.remove(Enemies, table.indexOf(Enemies, en))
		end
	end
end

function endAttackAnimation(event)
	local obj = event.target
	if (event.phase == 'ended'
			and (obj.sequence == 'punch1' or obj.sequence == 'punched'
						or obj.sequence == 'kick')) then
		obj:pause()
		obj:setSequence('idle')
		obj:play()
	end
end

function attack(event)
	if (not Player.canAttack) then
		return
	end
	Player.canAttack = false
	if (event.target.name == 'punchbutton') then
		Player:setSequence('punch1')
	else
		Player:setSequence('kick')
	end
	Player:play()
	for i, en in ipairs(Enemies) do
		if (en and getDistance(Player.x, Player.y,
				en.x, en.y) <= 40) then
			if (not en.isAggro) then
				en.isAggro = true
			end
			audio.play(SoundFX.punch, {loops = 0, channel = 2})
			en.health = en.health - 10
			if (Player.health + 4 > 100) then
				Player.health = 100
				HealthUI.red.x = display.contentCenterX - 170
				HealthUI.red.width = 0
			else
				Player.health = Player.health + 4
				HealthUI.red.x = HealthUI.red.x + 2
				HealthUI.red.width = HealthUI.red.width - 4
			end
			en:setSequence('punched')
			en:play()
		end
	end
	timer.performWithDelay(500, function() Player.canAttack = true end)
end

function checkArea(event)
	if table.getn(Enemies) > 0 then
			AreaClear = false
		else
			AreaClear = true
		end
end

function move(event)
	if (Player.isDead) then return end
	moveCollisionChecker()
	if (AreaCode < 5) then
		moveBackgroundChecker()
	end
	Player.x = Player.x + SpeedX
	Player.y = Player.y + SpeedY
end

function moveCalc(event)
	Player:setSequence('walk')
	if (event.target == Controls.ControlUpUI) then
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
	elseif (event.target == Controls.ControlDownUI) then
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
	elseif (event.target == Controls.ControlRightUI) then
		if (event.phase == 'began') then
			Player:play()
			Player.xScale = 1
			SpeedX = 1
			SpeedY = 0
			BackgroundSpeed = -1.7
		else
			Player:pause()
			Player:setSequence('idle')
			Player:play()
			SpeedX = 0
			SpeedY = 0
			BackgroundSpeed = 0
		end
	elseif (event.target == Controls.ControlLeftUI) then
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
-- Auxiliar functions
-- -----------------------------------------------------------------------------------
function editPlayableArea()
	local canReset = true

	if (Background[1].x < -350) then
		display.remove(PlayableArea[1])
		display.remove(Background[1])
		table.remove(PlayableArea, 1)
		table.remove(Background, 1)
	end

  --create next screen as the current screen scrolls left
	if (BackgroundSpeed ~= 0) then
		--create the next background sprite
		if (#Background < 3) then
			local aux = display.newImageRect(BackGroup,
					'Sprites/BGs/City2/Bright/City2.png', 1920, 1080)
			if (#Background > 1) then
				aux.x = Background[#Background - 1].x + 570
			else
				aux.x = Background[1].x + 570
			end
			table.insert(Background, aux)
			aux.y = display.contentCenterY
			aux:scale(0.3, 0.3)
		end


		--create the next playable area polygon
		if (#PlayableArea < 3) then
			local auxVert = {}
			local pa
			if (#PlayableArea > 1) then
				pa = PlayableArea[#PlayableArea - 1]
			else
				pa = PlayableArea[1]
			end
			for j = 1, #vertices do
				if (j % 2 ~= 0) then
					auxVert[j] = pa.vertices[j] + 570
				else
					auxVert[j] = pa.vertices[j]
				end
			end
			pa = display.newPolygon(Background[1].x,
				display.contentCenterY, auxVert)
			pa.vertices = auxVert
			pa.alpha = 0
			table.insert(PlayableArea, pa)
		end

		--move all screens
		for i, b in ipairs(Background) do
			b.x = b.x + BackgroundSpeed
		end

		--move the playable area polygons
		for i, pa in ipairs(PlayableArea) do
			auxVert = {}
			for j = 1, #vertices do
				if (j % 2 ~= 0) then
					auxVert[j] = pa.vertices[j] + BackgroundSpeed
				else
					auxVert[j] = pa.vertices[j]
				end
			end
			display.remove(pa)
			table.remove(PlayableArea, i)
			pa = display.newPolygon(Background[i].x,
				display.contentCenterY, auxVert)
			pa.vertices = auxVert
			pa.alpha = 0
			table.insert(PlayableArea, i, pa)
		end
	end
end

function getDistance(obj1X, obj1Y, obj2X, obj2Y)
	return math.sqrt(math.pow((obj1X - obj2X), 2)
		+ math.pow((obj1Y - obj2Y), 2))
end

function isInArea(x, y)
	for i, pa in ipairs(PlayableArea) do
		if (isInAreaAux(x, y, pa)) then
			return true
		end
	end
	return false
end

function isInAreaAux(x, y, area)
	local polyX = {}
	local polyY = {}
	local j = #area.vertices/2
	local result = false
	for i, xy in ipairs(area.vertices) do
		if (i % 2 == 0) then
			table.insert(polyY, xy)
		else
			table.insert(polyX, xy)
		end
	end

	for i = 1, #area.vertices/2 do
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

function moveCollisionChecker()
	if (not isInArea(Player.x, Player.y)) then
		if (SpeedX > 0) then
			Player.x = Player.x - 5
		elseif (SpeedX < 0) then
			Player.x = Player.x + 5
		elseif (SpeedY > 0) then
			Player.y = Player.y - 1
		elseif (SpeedY < 0) then
			Player.y = Player.y + 1
		end
		SpeedX = 0
		BackgroundSpeed = 0
		SpeedY = 0
	end

	if (ClosestEnemy and getDistance(Player.x, Player.y,
			ClosestEnemy.x, ClosestEnemy.y) < 20) then
			if (SpeedX > 0) then
				Player.x = Player.x - 5
			elseif (SpeedX < 0) then
				Player.x = Player.x + 5
			elseif (SpeedY > 0) then
				Player.y = Player.y - 1
			elseif (SpeedY < 0) then
				Player.y = Player.y + 1
			end
		SpeedX = 0
		BackgroundSpeed = 0
		SpeedY = 0
	end
end

function moveBackgroundChecker()
	if (Player.x <= 90) then
		BGMove = false
	elseif (Player.x >= 280 and AreaClear) then
		BGMove = true
		AreaCanMove = true
	end

	if (BGMove) then
		editPlayableArea()
		if (SpeedX > 0) then
			SpeedX = -0.7
		end
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

function canSeePlayer(enemy)
	if (enemy.isAggro) then
		return true
	end
	if (enemy.x > Player.x) then
		if (enemy.xScale == -1) then
			return true
		else
			return false
		end
	elseif (enemy.xScale == 1) then
			return true
		else
			return false
	end
end

function spawnBoss()
	AreaClear = false
	if (AreaCode < 5 and #Enemies > 0) then
		return
	end
	audio.stop(1)
	Music.Stage1Music = audio.loadStream("Sounds/Crewcabanger.mp3")
	audio.play(Music.Stage1Music, {loops = -1})
	Boss = display.newSprite(MainGroup, Player.SpriteSheet, Player.Sequences)
	Boss.x = math.random(Player.x + 200, Player.x + 250)
	Boss.y = math.random(Player.y - 10, Player.y + 10)
	Boss.xScale = -1
	Boss.health = 500
	Boss.isMoving = false
	Boss.canAttack = false
	Boss.canKick = false
	Boss.canSpecial = false
	Boss.isPlayer = false
	Boss.isAggro = true
	Boss:addEventListener('sprite', endAttackAnimation)
	Boss.brain = BT:new({
		object = {name = 'bossbrain'},
		tree = BT.Priority:new({
			nodes = {
				--first node: attack Sequence
				BT.Sequence:new({
					nodes = {
						BT.Task:new({
							run = amAlive,
						}),
						BT.Task:new({
							run = moveToPlayer,
						}),
						BT.Task:new({
							run = attackPlayer,
						}),
					}
				}),
			}
		}),
	})
	Boss.brain:setObject(Boss)
	Boss:scale(1.49, 1.5)
	table.insert(Enemies, Boss)
end

function spawnEnemies()
	if (#Enemies >= 2 or AreaCode > 4) then
		return
	end
	AreaClear = false
	AreaCode = AreaCode + 1
	for i = 0, 2 do
		local Enemy = display.newSprite(MainGroup, Player.SpriteSheet, Player.Sequences)
		Enemy.x = math.random(Player.x + 200, Player.x + 250)
		Enemy.y = math.random(Player.y - 10, Player.y + 10)
		Enemy.xScale = 1
		Enemy.health = 100
		Enemy.isMoving = false
		Enemy.isWandering = false
		Enemy.canAttack = false
		Enemy.isPlayer = false
		Enemy.isAggro = false
		Enemy:scale(1.19, 1.2)
		Enemy:addEventListener('sprite', endAttackAnimation)
		Enemy.brain = BT:new({
			object = {name = 'brain' .. i},
			tree = BT.Priority:new({
				nodes = {
					--first node: wander sequence
					BT.Sequence:new({
						nodes = {
							BT.Task:new({
								run = amAlive,
							}),
							BT.Task:new({
								run = wander,
							}),
						}
					}),
					--second node: attack Sequence
					BT.Sequence:new({
						nodes = {
							BT.Task:new({
								run = moveToPlayer,
							}),
							BT.Task:new({
								run = attackPlayer,
							}),
						}
					}),
				}
			}),
		})
		Enemy.brain:setObject(Enemy)
		table.insert(Enemies, Enemy)
	end
end

-- -----------------------------------------------------------------------------------
-- BT Aux Functions
-- -----------------------------------------------------------------------------------
function attackPlayer(task, args)
	if (Player.isDead) then
		task:fail()
		return
	end
	local opchance = math.random(0, 2)
	if (args.canAttack and args.isAggro and args.sequence ~= 'punched') then
		args.canAttack = false
		if (opchance < 1) then
			args:setSequence('punch1')
		else
			args:setSequence('kick')
		end
		args:play()
		if (args and getDistance(Player.x, Player.y,
				args.x, args.y) <= 25) then
			local damage = math.random(5, 10)
			audio.play(SoundFX.punch, {loops = 0, channel = 3})
			if (Player.health - damage < 0) then
				Player.health = 0
				HealthUI.red.x = display.contentCenterX - 220
				HealthUI.red.width = 100
			else
				Player.health = Player.health - damage
				HealthUI.red.x = HealthUI.red.x - damage/2
				HealthUI.red.width = 100 - Player.health
			end
			Player:setSequence('punched')
			Player:play()
		end
		timer.performWithDelay(1000, function () args.canAttack = true; end)
		task:running()
	else
		task:fail()
	end
end

function amAlive(task, args)
		if (args.health <= 0) then
			task:fail()
		else
			task:success()
		end
	end

function wander(task, args)
		if (args.isAggro) then
			task:fail()
			args.isWandering = false
			return
		end
		if (args.isWandering) then
			task:running()
			return
		end
		args.isWandering = true
		posX = math.random(-30, 30)
		posY = math.random(-30, 30)
		delay = math.random(2000, 10000)
		if (not isInArea(args.x + posX, args.y + posY)) then
			task:fail()
			return
		end
		if (posX < 0) then
			args.xScale = -1
		else
			args.xScale = 1
		end
		transition.to(args,
			{time = 1000, y = posY, x = posX, delta = true, onComplete =
			function()
				if (args) then
				args:pause(); args:setSequence('idle'); args:play();
				tasktimer = timer.performWithDelay(delay, function ()
					args.isWandering = false; end); args.isMoving = false;
				end
			end,
			onStart = function()
				if (args) then
					args:pause(); args:setSequence('walk'); args:play();
					args.isWandering = true; args.isMoving = true;
				end
			end})
			task:running()
			return
	end

function moveToPlayer(task, args)
		if (not args.isAggro or Player.isDead) then
			task:fail()
			return
		end
		if (getDistance(Player.x, Player.y, args.x, args.y) <= 25) then
			transition.cancel(args)
			if (args.sequence == 'walk') then
				args:pause(); args:setSequence('idle'); args:play();
			end
			args.isMoving = false
			task:success()
			return
		elseif (args.isMoving) then
			task:running()
			return
		end
		deltax = math.random(-10, 10)
		deltay = math.random(-10, 10)
		if (Player.x < args.x) then
			args.xScale = -1
		else
			args.xScale = 1
		end
		transition.to(args, {time = 5000, x = Player.x + deltax, y = Player.y + deltay,
			onCancel = function()
				if (args) then
					args:pause(); args:setSequence('idle'); args:play();
					args.isMoving = false; args.canAttack = true; task:success();
				end
			end,
			onComplete = function()
				if (args) then
					args:pause(); args:setSequence('idle'); args:play();
					args.isMoving = false; args.canAttack = true; task:success();
				end
			end,
			onStart = function()
				if (args) then
					args:pause(); args:setSequence('walk'); args:play();
					args.isMoving = true; task:running();
				end
			end})
	end

function scene:destroy( event )
	local sceneGroup = self.view
	Runtime:removeEventListener('enterFrame', move)
	Runtime:removeEventListener('enterFrame', checkArea)
	Runtime:removeEventListener('enterFrame', checkHealth)
	Runtime:removeEventListener('enterFrame', setClosestEnemy)
	Runtime:removeEventListener('enterFrame', runAI)
	Runtime:removeEventListener('enterFrame', checkAggro)
	Runtime:removeEventListener('enterFrame', checkEnemySpawn)
	Runtime:removeEventListener('enterFrame', checkLevelEnd)
	scene:removeEventListener('create', scene )
	scene:removeEventListener('show', scene )
	scene:removeEventListener('hide', scene )
	scene:removeEventListener('destroy', scene )
end

function scene:hide(event)
	if (event.phase == 'did') then
		audio.stop(1)
		audio.dispose(Music.Stage1Music)
		audio.dispose(SoundFX.punch)
		composer.removeScene('stage1')
	end
end

-- -----------------------------------------------------------------------------------
-- Scene event function listeners
-- -----------------------------------------------------------------------------------
scene:addEventListener('create', scene )
scene:addEventListener('show', scene )
scene:addEventListener('hide', scene )
scene:addEventListener('destroy', scene )

--------------------------------------------------------------------------------------
return scene

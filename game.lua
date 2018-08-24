--[[

  GAME ENGINE
    Logic

--]]

local MapDir = '/maps/'
local curObj = nil

-- FOR TESTING
local debug = true

game = {}

t_map = 
{
    ['name'] = '',
    ['img'] = '',
    ['path'] = {},
    ['area'] = {}
}

local winX, winY = love.graphics.getWidth(), love.graphics.getHeight()

function game.loadMap(imageMap, mapName)
  local imgSize, mapData, data
  
  t_map.name = mapName
  t_map.img = gui.createImage(0, 0, imageMap)
  imgSize = t_map.img:getSize()
  t_map.img:setScale(winX/imgSize[1], winY/imgSize[2]) -- let map fill the whole screen
  
  
  
  -- Get Path and area and insert into table
  mapData = loadMapData(MapDir .. mapName:sub(1, #mapName-3) .. 'homie')
  if mapData then
    data = string.split(mapData, '/')
    data[1] = string.split(data[1], '_')
    
    for k, path in ipairs(data[1]) do
      data[1][k] = string.split(path, '|')
      local p = {}
      for v, node in ipairs(data[1][k]) do
        node = string.split(node, ',')
        table.insert(p, {x = tonumber(node[1]), y = tonumber(node[2])})
      end
      table.insert(t_map.path, p)
    end
    
    data[2] = string.split(data[2], '_')
    
    for t, area in ipairs(data[2]) do
      data[2][t] = string.split(area, '|')
      local a = {}
      for v, node in ipairs(data[2][t]) do
        node = string.split(node, ',')
        table.insert(a, {x = tonumber(node[1]), y = tonumber(node[2])})
      end
      table.insert(t_map.area, a)
    end
  else
    print(mapName .. ':' .. 'Missing MapData')
  end
  
  -- Create bg Music
  sounds.game_bg:setVolume(sounds.volume)
  sounds.game_bg:setLooping(true)
  sounds.game_bg:play()
  
  -- load default settings, and register gameCallBacks
  gameObj = {towers = {}, enemies = {}, enemyQueue = {}, hud = {}, menu = {}, projectiles = {}, upgradeMenu = {}}
  gameVar = {lives = 1, cash = 100, wave = 0, spawnTick = 0, enemyCounter = 0}
  
  -- load hud
  gameObj.hud = hud_createHUD()
  gameObj.hud:setCash(gameVar.cash)
  gameObj.hud:setHealth(gameVar.lives)
  gameObj.hud:setCurWave(gameVar.wave)
  local mapName = t_map.name:sub(1, #t_map.name-4):lower()
  local maxWaves = level_get_max_waves(mapName)
  gameObj.hud:setMaxWave(maxWaves)
  
  -- load tower menu
  gameObj.menu = create_towerMenu()
  
  -- registerCallBacks
  registerGameCallBack('keypressed', 'game_do_keyPressed')
  registerGameCallBack('mousepressed', 'game_do_mousepressed')
  registerGameCallBack('draw', 'game_do_draw')
  
  return true
  
end

--[[

  Tower Logic

--]]

function gameCreateTower(x, y, strTower)
  -- Check if enough funds.
  local cash = gameObj.hud:getCash()
  local towerCost = Towers[strTower].cost
  if cash >= towerCost and curObj == nil then
    gameObj.hud:setCash(cash-towerCost)
    local tower = create_tower(strTower)
    tower.canSet   = false
    
    table.insert(gameObj.towers, tower)
    curObj = tower
    
    tower:setPosition(x, y)
    tower:setClickHandler('tower_click')
    
    --register handlers
    registerGameCallBack('update', 'tower_place_update')
    registerGameCallBack('mousepressed', 'tower_place_mousepressed')
    
    --deregisterGameCallBacks
    deregisterGameCallBack('mousepressed', 'game_do_mousepressed')
  else
    -- print error for user, not enough funds
  end
  
  return true
end

function tower_place_update()
  local mx, my = love.mouse.getPosition()
  
  curObj:setPosition(mx, my)
  curObj.canAttack = false
  
  -- check if tower is inside deploy area
  for k, poly in ipairs(t_map.area) do
    if (isPointInsidePolygon(curObj.bbox[1], curObj.bbox[2], poly)) and (isPointInsidePolygon(curObj.bbox[3], curObj.bbox[4], poly)) and (isPointInsidePolygon(curObj.bbox[5], curObj.bbox[6], poly)) and (isPointInsidePolygon(curObj.bbox[7], curObj.bbox[8], poly)) then
      curObj.rangeColor = setAlphaInTable(Colors.green, 0.2)
      curObj.canSet = true
      break
    else
      curObj.canSet = false
      curObj.rangeColor = setAlphaInTable(Colors.red, 0.2)
    end
  end
  
  -- check to see if towers hit any other towers
  for k, tower in ipairs(gameObj.towers) do
    if curObj ~= tower then
      if (CheckCollision(curObj.x, curObj.y, curObj.w, curObj.h, tower.x, tower.y, tower.w, tower.h)) then
        curObj.canSet = false
        curObj.rangeColor = setAlphaInTable(Colors.red, 0.2)
      end
    end
  end
end

function tower_place_mousepressed(intX, intY, strButton)
  -- if tower can be set set it, and deregister the events
  if strButton == 1 then 
    if curObj.canSet == true then
      deregisterGameCallBack('update', 'tower_place_update')
      deregisterGameCallBack('mousepressed', 'tower_place_mousepressed')
      registerGameCallBack('mousepressed', 'game_do_mousepressed')
      curObj.canAttack = true
    end
  elseif strButton == 2 then
    
    -- else destroy tower and get cash back
    local cash = gameObj.hud:getCash()
    local towerCost = Towers[curObj.towerType].cost
    local cashBack = cash + towerCost
    
    gameObj.hud:setCash(cashBack)
    tower_destroy(curObj)
    
    deregisterGameCallBack('update', 'tower_place_update')
    deregisterGameCallBack('mousepressed', 'tower_place_mousepressed')
    registerGameCallBack('mousepressed', 'game_do_mousepressed')
  end
end

function tower_destroy(towerObj)
  for k, tower in ipairs(gameObj.towers) do
    if tower == towerObj then
      table.remove(gameObj.towers, k)
      curObj = nil
      return true
    end
  end
end

-- activated when clicking on tower
function tower_click(tower, strButton)
  if strButton == 1 then
    if not curObj then
      curObj = tower
      
      -- Open upgrade menu
      tower_openUpgradeMenu(curObj)
    end
  end
  
  return true
end

function tower_openUpgradeMenu(tower)
  local mx, my = love.mouse.getPosition()
  local sizeX, sizeY = 150, 250
  local pos = {0, love.graphics.getHeight() - sizeY}
  
  local t_inf = Towers[tower.towerType]
  
  gameObj.upgradeMenu['rectangle']  = gui.createRectangle(pos[1], pos[2], sizeX, sizeY, Colors.grey)
  gameObj.upgradeMenu['text']       = gui.createLabel(pos[1], pos[2], string.format('%s\n\nDesc:%s\n\nRPS: %s\n\nDmg: %s', t_inf.name, t_inf.description, t_inf.rps, t_inf.damage), Colors.white, 'Maps')
  gameObj.upgradeMenu['text']:setWrapLimit(90)
  gameObj.upgradeMenu['sellBtn']  = gui.createButton(pos[1] + 5, (pos[2] + sizeY) - 25, (sizeX/2)-10, 20, 'Sell', Colors.lightGrey, Colors.white, 'TowerMenu')
  gameObj.upgradeMenu['sellBtn']:setClickHandler('tower_sellBtnClick')
  gameObj.upgradeMenu['upgradeBtn'] = gui.createButton(pos[1] + 10 + 70, (pos[2] + sizeY) - 25, (sizeX/2)-10, 20, 'Upragde', Colors.lightGrey, Colors.white, 'TowerMenu')
  gameObj.upgradeMenu['upgradeBtn']:setClickHandler('tower_upgradeBtnClick')
end

function tower_upgradeBtnClick()
  -- check found if, if user have enough upgrade, else give error
  local curCash = gameObj.hud:getCash()
  if (Towers[curObj.towerType .. curObj.level+1]) then
    if (curCash >= Towers[curObj.towerType .. curObj.level+1].cost) then
      local oldTower = curObj
      local newTower = create_tower(curObj.towerType .. curObj.level+1)
      newTower.level = newTower.level + 1
      local costForNew = Towers[curObj.towerType .. curObj.level+1].cost
      local pay = curCash - costForNew
      
      gameObj.hud:setCash(pay)
      
      table.insert(gameObj.towers, newTower)
      
      newTower:setPosition(oldTower.x, oldTower.y)
      newTower:setClickHandler('tower_click')
      newTower.canAttack = true
      
      tower_destroy(curObj) -- destroy tower
      tower_destroyUpgradeMenu() -- destroy menu
      
      -- play click sound
      sounds.click:setVolume(sounds.volume)
      sounds.click:play()
      
      return true
    end
  end
  
  return false
end

function tower_sellBtnClick()
  -- check what the tower cost, and get 80%, and destroy menu
  local curCash = gameObj.hud:getCash()
  local cashBack = curCash + (Towers[curObj.towerType].cost)*0.8
  tower_destroy(curObj) -- destroy tower
  gameObj.hud:setCash(cashBack)
  tower_destroyUpgradeMenu()
  
  -- play click sound
  sounds.click:setVolume(sounds.volume)
  sounds.click:play()
  
  return true
end


function tower_destroyUpgradeMenu()
  for k ,menu in pairs(gameObj.upgradeMenu) do
    menu:destroy()
    gameObj.upgradeMenu[k] = nil
  end
end

function tower_attackEnemies_update(dt)
  for k, tower in ipairs(gameObj.towers) do
  -- get target if tower have none
    tower.target = tower:getTarget(gameObj.enemies) or nil
    -- rotate to target
    if tower.target then
      tower:setRotation(get2dAngle(tower.x, tower.y, tower.target.x, tower.target.y))
      if tower.canAttack then
        tower:attack(tower.target)
      end
    end
  end
  -- get Projectiles to fly if hits target, targets lose health
  for k, projectile in ipairs(gameObj.projectiles) do
    projectile:getToTarget(dt)
    if CheckCollision(projectile.x, projectile.y, projectile.w, projectile.h, projectile.target.x, projectile.target.y, projectile.target.w/2, projectile.target.h/2) then
      table.remove(gameObj.projectiles, k)
      projectile.target.health = projectile.target.health - projectile.damage
    end
  end
end

--[[

  Enemy Logic

--]]

function gameQueueEnemies()
  -- get startNode and mapName and look for next wave
  local mapName = t_map.name:sub(1, #t_map.name-4):lower()
  
  local curWave = gameObj.hud:getCurWave()
  local nextWave = Level[mapName][curWave+1]
  
  -- Queue enemies to get spawned
  
  for i=0, nextWave.amount-1 do
    local obj = {}
    obj.enemy = nextWave.enemyType
    obj.interval = nextWave.interval
    table.insert(gameObj.enemyQueue, obj)
    gameVar.enemyCounter = gameVar.enemyCounter + 1
  end
  
  return true
end

function gameSpawnEnemies_update(dt)
  local startX, startY = t_map.path[1][1].x, t_map.path[1][1].y
  -- spawn after delay
  local tick = getTime()
  if next(gameObj.enemyQueue) ~= nil then
    local curEnemy = gameObj.enemyQueue[1]
    if ((tick - gameVar.spawnTick) >= curEnemy.interval) then
      local enemy = create_enemy(curEnemy.enemy)
      table.insert(gameObj.enemies, enemy)
      enemy:setPosition(startX, startY)
      table.remove(gameObj.enemyQueue, 1)
      gameVar.spawnTick = tick
    end
  else
    deregisterGameCallBack('update', 'gameSpawnEnemies_update')
  end
end

function gameEnemiesMove_update(dt)
  for k, enemy in ipairs(gameObj.enemies) do
    if enemy.node ~= table.getn(t_map.path[1]) then
      local enemyNode = enemy.node
      local curNode = t_map.path[1][enemyNode]
      local nextNode = t_map.path[1][enemyNode + 1]
      local speed = t_enemies[enemy.enemyType].speed
      local nodeDistance = get2dDistance(curNode.x, curNode.y, nextNode.x, nextNode.y)
      
      -- Get distance in time, pixels pr frame
      local pathTime = nodeDistance / speed
      
      -- Get progress for enemy in time
      enemy.t = enemy.t + dt / pathTime
      enemy.t = math.min(enemy.t, 1)
      
      -- Get where the enemy is on the line, by calculating how much time have passed
      local enemyX = curNode.x + (nextNode.x - curNode.x) * enemy.t
      local enemyY = curNode.y + (nextNode.y - curNode.y) * enemy.t
      
      -- and place enemy
      enemy:setPosition(enemyX, enemyY)
      
      -- get rotation and set
      local rot = get2dAngle(curNode.x,curNode.y, nextNode.x, nextNode.y)
      enemy:setRotation(rot)
      
      -- Check if enemy has reached destination if it has set next node
      if enemy.t == 1 then
        enemy.node = enemy.node + 1
        enemy.t = 0
      end
      
      -- check and see if enemies are dead if they are get money
      if enemy.health <= 0 then
        table.remove(gameObj.enemies, k)
        local curCash = gameObj.hud:getCash()
        curCash = curCash + enemy:getCashBack()
        gameObj.hud:setCash(curCash)
        gameVar.enemyCounter = gameVar.enemyCounter -1
      end
    
    else
      -- If enemy reaches the end, then check if last health or else lose 1 life
      if gameVar.lives ~= 1 then
        -- remove enemy and lose 1 health
        table.remove(gameObj.enemies, k)
        gameVar.lives = gameVar.lives - 1
        gameObj.hud:setHealth(gameVar.lives)
        gameVar.enemyCounter = gameVar.enemyCounter - 1
      else
        game_do_lost()
      end
    end
  end
  -- if there is no more enemies deregister event
  if (next(gameObj.enemies) == nil and gameVar.enemyCounter == 0) then
    gameObj.hud:HideReady(false)
    gameObj.projectiles = {}
    deregisterGameCallBack('update', 'gameEnemiesMove_update')
    deregisterGameCallBack('update', 'tower_attackEnemies_update')
  end
end


--[[

  HANDLERS

--]]

--DRAW
function game_do_draw()
  if gameObj then
    
    -- DRAW TOWERS
    
    for _, tower in ipairs(gameObj.towers) do
      love.graphics.setColor(Colors.white)
      love.graphics.draw(tower.imgBase, tower.x, tower.y, 0, tower.scaleX, tower.scaleY, tower.w/2, tower.h/2)
      love.graphics.draw(tower.imgTop, tower.x, tower.y, tower.rot, tower.scaleX, tower.scaleY, tower.w/2, tower.h/2)
      if curObj == tower then
        -- Draw Tower Range
        love.graphics.setColor(tower.rangeColor)
        love.graphics.circle('fill', tower.x, tower.y, Towers[tower.towerType].range)
        if debug then
          love.graphics.setColor(setAlphaInTable(Colors.white, 0.1))
          love.graphics.rectangle('fill', tower.bbox[1], tower.bbox[2], tower.bbox[3]-tower.bbox[1], tower.bbox[4]-tower.bbox[2]) -- SEE HITBOXES FOR TOWERS; JUST TESTING
        end
      end
    end
  
  -- DRAW ENEMIES
  
    for _, enemies in ipairs(gameObj.enemies) do
      love.graphics.setColor(Colors.white)
      love.graphics.draw(enemies.skin, enemies.x, enemies.y, enemies.rot, enemies.scaleX, enemies.scaleY, enemies.w/2, enemies.h/2)
      -- TEST DRAW enemies hitboxes
      if debug then
        love.graphics.setColor(setAlphaInTable(Colors.white, 0.2))
        love.graphics.rectangle('fill', enemies.bbox[1], enemies.bbox[2], enemies.bbox[3]-enemies.bbox[1], enemies.bbox[4] - enemies.bbox[2])
      end
      
    end
  end

  
  -- DRAW PROJECTILES
  for _, projectiles in ipairs(gameObj.projectiles) do
    projectiles:render()
  end
  
end



--MOUSE PRESSED

function game_do_mousepressed(intX, intY, strButton)  
  -- Tower Click Handler
  if gameObj then
    for _, tower in ipairs(gameObj.towers) do
      if tower.clickHandler then
        if (isPointInsideBox(intX, intY, unpack(tower.bbox))) then
          return _G[tower.clickHandler](tower, strButton, intX, intY)
        else
          tower_destroyUpgradeMenu()
          curObj = nil
        end
      end
    end
  end
  
end

-- Keyboard pressed
function game_do_keyPressed(key, scanCode, isKeyRepeat)
  -- check if a wave is in progress
  if key == 'space' then
    if next(gameObj.enemies) == nil and gameVar.enemyCounter == 0 then
      
      -- check if not current wave is last
      local curWave = gameObj.hud:getCurWave()
      local lastWave = gameObj.hud:getMaxWaves()
      
      if curWave ~= lastWave then
        -- queue and spawn enemies
        gameQueueEnemies()
        
        -- Register Game Logic
        registerGameCallBack('update', 'gameSpawnEnemies_update')
        registerGameCallBack('update', 'gameEnemiesMove_update')
        registerGameCallBack('update', 'tower_attackEnemies_update')
        
        gameVar.wave = curWave + 1
        gameObj.hud:setCurWave(gameVar.wave)
        -- hide ready label
        gameObj.hud:HideReady(true)
        
      end
    end
  end
end

-- Games lost, reset everything and go to menu
function game_do_lost()
    -- Deregister update functions
    deregisterGameCallBack('update', 'gameSpawnEnemies_update')
    deregisterGameCallBack('update', 'gameEnemiesMove_update')
    deregisterGameCallBack('update', 'tower_attackEnemies_update')
  
    gameObj.hud:setText("You Lost!")
    gameObj.towers, gameObj.enemies, gameObj.enemyQueue, gameObj.menu, gameObj.projectiles, upgradeMenu = {}, {}, {}, {}, {}
    gameVar = {lives = 1, cash = 100, wave = 0, spawnTick = 0, enemyCounter = 0}
    gameVar.enemyCounter = 0
    
    -- deregister Game Event Logic
    deregisterGameCallBack('draw', 'game_do_draw')
    deregisterGameCallBack('keypressed', 'game_do_keyPressed')
    deregisterGameCallBack('mousepressed', 'game_do_mousepressed')
    
    -- Destroy all gui objects
    gui_remove_all()
    
    -- Go to Main Menu
    menu.main.create()
    
end
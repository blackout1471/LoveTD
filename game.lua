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
  
  -- load default settings, and register gameCallBacks
  gameObj = {towers = {}, enemies = {}, hud = {}, menu = {}}
  gameVar = {lives = 100, cash = 100, wave = 0}
  
  -- load hud
  gameObj.hud = hud_createHUD()
  gameObj.hud:setCash(gameVar.cash)
  gameObj.hud:setHealth(gameVar.lives)
  gameObj.hud:setCurWave(gameVar.wave)
  
  -- load tower menu
  gameObj.menu = create_towerMenu()
  
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
end

function tower_place_mousepressed(intX, intY, strButton)
  -- if tower can be set set it, and deregister the events
  if strButton == 1 then 
    if curObj.canSet == true then
      deregisterGameCallBack('update', 'tower_place_update')
      deregisterGameCallBack('mousepressed', 'tower_place_mousepressed')
      registerGameCallBack('mousepressed', 'game_do_mousepressed')
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
    end
  end
  
  return true
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
end
registerGameCallBack('draw', 'game_do_draw')



--MOUSE PRESSED

function game_do_mousepressed(intX, intY, strButton)  
  -- Tower Click Handler
  if gameObj then
    for _, tower in ipairs(gameObj.towers) do
      if tower.clickHandler then
        if (isPointInsideBox(intX, intY, unpack(tower.bbox))) then
          return _G[tower.clickHandler](tower, strButton, intX, intY)
        else
          curObj = nil
        end
      end
    end
  end
  
end
registerGameCallBack('mousepressed', 'game_do_mousepressed')
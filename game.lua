--[[

  GAME ENGINE
    Logic

--]]

local MapDir = '/maps/'
local curObj = nil

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

function gameCreateTower(x, y, strTower)
  -- Check if enough funds.
  local cash = gameObj.hud:getCash()
  local towerCost = Towers[strTower].cost
  if cash >= towerCost and curObj == nil then
    gameObj.hud:setCash(cash-towerCost)
    local tower = create_tower(strTower)
    tower.isPlaced = false
    tower.canSet   = false
    
    table.insert(gameObj.towers, tower)
    curObj = tower
    
    tower:setPosition(x, y)
    tower:setClickHandler('tower_click')
  else
    -- print error for user, not enough funds
  end
  
  return true
end

function tower_click(tower)
  curObj = tower
  print('clicked')
end

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
        love.graphics.setColor(setAlphaInTable(Colors.white, 0.1))
        love.graphics.rectangle('fill', tower.bbox[1], tower.bbox[2], tower.bbox[3]-tower.bbox[1], tower.bbox[4]-tower.bbox[2])
      end
    end
  end
  
  -- DRAW ENEMIES
  
  -- DRAW PROJECTILES
end
registerGameCallBack('draw', 'game_do_draw')

-- GAME UPDATE

function game_do_update()
  local mx, my = love.mouse.getPosition()
  
  if gameObj then
    
    -- TOWERS
    for k, tower in ipairs(gameObj.towers) do
      if tower.isPlaced == false then
        tower:setPosition(mx, my)
        
        -- Check if tower is inside the deploy area
        for k, poly in ipairs(t_map.area) do
          if (isPointInsidePolygon(tower.bbox[1], tower.bbox[2], poly)) and (isPointInsidePolygon(tower.bbox[3], tower.bbox[4], poly)) then
            tower.rangeColor = setAlphaInTable(Colors.green, 0.2)
            tower.canSet = true
            break
          else
            tower.canSet = false
            tower.rangeColor = setAlphaInTable(Colors.red, 0.2)
          end
        end
      end
    end
    
    -- Enemies
    -- projectiles
  end
end
registerGameCallBack('update', 'game_do_update')

-- GAME MOUSEPRESSED

function game_do_mousepressed(intX, intY, strButton)
  -- Towers
  if strButton == 1 then
    if curObj then
      -- Check if tower can be set
      if curObj.canSet == true and curObj.isPlaced == false then
        curObj.isPlaced = true
        curObj = nil
      end
    end
  end
  
  -- Tower Click Handler
  if gameObj then
    for _, tower in ipairs(gameObj.towers) do
      if tower.clickHandler then
        if (isPointInsideBox(intX, intY, unpack(tower.bbox))) then
          return _G[tower.clickHandler](tower, strButton, intX, intY)
        end
      end
    end
  end
  
end
registerGameCallBack('mousepressed', 'game_do_mousepressed')
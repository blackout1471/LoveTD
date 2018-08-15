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
  -- load gameCallBacks
  registerAllTowerHandlers()
  
  --TEST
  gameObj.menu = tower_createTower_menu(winX, 0)
end
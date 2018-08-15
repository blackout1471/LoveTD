nav = {buttons = {}, images = {}, labels = {}, rectangles = {}, lines = {}}
varMap = nil
paths = {}
areas  = {}

local winY, winX = love.graphics.getHeight(), love.graphics.getWidth()
local size, realSize = 10, 200
local buttonSize = {75, 40}

function loadMap(map, mapName)
  varMap = gui.createImage(0, 0, map)
  
  curMapName = mapName
  
  local data = loadMapData(curMapName:sub(1,#curMapName-3) .. 'homie')
  
  if data then
    data = string.split(data, '/')
    data[1] = string.split(data[1], '_')
    for k, path in ipairs(data[1]) do
      data[1][k] = string.split(path, '|')
      for t, node in ipairs(data[1][k]) do
        node = string.split(node, ',')
        if t == 1 then
          createFirstPath(tonumber(node[1]), tonumber(node[2]))
        else
          createPathNode(tonumber(node[1]), tonumber(node[2]))
        end
      end
    end
    data[2] = string.split(data[2], '_')
    for k, area in ipairs(data[2]) do
      data[2][k] = string.split(area, '|')
      for t, node in ipairs(data[2][k]) do
        node = string.split(node, ',')
        if t == 1 then
          createFirstArea(tonumber(node[1]), tonumber(node[2]))
        else
          createAreaNode(tonumber(node[1]), tonumber(node[2]))
        end
      end
    end
  end
  
  point_clickHandler(0, 0, 1)
  point_clickHandler(0, 0, 2)
  
  nav.create()
end

function nav.create()
  nav.rectangles['sideMenu'] = gui.createRectangle(winX-size, 0, size, winY, Colors.lightGrey)
  nav.rectangles['sideMenu']:setHoverHandler('nav_sideMenuHoverEnter', 'nav_sideMenuHoverExit')
  
  nav.buttons['cordDeploy'] = gui.createButton((winX-realSize) + buttonSize[1] + 40, 25, buttonSize[1], buttonSize[2], 'Area', {0.7, 0.7, 0.7, 1}, Colors.white, 'Maps')
  nav.buttons['cordDeploy']:setHidden(true)
  nav.buttons['cordDeploy']:setClickHandler('createFirstArea_mouse')
  
  nav.buttons['cordStart'] = gui.createButton((winX-realSize) + 20, 25, buttonSize[1], buttonSize[2], 'Path', {0.7, 0.7, 0.7, 1}, Colors.white, 'Maps')
  nav.buttons['cordStart']:setHidden(true)
  nav.buttons['cordStart']:setClickHandler('createFirstPath_mouse')
  
  nav.buttons['saveMap'] = gui.createButton((winX-realSize)+buttonSize[1], winY-100, buttonSize[1], buttonSize[2], 'Save', Colors.lightGrey, Colors.white, 'Maps')
  nav.buttons['saveMap']:setHidden(true)
  nav.buttons['saveMap']:setClickHandler('writeMapData')
end

function createFirstArea(x, y)
  local area = {}
  table.insert(area, point.createArea(x, y, 5, Colors.white, #areas+1, true))
  table.insert(areas, area)
  areas[#areas][1]:setObject()
  areas[#areas][1]:setClickHandler('createAreaNode_mouse')
end

function createFirstArea_mouse()
  local mx, my = love.mouse.getPosition()
  createFirstArea(mx, my)
end

function createAreaNode(x, y)
  table.insert(areas[#areas], point.createArea(x, y, 5, Colors.white, #areas, false))
  areas[#areas][#areas[#areas]]:setObject()
  areas[#areas][#areas[#areas]]:setClickHandler('createAreaNode_mouse')
end

function createAreaNode_mouse()
  local mx, my = love.mouse.getPosition()
  createAreaNode(mx, my)
end

function createFirstPath(x, y)
  local t_path = {}
  table.insert(t_path, point.createPath(x, y, 5, Colors.green, #paths+1, true))
  table.insert(paths, t_path)
  paths[#paths][1]:setObject()
  paths[#paths][1]:setClickHandler('createPathNode_mouse')
end

function createFirstPath_mouse()
  local mx, my = love.mouse.getPosition()
  createFirstPath(mx, my)
end

function createPathNode(x, y)
  table.insert(paths[#paths], point.createPath(x, y, 5, Colors.blue, #paths, false))
  paths[#paths][#paths[#paths]]:setObject()
  paths[#paths][#paths[#paths]]:setClickHandler('createPathNode_mouse')
end

function createPathNode_mouse()
  local mx, my = love.mouse.getPosition()
  createPathNode(mx, my)
end

function nav_sideMenuHoverEnter(rect)
  rect:setPosition(winX-realSize, 0)
  rect:setSize(realSize, winY)
  rect:setColor(Colors.grey)
  nav.buttons['cordStart']:setHidden(false)
  nav.buttons['cordDeploy']:setHidden(false)
  nav.buttons['saveMap']:setHidden(false)
end

function nav_sideMenuHoverExit(rect)
  rect:setPosition(winX-size, 0)
  rect:setSize(size, winY)
  rect:setColor(Colors.lightGrey)
  nav.buttons['cordStart']:setHidden(true)
  nav.buttons['cordDeploy']:setHidden(true)
  nav.buttons['saveMap']:setHidden(true)
end

function mapNodes_draw()
  for k, path in ipairs(paths) do
    for i, node in ipairs(path) do
      if i < #path then
        local nextNode = path[i+1]
        love.graphics.setColor(unpack(Colors.white))
        love.graphics.setLineWidth(2)
        love.graphics.line(node.x, node.y, nextNode.x, nextNode.y)
      end
    end
  end
  for k, area in ipairs(areas) do
    for i, node in ipairs(area) do
      local prevNode = i - 1
      if prevNode < 1 then
        prevNode = #area
      end
      prevNode = area[prevNode]
      love.graphics.setColor(unpack(Colors.white))
      love.graphics.setLineWidth(2)
      love.graphics.line(node.x, node.y, prevNode.x, prevNode.y)
    end
  end
end
registerGameCallBack('draw', 'mapNodes_draw')
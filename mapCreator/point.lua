--[[

    Map Creator Library

--]]

point = 
{
  
  area    = {},
  path    = {},
  generic = {},
  objects = {}
  
}

local pointGeneric_mt = {__index = function(t,k) return point.generic[k] end}
setmetatable(point.area, pointGeneric_mt)
setmetatable(point.path, pointGeneric_mt)

local function create(obj)
  setmetatable(obj, {__index = function(t,k) return point[obj.pointType][k] end})
  table.insert(point.objects, obj)
  
  return obj
end

local curObject

local function getAreaGroup(intGroup)
  local group = {}
  for k, area in ipairs(point.area) do
    if area.group == intGroup then
      table.insert(group)
    end
  end
  
  return group
end

local function getPathGroup()
  local group = {}
  for _, path in ipairs(point.objects) do
    if path.pointType == 'path' then
      table.insert(group, path)
    end
  end
  return group
end

--[[

  Point

--]]

function point.createPath(intX, intY, intRad, t_color, intGroup, bStart)
  local obj       = {}
  obj.pointType   = 'path'
  obj.x           = intX
  obj.y           = intY
  obj.rad         = intRad
  obj.color       = t_color
  obj.group       = intGroup
  obj.set         = false
  obj.start       = bStart
  obj.bgCirc      = gui.createCircle(obj.x, obj.y, obj.rad+2, {0,0,0,0.8})
  obj.fgCirc      = gui.createCircle(obj.x, obj.y, obj.rad, obj.color)
  obj.bbox        = {obj.x-obj.rad, obj.y-obj.rad, obj.x+obj.rad, obj.y+obj.rad}
  
  return create(obj)
end

function point.path:setStart(bool)
  self.start = bool
  
  return true
end

--[[

  Area

--]]

function point.createArea(intX, intY, intRad, t_color, intGroup, bStart)
  local obj     = {}
  obj.pointType = 'area'
  obj.x         = intX
  obj.y         = intY
  obj.rad       = intRad
  obj.color     = t_color
  obj.set       = false
  obj.start     = bStart
  obj.bgCirc    = gui.createCircle(obj.x, obj.y, obj.rad+2, {0,0,0,0.8})
  obj.fgCirc    = gui.createCircle(obj.x, obj.y, obj.rad, obj.color)
  obj.group     = intGroup
  obj.bbox      = {obj.x-obj.rad, obj.y-obj.rad, obj.x+obj.rad, obj.y+obj.rad}
  
  return create(obj)
end

function point.area:setStart(bool)
  self.start = bool
  
  return true
end

function point.area:setGroup(intGroup)
  self.group = intGroup
  
  return true
end


--[[

  GENERIC

--]]

function point.generic:destroy()
  if curObject == self then
    curObject = nil
  end
  
  for k, poin in ipairs(point.objects) do
    if poin == self then
      self.fgCirc:destroy()
      self.bgCirc:destroy()
      table.remove(point.objects, k)
      break
    end
  end
  
  if self.pointType == 'path' then
    for k, node in ipairs(paths[self.group]) do
      if node == self then
        table.remove(paths[self.group], k)
        break
      end
    end
    if #paths[self.group] == 0 then
      table.remove(paths, self.group)
    end
  else
    for k, node in ipairs(areas[self.group]) do
      if node == self then
        table.remove(areas[self.group], k)
        break
      end
    end
    if #areas[self.group] == 0 then
      table.remove(areas, self.group)
    end
  end
  
  self = nil
end

function point.generic:setHoverHandler(strFuncEnter, strFuncExit)
  self.hoverHandler = {['Enter'] = strFuncEnter, ['Exit'] = strFuncExit}
  
  return true
end

function point.generic:setClickHandler(strFunc)
  self.clickHandler = strFunc
  
  return true
end

function point.generic:setHidden(bool)
  self.hide = bool
  
  return true
end

function point.generic:setPosition(intX, intY)
  self.x      = intX
  self.y      = intY
  self.fgCirc:setPosition(intX, intY)
  self.bgCirc:setPosition(intX, intY)
  
  self.bbox   = {self.x-self.rad, self.y-self.rad, self.x+self.rad, self.y+self.rad}
  
  return true
end

function point.generic:setRadius(intRad)
  self.rad    = intRad
  self.gui:setRadius(intRad)
  self.bbox   = {self.x-self.rad, self.y-self.rad, self.x+self.rad, self.y+self.rad}
  
  return true
end

function point.generic:setObject()
  curObject = self
  return true
end

--[[

  HANDLERS

--]]

function point_clickHandler(intX, intY, strButton)
  local lastObj
  if strButton == 1 then
    if curObject then
      if curObject.start == true then
        curObject.start = false
      else
        lastObj = curObject
        curObject.set = true
        curObject = nil
        if lastObj.clickHandler then
          _G[lastObj.clickHandler](lastObj, strButton, intMx, intMy)
          lastObj = nil
          return true
        end
      end
    end
  elseif strButton == 2 then
    if curObject then
      curObject:destroy()
      curObject = nil
    end
  elseif strButton == 3 then
    if curObject then
      curObject.set = false
    end
  end
end
registerGameCallBack('mousepressed', 'point_clickHandler')

function point_hoverHandler()
  local mx, my = love.mouse.getPosition()
  if (curObject and curObject.hoverHandler) then
    if not (isPointInsideBox(mx, my, unpack(curObject.bbox))) or (curObject.hide) then
      _G[curObject.hoverHandler['Exit']](curObject)
      curObject = nil
    end
    return true
  end
  
  
  for k, pointObj in ipairs(point.objects) do
    if not (pointObj.hide) then
      if (pointObj.hoverHandler) then
        if (isPointInsideBox(mx, my, unpack(pointObj.bbox))) then
          curObject = pointObj
          return _G[pointObj.hoverHandler['Enter']](pointObj, mx, my)
        end
      end
      if curObject == nil then
        if (isPointInsideBox(mx, my, unpack(pointObj.bbox))) then
          curObject = pointObj
        end
      end
    end
  end
  
  if (curObject and curObject.set == false) then
    curObject:setPosition(mx, my)
  end
end
registerGameCallBack('update', 'point_hoverHandler')
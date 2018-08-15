Towers = 
{
    ['cannon'] = 
    {
      name            = 'Cannon', -- Name that will be displayed in menu
      description     = 'Cannon that shoots balls as big as watermelons, As efficient as it is expensive.', -- description
      aoe             = 0, -- area of effect, the area the projectile will reach.
      rps             = 1, -- round per second
      damage          = 5,
      projectileType  = '', -- What kind of projectile, to be fired
      cost            = 10,
      icon            = 'cannon_icon1', -- Menu icon, and also determines if it should be in menu, if not it's a upgrade
      range           = 50, -- seen in pixels
      size            = {w = 32, h = 32},
      renderType      = 'canon_1',
      parts           = {
                          base = {skin = 'cannon_base1'},
                          top  = {skin = 'cannon_top1'}
                        }
      
    },
    ['laser'] =
    {
      name            = 'Laser',
      description     = 'Laser tower, that will melt all chickens that are nearby.',
      aoe             = 0,
      rps             = 4,
      damage          = 2,
      projectileType  = '',
      cost            = 20,
      icon            = '', -- make
      range           = 40,
      size            = {w = 32, h = 32},
      renderType      = 'laser_1',
      parts           = {
                          base  = {skin = 'laser_base1'},
                          top   = {skin = 'laser_top1'}
                        }
      
    }
}

local tower = 
{
  towers    = {},
  menu      = {},
  generic   = {}
}

local t_rangeColor = Colors.green
local towerImgDir = '/img/'
local curObj = nil
local winX, winY = love.graphics.getWidth(), love.graphics.getHeight()
local menu_size = {w = 200, h = winY, buttonSize = {w = 90, h = 45, m = 5}}

local towerGeneric_mt = {__index = function(t,k) return tower.generic[k] end}
setmetatable(tower.towers, towerGeneric_mt)

local function create(obj)
  setmetatable(obj, {__index = function(t, k) return tower.towers[k] end})
  table.insert(tower.towers, obj)
  return obj
end

--[[

  Tower Menu

--]]

function tower_createTower_menu(x, y)
  local bgcolor = Colors.grey
  local counterX, counterY, max = 0, 0 ,1
  
  tower.menu['rectangle'] = gui.createRectangle(x-menu_size.w, y, menu_size.w, menu_size.h, bgcolor)
  tower.menu['rectangle']:setHoverHandler('tower_tower_menu_hoverEnter', 'tower_tower_menu_hoverExit')
  
  for t, menuObj in pairs(Towers) do
   if menuObj.icon then
      tower.menu[menuObj.name] = gui.createButton(((x-menu_size.w) + menu_size.buttonSize.w*counterX)+menu_size.buttonSize.m*(counterX+1), (y) + (menu_size.buttonSize.h*counterY)+menu_size.buttonSize.m*(counterY+1), menu_size.buttonSize.w, menu_size.buttonSize.h, menuObj.name, Colors.lightGrey, Colors.white, 'Maps')
      
      tower.menu[menuObj.name]:setHoverHandler('tower_tower_buttons_hoverEnter', 'tower_tower_buttons_hoverExit')
      tower.menu[menuObj.name]:setClickHandler('tower_tower_buttons_click')
      if not counterX == max then counterX = counterX + 1 else counterX = 1 end 
    end
  end
  
  -- start
  tower.menu['rectangle']:setPosition(winX-10, 0)
  
  for _, menuObj in pairs(tower.menu) do
    if menuObj ~= tower.menu['rectangle'] then
      menuObj:setHidden(true)
    end
  end
  
end

function tower_tower_menu_hoverEnter(rect)
  rect:setPosition(winX-menu_size.w, 0)
  
  for _, menuObj in pairs(tower.menu) do
    if menuObj ~= rect then
      menuObj:setHidden(false)
    end
  end
end

function tower_tower_menu_hoverExit(rect)
  rect:setPosition(winX-10, 0)
  for _, menuObj in pairs(tower.menu) do
    if menuObj ~= rect then
      menuObj:setHidden(true)
    end
  end
end

function tower_tower_buttons_hoverEnter(but)
  but:setSize(menu_size.buttonSize.w+5, menu_size.buttonSize.h+5)
end

function tower_tower_buttons_hoverExit(but)
  but:setSize(menu_size.buttonSize.w, menu_size.buttonSize.h)
end

function tower_tower_buttons_click(but)
  local playerCash = gameObj.hud:getCash()
  local towerCost = Towers[but.text:lower()].cost
  local mx, my = love.mouse.getPosition()
  
  if playerCash >= towerCost and not curObj then
    gameObj.hud:setCash(playerCash-towerCost)
    local a = tower_createTower(mx, my, but.text:lower())
  end
end

--[[

  Towers

--]]

function tower_createTower(intX, intY, strTower)
  local obj = {}
  obj.towerType = strTower
  obj.x = intX
  obj.y = intY
  obj.w = Towers[strTower].size.w
  obj.h = Towers[strTower].size.h
  obj.base = love.graphics.newImage(towerImgDir .. Towers[strTower].parts.base.skin .. '.png')
  obj.top  = love.graphics.newImage(towerImgDir .. Towers[strTower].parts.top.skin .. '.png')
  obj.rot = 180
  obj.set = false
  obj.canSet = false
  obj.scaleX = 1
  obj.scaleY = 1
  obj.level = 1
  obj.bbox = {intX, intY, intX+obj.w, intY+obj.h}
  
  return create(obj)
end

function tower.towers:destroy()
  if curObj == self then
    curObj = nil
  end
  
  for k, tow in ipairs(tower.towers) do
    if tow == self then
      table.remove(tower.towers, k)
    end
  end
    
  self = nil
end

function tower.towers:setPosition(intX, intY)
  self.x = intX
  self.y = intY
  
  self.bbox = {intX, intY, intX + self.w, intY + self.h}
  
  return true
end

function tower.towers:setScale(intScaleX, intScaleY)
  self.scaleX = intScaleX
  self.scaleY = intScaleY
  
  return true
end

function tower.towers:setRotation(intRot)
  self.rot = intRot
  
  return true
end

function tower.towers:render()
  love.graphics.setColor(unpack(t_rangeColor))
  if self == curObj then
    if self.level == 1 then
      love.graphics.circle('fill', self.x + self.w/2, self.y + self.h/2, Towers[self.towerType].range)
    else
      love.graphics.circle('fill', self.x + self.w/2, self.y + self.h/2, Towers[self.towerType .. self.level].range)
    end
  end
  --base
  love.graphics.setColor(1, 1, 1, 1)
  love.graphics.draw(self.base, self.x, self.y, 0, self.scaleX, self.scaleY)
  -- top
  self.rot = self.rot + 1
  love.graphics.draw(self.top, self.x + self.w/2, self.y + self.h/2, math.rad(self.rot), self.scaleX, self.scaleY, self.w/2, self.h/2)
  
end

function tower_do_render()
  for _, guiObj in ipairs(tower.towers) do
    if not (guiObj.hide) then
      guiObj:render()
    end
  end
end

--[[

  GENERIC

--]]

function tower.generic:setHoverHandler(strFuncEnter, strFuncExit)
  self.hoverHandler = {['Enter'] = strFuncEnter, ['Exit'] = strFuncExit}
  
  return true
end

function tower.generic:setHidden(bHidden)
  self.hide = bHidden
  
  return true
end

--[[

  HANDLERS

--]]

function tower_do_clickHandler(intX, intY, strButton)
  if strButton == 1 then
    if curObj then
      if (isPointInsideBox(intX, intY, unpack(curObj.bbox))) then
        if curObj.set == false and curObj.canSet == true then
          curObj.set = true
          curObj = nil
        end
      else
        curObj = nil
      end
    end
    for _, towObj in ipairs(tower.towers) do
      if (isPointInsideBox(intX, intY, unpack(towObj.bbox))) then
        curObj = towObj
      end
    end
  end
end

function tower_do_hoverHandler()
  local mx, my = love.mouse.getPosition()
  if curObj then
    if curObj.set == false then
      curObj:setPosition(mx - curObj.w/2, my - curObj.h/2)
    end
  end
end

function tower_do_gameHandling()
  local mx, my = love.mouse.getPosition()
  if curObj then
    if not curObj.set then
      curObj.canSet = false
      for _, area in ipairs(t_map.area) do
        if (isPointInsidePolygon(curObj.x, curObj.y, area)) and (isPointInsidePolygon(curObj.bbox[3], curObj.bbox[4], area)) then
          curObj.canSet = true
        end
      end
      if curObj.canSet then
        t_rangeColor = Colors.green
        t_rangeColor[4] = 0.1
      else
        t_rangeColor = Colors.red
        t_rangeColor[4] = 0.1
      end
    end
  end
end

function registerAllTowerHandlers()
  registerGameCallBack('mousepressed', 'tower_do_clickHandler')
  registerGameCallBack('update', 'tower_do_hoverHandler')
  registerGameCallBack('update', 'tower_do_gameHandling')
  registerGameCallBack('draw', 'tower_do_render')
end

function deRegisterAllTowerHandlers()
  deregisterGameCallBack('mousepressed', 'tower_do_clickHandler')
  deregisterGameCallBack('update', 'tower_do_hoverHandler')
  deregisterGameCallBack('update', 'tower_do_gameHandling')
  deregisterGameCallBack('draw', 'tower_do_render')
end
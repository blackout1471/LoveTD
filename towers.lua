t_towerList = 
{
  'cannon',
  'laser'
}

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
                          base = {skin = 'cannon_base1.png'},
                          top  = {skin = 'cannon_top1.png'}
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
                          base  = {skin = 'laser_base1.png'},
                          top   = {skin = 'laser_top1.png'}
                        }
      
    }
}

local tower = {mt = {}}
local towerImgDir = '/img/'

--[[

  Setup metatables for lookup

--]]

local function create(obj)
  setmetatable(obj, tower.mt)
  
  return obj
end

function tower.mt:__index(k)
  return tower[k]
end

--[[

  Tower Functions

--]]

function create_tower(strType)
  local obj = {}
  obj.towerType   = strType
  obj.x           = 0
  obj.y           = 0
  obj.w           = Towers[strType].size.w
  obj.h           = Towers[strType].size.h
  obj.rot         = 0
  obj.rangeColor  = setAlphaInTable(Colors.green, 0.2)
  obj.scaleX      = 1
  obj.scaleY      = 1
  obj.imgBase     = love.graphics.newImage(towerImgDir .. Towers[strType].parts.base.skin)
  obj.imgTop      = love.graphics.newImage(towerImgDir .. Towers[strType].parts.top.skin)
  obj.bbox        = {obj.x, obj.y, obj.x + obj.w, obj.y + obj.h}
  
  return create(obj)
end

function tower:setSize(intW, intH)
  self.w = intW
  self.h = intH
  
  return true
end

function tower:getSize()
  return {self.w, self.h}
end

function tower:setPosition(intX, intY)
  self.x    = intX
  self.y    = intY
  
  self.bbox = {self.x - self.w/2, self.y - self.h/2, self.x + self.w/2, self.y + self.h/2, self.x - self.w/2, self.y + self.h/2, self.x + self.w/2, self.y - self.h/2}
  
  return true
end

function tower:getPosition()
  return {self.x, self.y}
end

function tower:setRotation(intRot)
  self.rot = intRot
  
  return true
end

function tower:getRotation()
  return self.rot
end

function tower:setScale(intScaleX, intScaleY)
  self.scaleX = intScaleX
  self.scaleY = intScaleY
  
  return true
end

function tower:setClickHandler(strFunc)
  self.clickHandler = strFunc
  
  return true
end
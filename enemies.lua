--[[

  ENEMY FILE, containing methods for the enemies and the constructor

--]]

local imgDir = '/img/'

t_enemies = {
    ['red'] = 
    {
      health  = 20,
      speed   = 50, -- pixels per frame
      skin    = 'red1.png',
      size    = {32, 32},
      cash    = 1
    }
}

local enemies = {mt = {}}

local function create(obj)
  setmetatable(obj, enemies.mt)
  
  return obj
end

function enemies.mt:__index(k)
  return enemies[k]
end

function create_enemy(strEnemyType)
  local obj = {}
  obj.enemyType = strEnemyType
  obj.x         = 0
  obj.y         = 0
  obj.w         = t_enemies[strEnemyType].size[1]
  obj.h         = t_enemies[strEnemyType].size[2]
  obj.rot       = 0
  obj.scaleX    = 1
  obj.scaleY    = 1
  obj.node      = 1
  obj.skin      = love.graphics.newImage(imgDir .. t_enemies[strEnemyType].skin)
  obj.bbox      = {obj.x, obj.y, obj.x + obj.w, obj.y + obj.h}
  
  return create(obj)
end

function enemies:setSize(intW, intH)
  self.w = intW
  self.h = intH
  
  self.bbox = {self.x, self.y, self.x + self.w, self.y + self.h}
  
  return true
end

function enemies:setPosition(intX, intY)
  self.x = intX
  self.y = intY
  
  self.bbox = {self.x - self.w/2, self.y - self.h/2, self.x + self.w/2, self.y + self.h/2}
  
  return true
end

function enemies:getPosition()
  return {self.x, self.y}
end

function enemies:setScale(intScaleX, intScaleY)
  self.scaleX = intScaleX
  self.scaleY = intScaleY
  
  return true
end

function enemies:getScale()
  return {self.scaleX, self.scaleY}
end

function enemies:setRotation(intRot)
  self.rot = intRot
  
  return true
end

function enemies:getRotation()
  return self.rot
end
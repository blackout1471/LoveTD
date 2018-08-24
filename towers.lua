t_towerList = 
{
  'cannon',
  'laser',
  'flamethrower',
  'nuclear'
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
      projectileType  = 'cannon', -- What kind of projectile, to be fired
      cost            = 10,
      icon            = 'cannon_icon1', -- Menu icon, and also determines if it should be in menu, if not it's a upgrade
      range           = 90, -- seen in pixels
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
      rps             = 7,
      damage          = 1.4,
      projectileType  = 'laser',
      cost            = 20,
      icon            = '', -- make
      range           = 130,
      size            = {w = 32, h = 32},
      renderType      = 'laser_1',
      parts           = {
                          base  = {skin = 'laser_base1.png'},
                          top   = {skin = 'laser_top1.png'}
                        }
      
    },
    ['nuclear'] =
    {
      name            = 'Nuclear',
      description     = 'Total annihilation of all chickens, be careful when you use this.',
      aoe             = 0,
      rps             = 0.2,
      damage          = 200,
      projectileType  = 'nuclear',
      cost            = 110,
      icon            = '', -- make
      range           = 300,
      size            = {w = 50, h = 50},
      renderType      = 'laser_1',
      parts           = {
                          base  = {skin = 'Nuclear_base.png'},
                          top   = {skin = 'Nuclear_top.png'}
                        }
    },
    ['flamethrower'] =
    {
      name            = 'Flamethrower',
      description     = 'If you like your chickens grilled, this is the tower for you.',
      aoe             = 3,
      rps             = 20,
      damage          = 1,
      projectileType  = 'flame',
      cost            = 40,
      icon            = '', -- make
      range           = 60,
      size            = {w = 32, h = 32},
      renderType      = 'flame_1',
      parts           = {
                          base  = {skin = 'Flame_Base1.png'},
                          top   = {skin = 'Flame_Top1.png'}
                        }
      
    },
    ['flamethrower2'] =
    {
      name            = 'Flamethrower',
      description     = 'If you like your chickens grilled, this is the tower for you.',
      aoe             = 3,
      rps             = 20,
      damage          = 2.4,
      projectileType  = 'flame',
      cost            = 80,
      icon            = '', -- make
      range           = 80,
      size            = {w = 32, h = 32},
      renderType      = 'flame_1',
      parts           = {
                          base  = {skin = 'Flame_Base1.png'},
                          top   = {skin = 'Flame_Top1.png'}
                        }
      
    },
    ['laser2'] = --TEST FOR AN UPGRADE
    {
       name            = 'Laser2',
      description     = 'Laser tower, that will melt all chickens that are nearby.',
      aoe             = 0,
      rps             = 10,
      damage          = 2,
      projectileType  = 'laser',
      cost            = 40,
      icon            = '', -- make
      range           = 140,
      size            = {w = 32, h = 32},
      renderType      = 'laser_1',
      parts           = {
                          base  = {skin = 'laser_base1.png'},
                          top   = {skin = 'laser_top1.png'}
                        }
      
    },
    ['laser23'] = --TEST FOR AN UPGRADE
    {
       name            = 'Laser3',
      description     = 'Laser tower, that will melt all chickens that are nearby.',
      aoe             = 0,
      rps             = 12,
      damage          = 4,
      projectileType  = 'laser',
      cost            = 100,
      icon            = '', -- make
      range           = 140,
      size            = {w = 32, h = 32},
      renderType      = 'laser_1',
      parts           = {
                          base  = {skin = 'laser_base2.png'},
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
  obj.level       = 1
  obj.y           = 0
  obj.w           = Towers[strType].size.w
  obj.h           = Towers[strType].size.h
  obj.rot         = 0
  obj.target      = nil
  obj.rangeColor  = setAlphaInTable(Colors.green, 0.2)
  obj.scaleX      = 1
  obj.scaleY      = 1
  obj.tick        = 1
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

function tower:getProjectile()
  return Towers[self.towerType].projectileType
end

function tower:setClickHandler(strFunc)
  self.clickHandler = strFunc
  
  return true
end

function tower:getTarget(t_enemy)
  for k, enemy in ipairs(t_enemy) do
    local distToTarget = get2dDistance(self.x + self.w/2, self.y + self.h/2, enemy.x + enemy.w/2, enemy.y + enemy.h/2)
    local range = Towers[self.towerType].range
    if distToTarget <= range then
      return enemy
    end
  end
  return nil
end

function tower:attack(targetObj)
  local tick = getTime()
  local attackRate = Towers[self.towerType].rps
  if ((tick - self.tick) >= 1 / attackRate) then
    table.insert(gameObj.projectiles, createProjectile(self.x, self.y, self:getProjectile(), targetObj, Towers[self.towerType].damage))
    self.tick = tick
  end
end
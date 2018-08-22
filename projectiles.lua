--[[

  PROJECTILES

--]]

local imgDir = '/img/'

t_projectiles = {
  
    ['cannon'] = {
      skin = 'cannon_ball.png',
      speed = 100, -- pixels pr second
      amount = 1, -- the amount of shots to produce
      size = {10, 10}
    },
    ['laser'] = {
        skin = 'laser_shot.png',
        speed = 300,
        amount = 1,
        size = {10, 5}
    },
    ['flame'] = {
        skin = 'Flame_shot.png',
        speed = 150,
        amount = 1,
        size = {14, 14}
    }
}

local projectiles = {mt={}}

local function create(obj)
  setmetatable(obj, projectiles.mt)
  
  return obj
end

function projectiles.mt:__index(k)
  return projectiles[k]
end

function createProjectile(intX, intY, strType, target, intDamage)
  local obj   = {}
  obj.type    = strType
  obj.x       = intX
  obj.y       = intY
  obj.w       = t_projectiles[strType].size[1]
  obj.h       = t_projectiles[strType].size[2]
  obj.target  = target
  obj.rot     = 0
  obj.scaleX  = 1
  obj.scaleY  = 1
  obj.damage  = intDamage
  obj.image   = love.graphics.newImage(imgDir .. t_projectiles[strType].skin)
  obj.bbox    = {obj.x, obj.y, obj.x + obj.w, obj.y + obj.h}
  
  return create(obj)
end

function projectiles:setPosition(intX, intY)
  self.x = intX
  self.y = intY
  
  self.bbox = {self.x, self.y, self.x + self.w, self.y + self.h}
  
  return true
end

function projectiles:setRotation(intRot)
  self.rot = rot
  
  return true
end

function projectiles:render()
  love.graphics.setColor(unpack(Colors.white))
  love.graphics.draw(self.image, self.x, self.y, self.rot, self.scaleX, self.scaleY, self.w/2, self.h/2)
end

function projectiles:getToTarget(dt)
  local distanceToTarget = get2dDistance(self.x + self.w/2, self.y + self.h/2, self.target.x, self.target.y)
  local speed = t_projectiles[self.type].speed
  local proj_vx, proj_vy = (self.target.x - self.x) / distanceToTarget * speed, (self.target.y - self.y) / distanceToTarget * speed
  local projX, projY = self.x + proj_vx * dt, self.y + proj_vy * dt
  
  self:setPosition(projX, projY)
end


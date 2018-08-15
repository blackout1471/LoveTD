--[[

    GAME HUD

--]]

local hud = {mt = {}}

local hud_color = {{0.5, 0.5, 0.5, 0.8}, {0.5, 0.5, 0.5, 0.1}}
local hud_size = {w = 250, h = 50}
local winX, winY = love.graphics.getWidth(), love.graphics.getHeight()

function hud_createHUD()
  local obj = {}
  
  obj.bar = {}
  local bar = obj.bar
  bar.bg = gui.createRectangle(winX/2-hud_size.w/2, 20, hud_size.w, hud_size.h, hud_color[2])
  bar.bg:setHoverHandler('hud_hoverEnter', 'hud_hoverExit')
  
  bar.cashLabel     = gui.createLabel(bar.bg.x+10, bar.bg.y+20, '$:', Colors.white, 'Maps')
  bar.healthLabel   = gui.createLabel(bar.bg.x+100, bar.bg.y+20, 'Lives:', Colors.white, 'Maps')
  
  
  bar.curWaveLabel  = gui.createLabel(bar.bg.x+190, bar.bg.y+20, '0', Colors.white, 'Maps')
  bar.maxWaveLabel  = gui.createLabel(bar.bg.x+200, bar.bg.y+20, '/20', Colors.white, 'Maps')
  
  setmetatable(obj, hud.mt)
  hud.inst = obj
  
  return obj
end

function hud.mt:__index(k)
  return hud[k]
end

function hud:destroy()
  for _,GUIObj in pairs (self.bar) do GUIObj:destroy() end
    return true
end

function hud:setCash(intCash)
  return self.bar.cashLabel:setText('$:' .. tostring(intCash))
end

function hud:getCash()
  local text = self.bar.cashLabel:getText()
  text = tonumber(text:sub(3, #text))
  
  return text
end

function hud:setHealth(intHealth)
  return self.bar.healthLabel:setText('Lives:' .. tostring(intHealth))
end

function hud:getHealth()
  return tonumber(self.bar.healthLabel:getText():sub(7, #self.bar.healthLabel:getText()))
end

function hud:setCurWave(intWave)
  return self.bar.curWaveLabel:setText(tostring(intWave))
end

function hud:getCurWave()
  return tonumber(self.bar.curWaveLabel:getText())
end

function hud:setMaxWave(intMaxWave)
  return self.bar.maxWaveLabel:setText(tostring(intMaxWave))
end

function hud:getMaxWaves()
  return tonumber(self.bar.maxWaveLabel:getText())
end


function hud_hoverEnter()
  for _, guiObj in pairs(hud.inst.bar) do
    local clr = {guiObj.color[1], guiObj.color[2], guiObj.color[3], 0.8}
    guiObj:setColor(clr)
  end
end

function hud_hoverExit()
  for _, guiObj in pairs(hud.inst.bar) do
    local clr = {guiObj.color[1], guiObj.color[2], guiObj.color[3], 0.2}
    guiObj:setColor(clr)
  end
end

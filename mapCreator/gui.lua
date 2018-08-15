--[[

  GUI setup for oop, and general arrays to hold data.
  This file contains the GUI engine.

]]--

gui = 
{
    Buttons     = {},
    Labels      = {},
    Rectangles  = {},
    Generic     = {},
    Image       = {},
    Circles     = {},
    Lines       = {},
    objects     = {}
}

local t_fonts =
{
  ['Buttons'] = love.graphics.newFont('/font/butFont.otf', 20),
  ['Maps']    = love.graphics.newFont(12)
}

Colors =
{
    ['black']     = {0, 0, 0, 1},
    ['white']     = {1, 1, 1, 1},
    ['green']     = {0, 1, 0, 1},
    ['grey']      = {0.5, 0.5, 0.5, 1},
    ['lightGrey'] = {0.7, 0.7, 0.7, 1},
    ['blue']      = {0, 0, 1, 1},
    ['red']       = {1, 0, 0, 1},
    ['yellow']    = {1, 1, 0, 1}
}

local guiGeneric_mt = {__index = function(t,k) return gui.Generic[k] end}
setmetatable(gui.Buttons, guiGeneric_mt)
setmetatable(gui.Labels, guiGeneric_mt)
setmetatable(gui.Rectangles, guiGeneric_mt)
setmetatable(gui.Image, guiGeneric_mt)
setmetatable(gui.Circles, guiGeneric_mt)

local function create (obj)
    setmetatable (obj, {__index = function(t,k) return gui[obj.guiType][k] end})
    table.insert (gui.objects, obj)
    
    return obj
end

local curGuiHoverObject

function gui_do_render()
  local t_postGUI = {}
  
  for _, renderObj in ipairs(gui.objects) do
    if not (renderObj.hide) then
      if not (renderObj.postGUI) then
        renderObj:render()
      else
        table.insert(t_postGUI, renderObj)
      end
    end
  end
  
  for _, postRender in ipairs(t_postGUI) do
    postRender:render()
  end
end

--[[
  GUI ENGINE
--]]

--[[

  BUTTONS

--]]

function gui.createButton(intX, intY, intW, intH, strText, t_bgColor, t_textColor, strFont)
  local t_Font = t_fonts[strFont] 
  
  local obj = {}
  obj.guiType   = 'Buttons'
  obj.text      = strText
  obj.x         = intX
  obj.y         = intY
  obj.w         = intW
  obj.h         = intH
  obj.textX     = intX + (intW/2) - t_Font:getWidth(strText)/2
  obj.textY     = intY + (intH/2) - t_Font:getHeight()/2
  obj.textColor = t_textColor
  obj.bgColor   = t_bgColor
  obj.font      = t_Font
  obj.bbox      = {intX, intY, intX+intW, intY+intH}
  
  return create(obj)
end

function gui.Buttons:render() -- Render function for the buttons
  love.graphics.setColor(self.bgColor)
  
  love.graphics.rectangle('fill', self.x, self.y, self.w, self.h)
  
  love.graphics.setColor(self.textColor)
  love.graphics.setFont(self.font)
  love.graphics.print(self.text, self.textX, self.textY)
end

function gui.Buttons:destroy() -- Destroy button
  if curGuiHoverObject == self then
    curGuiHoverObject = nil
  end
  
  for k, guiBut in ipairs(gui.objects) do
    if guiBut == self then
      table.remove(gui.objects, k)
    end
  end
    
  self = nil
end

function gui.Buttons:setText(strText)
  self.text   = strText
  self.textX  = self.x + (self.w/2) - self.font:getWidth(strText)/2
  
  return true
end

function gui.Buttons:setbgColor(t_bgColor)
  self.bgColor = t_bgColor
  
  return true
end

function gui.Buttons:setTextColor(t_textColor)
  self.textColor = t_textColor
  
  return true
end

function gui.Buttons:setPosition(intX, intY)
  local diffX, diffY = intX - self.x, intY - self.y
  
  self.x = intX
  self.y = intY
  self.textX = self.textX + diffX
  self.textY = self.textY + diffY
  
  self.bbox = {self.x, self.y, self.x+self.w, self.y+self.h}
  
  return true
end

--[[

    LABELS

--]]

function gui.createLabel(intX, intY, strText, t_color, t_font)
  local font = t_fonts[t_font]
  local fontW, fontH = font:getWidth(strText), font:getHeight()
  local obj = {}
  
  obj.guiType = 'Labels'
  obj.x       = intX
  obj.y       = intY
  obj.w       = fontW
  obj.h       = fontH
  obj.text    = strText
  obj.color   = t_color
  obj.font    = font
  obj.bbox    = {intX, intY, intX+fontW, intY+fontH}
  
  return create (obj)
end

function gui.Labels:render()
  love.graphics.setColor(unpack(self.color))
  love.graphics.setFont(self.font)
  love.graphics.print(self.text, self.x, self.y)
end

function gui.Labels:destroy()
  if curGuiHoverObject == self then
    curGuiHoverObject = nil
  end
  
  for k, guiBut in ipairs(gui.objects) do
    if guiBut == self then
      table.remove(gui.objects, k)
    end
  end
    
  self = nil
end

function gui.Labels:setPosition(intX, intY)
  
  self.x = intX
  self.y = intY
  
  self.bbox = {self.x, self.y, self.x+self.w, self.y+self.h}
  
  return true
end

function gui.Labels:center()
  local winX, winY = love.graphics.getWidth(), love.graphics.getHeight()
  
  self.x = winX/2 - (self.font:getWidth(self.text)/2)
  self.y = winY/2 - (self.font:getHeight()/2)
  
  return true
end

function gui.Labels:centerX()
  local winX, winY = love.graphics.getWidth(), love.graphics.getHeight()
  
  self.x = winX/2 - (self.font:getWidth(self.text)/2)
  
  return true
end

function gui.Labels:centerY()
  local winX, winY = love.graphics.getWidth(), love.graphics.getHeight()
  
  self.y = winY/2 - (self.font:getHeight()/2)
  
  return true
end

function gui.Labels:setText(strText)
  self.text = strText
  self.w = self.font:getWidth(self.text)
  self.h = self.font:getheight(self.text)
  
  return true
end


--[[

    Images

--]]

function gui.createImage(intX, intY, Image)
  local imageW, imageH = Image:getWidth(), Image:getHeight()
  
  local obj = {}
  
  obj.guiType       = 'Image'
  obj.image         = Image
  obj.x             = intX
  obj.y             = intY
  obj.w             = imageW
  obj.h             = imageH
  obj.orientation   = 0
  obj.scaleX        = 1
  obj.scaleY        = 1
  obj.color         = Colors.white
  obj.bbox          = {intX, intY, intX+imageW, intY+imageH}
  
  return create(obj)
  
end

function gui.Image:render()
  love.graphics.setColor(unpack(self.color))
  love.graphics.draw(self.image, self.x, self.y, self.orientation, self.scaleX, self.scaleY)
end

function gui.Image:destroy()
  if curGuiHoverObject == self then
    curGuiHoverObject = nil
  end
  
  for k, guiBut in ipairs(gui.objects) do
    if guiBut == self then
      table.remove(gui.objects, k)
    end
  end
    
  self = nil
end

function gui.Image:setPosition(intX, intY)
  self.x = intX
  self.y = intY
  
  return true
end

function gui.Image:getImage()
  return self.image
end

function gui.Image:setRotation(intRot)
  self.orientation = intRot
  
  return true
end

function gui.Image:setScale(intX, intY)
  local intW, intH = self.image:getDimensions()
  
  self.bbox[3] = self.x + intW * intX
  self.bbox[4] = self.y + intH * intY
  
  self.scaleX = intX
  self.scaleY = intY
  
  return true
end

--[[

    Rectangles

--]]

function gui.createRectangle(intX, intY, intW, intH, t_color)
  local obj = {}
  
  obj.guiType = 'Rectangles'
  obj.x       = intX
  obj.y       = intY
  obj.w       = intW
  obj.h       = intH
  obj.color   = t_color
  obj.bbox    = {intX, intY, intX+intW, intY+intH}
  
  return create(obj)
end

function gui.Rectangles:destroy()
    if curGuiHoverObject == self then
    curGuiHoverObject = nil
  end
  
  for k, guiBut in ipairs(gui.objects) do
    if guiBut == self then
      table.remove(gui.objects, k)
    end
  end
    
  self = nil
end

function gui.Rectangles:render()
  
  love.graphics.setColor(unpack(self.color))
  love.graphics.rectangle('fill', self.x, self.y, self.w, self.h)
end

function gui.Rectangles:setColor(t_color)
  self.color = t_color
  
  return true
end

function gui.Rectangles:setPosition(intX, intY)
  
  self.x = intX
  self.y = intY
  
  self.bbox = {intX, intY, intX+self.w, intY+self.h}
  
  return true
end

function gui.Rectangles:setSize(intW, intH)
  self.w = intW
  self.h = intH
  
  self.bbox[3] = self.x + intW
  self.bbox[4] = self.y + intH
  
  return true
end

function gui.Rectangles:setCenter()
  local ww, wh = love.graphics.getWidth(), love.graphics.getHeight()
  
  self.x = (ww/2) - (self.w/2)
  self.y = (wy/2) - (self.h/2)
  
  self.bbox = {self.x, self.y, self.x + self.w, self.y + self.h}
  
  return true
end


--[[

  Circles

--]]

function gui.createCircle(intX, intY, rad, t_color)
  local obj = {}
  
  obj.guiType = 'Circles'
  obj.x       = intX
  obj.y       = intY
  obj.rad     = rad
  obj.color   = t_color
  obj.bbox    = {intX - rad, intY-rad, intX + rad, intY + rad}
  
  return create(obj)
end

function gui.Circles:destroy()
  if curGuiHoverObject == self then
    curGuiHoverObject = nil
  end
  
  for k, guiBut in ipairs(gui.objects) do
    if guiBut == self then
      table.remove(gui.objects, k)
    end
  end
    
  self = nil
end

function gui.Circles:render()
  
  love.graphics.setColor(unpack(self.color))
  love.graphics.circle('fill', self.x, self.y, self.rad)
  
end

function gui.Circles:setPosition(intX, intY)
  self.x  = intX
  self.y  = intY
  
  self.bbox = {self.x - self.rad, self.y - self.rad, self.x + self.rad, self.y + self.rad}
  
  return true
end

function gui.Circles:setRadius(intRad)
  self.rad = intRad
  
  self.bbox = {self.x - self.rad, self.y - self.rad, self.x + self.rad, self.y + self.rad}
  
  return true
end

function gui.Circles:setColor(t_color)
  self.color = t_color
  
  return true
end

function gui.Circles:getCenter()
  return {x = self.x, y = self.y}
end

--[[

  Lines

--]]

function gui.createLine(intX, intY, intX2, intY2, intW, t_color)
  local obj = {}
  
  obj.guiType = 'Lines'
  obj.x       = intX
  obj.y       = intY
  obj.x2      = intX2
  obj.y2      = intY2
  obj.color   = t_color
  obj.w   = intW
  
  return create(obj)
end

function gui.Lines:destroy()
  if curGuiHoverObject == self then
    curGuiHoverObject = nil
  end
  
  for k, guiBut in ipairs(gui.objects) do
    if guiBut == self then
      table.remove(gui.objects, k)
    end
  end
    
  self = nil
end

function gui.Lines:render()
  love.graphics.setColor(unpack(self.color))
  love.graphics.setLineWidth(self.w)
  love.graphics.line(self.x, self.y, self.x2, self.y2)
end

function gui.Lines:setColor(t_color)
  self.color = t_color
  
  return true
end

function gui.Lines:setWidth(intW)
  self.w = intW
  
  return true
end

--[[

    Generic

--]]

function isPointInsideBox (pX, pY, bX, bY, bX2, bY2)
    if ((pX > bX)
    and (pX < bX2)
    and (pY > bY)
    and (pY < bY2)) then
        return true
    end
    
    return false
end

function gui.Generic:setColor(t_color)
  self.color = t_color
  
  return true
end

function gui.Generic:setPostGui(bPostGUI)
  self.postGUI = bPostGUI
  
  return true
end

function gui.Generic:setHidden(bHidden)
  self.hide = bHidden
  
  return true
end

function gui.Generic:setHoverHandler(strFuncEnter, strFuncExit)
  self.hoverHandler = {['Enter'] = strFuncEnter, ['Exit'] = strFuncExit}
  
  return true
end

function gui.Generic:setClickHandler(strFunc)
  self.clickHandler = strFunc
  
  return true
end

function gui_clickHandler(intMx, intMy, strButton)
  for _, guiObj in ipairs(gui.objects) do
    if not guiObj.hide then 
      if guiObj.clickHandler then
        if isPointInsideBox(intMx, intMy, unpack(guiObj.bbox)) then
          return _G[guiObj.clickHandler](guiObj, strButton, intMx, intMy)
        end
      end
    end
  end
end
registerGameCallBack('mousepressed', 'gui_clickHandler')

function gui_DoHoverHandler()
    local int_mX, int_mY = love.mouse.getPosition ()
    if (curGuiHoverObject) then
        if not (isPointInsideBox(int_mX, int_mY, unpack(curGuiHoverObject.bbox))) or (curGuiHoverObject.hide) then
            _G[curGuiHoverObject.hoverHandler['Exit']](curGuiHoverObject)
            curGuiHoverObject = nil
        end
        
        return true
    end
    
    for k,GUIObj in ipairs (gui.objects) do
        if (not GUIObj.hide) then
            if (GUIObj.hoverHandler) then
                if (isPointInsideBox(int_mX, int_mY, unpack(GUIObj.bbox))) then
                    curGuiHoverObject = GUIObj
                    return _G[GUIObj.hoverHandler['Enter']](GUIObj, int_mX, int_mY)
                end
            end
        end
    end
    
    return true
end
registerGameCallBack('update', 'gui_DoHoverHandler')
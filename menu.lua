--[[

  Menu File, this is where all the menu's functions are

--]]

local MapDir = '/maps/'
local imgDir = '/img/'
local t_maps = {}

menu = 
{
    ['main']     = {},
    ['settings'] = {},
    ['play']     = {}
}

local winX, winY = love.graphics.getWidth(), love.graphics.getHeight()
local bg = love.graphics.newImage(imgDir .. 'menu_bg.png')
local menu_size = 
{
  w = 200,
  h = 75,
  m = 10
}
local intYCounter = 0

--[[

  MENUS and functions

--]]


--[[

  Main Menu

--]]

function menu.main.create()
  -- reset y counter
  intYCounter = 0
  
  menu.main.bg = gui.createImage(0, 0, bg)
  
  menu.main.play = gui.createButton((winX/2) - menu_size.w/2, 100+((intYCounter)*menu_size.h+(intYCounter*menu_size.m)), menu_size.w, menu_size.h, 'Play', Colors.grey, Colors.white, 'Buttons')
  intYCounter = intYCounter + 1
  
  menu.main.settings = gui.createButton((winX/2) - menu_size.w/2, 100+((intYCounter)*menu_size.h+(intYCounter*menu_size.m)), menu_size.w, menu_size.h, 'Settings', Colors.grey, Colors.white, 'Buttons')
  intYCounter = intYCounter + 1
  
  menu.main.quit = gui.createButton((winX/2) - menu_size.w/2, 100+((intYCounter)*menu_size.h+(intYCounter*menu_size.m)), menu_size.w, menu_size.h, 'Quit', Colors.grey, Colors.white, 'Buttons')
  
  -- Buttons Handlers
  menu.main.play:setHoverHandler('menu_main_hoverEnter', 'menu_main_hoverExit')
  menu.main.play:setClickHandler('menu_main_play_click')
  
  menu.main.settings:setHoverHandler('menu_main_hoverEnter', 'menu_main_hoverExit')
  menu.main.settings:setClickHandler('menu_main_settings_click')
  
  menu.main.quit:setHoverHandler('menu_main_hoverEnter', 'menu_main_hoverExit')
  menu.main.quit:setClickHandler('menu_main_quit_click')
  
end

function menu.main.destroy()
  for k, v in pairs(menu.main) do
    if type(v) == 'table' then
      v:destroy()
    end
  end
end

function menu_main_play_click(button)
  menu.play.create()
  menu.main.destroy()
end

function menu_main_settings_click(button)
  menu.settings.create()
  menu.main.destroy()
end

function menu_main_quit_click(button)
  love.event.quit()
end

function menu_main_hoverEnter(button)
  button:setbgColor(Colors.lightGrey)
  button:setSize(menu_size.w+10, menu_size.h+10)
end

function menu_main_hoverExit(button)
  button:setbgColor(Colors.grey)
  button:setSize(menu_size.w, menu_size.h)
end

--[[
  
  Play
  This is where the maps are getting loaded
  
--]]

function menu.play.create()
  menu.play.bg = gui.createImage(0, 0, bg)
  local t_maps = utility_getMaps(MapDir)
  
  for t, map in ipairs(t_maps) do
    local img = love.graphics.newImage(MapDir..map)
    local imgSize
    menu.play[t] = gui.createImage(0, 0, img)
    menu.play[t].mapName = map
    menu.play[t]:setScale(0.2, 0.2)
    imgSize = menu.play[t]:getSize()
    menu.play[t]:setPosition(((t-1)*imgSize[1])+menu_size.m*(t), (winY/2)-(imgSize[2]/2))
    menu.play[t]:setHoverHandler('menu_play_hoverEnter', 'menu_play_hoverExit')
    menu.play[t]:setClickHandler('menu_play_mapClick')
  end
end

function menu.play.destroy()
  for k, v in pairs(menu.play) do
    if type(v) == 'table' then
      v:destroy()
    end
  end
end

function menu_play_hoverEnter(button)
  button:setScale(0.21, 0.21)
end

function menu_play_hoverExit(button)
  button:setScale(0.2, 0.2)
end

function menu_play_mapClick(button)
  game.loadMap(button:getImage(), button.mapName)
  menu.play.destroy()
end


--[[
  
  Settings
  
--]]

function menu.settings.create()
  menu.settings.bg = gui.createImage(0, 0, bg)
end

function menu.settings.destroy()
  for k, v in pairs(menu.settings) do
    if type(v) == 'table' then
      v:destroy()
    end
  end
end

function menu_settings_hoverEnter(button)
  button:setbgColor(Colors.lightGrey)
  button:setSize(menu_size.w+10, menu_size.h+10)
end

function menu_settings_hoverExit(button)
  button:setbgColor(Colors.grey)
  button:setSize(menu_size.w, menu_size.h)
end
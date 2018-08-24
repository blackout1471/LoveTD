-- Main part of the map creator

local files = 
{
    'audio',
    'gui',
    'utility',
    'menu',
    'launcher',
    'game',
    'towers',
    'enemies',
    'hud',
    'level',
    'projectiles'
}


local t_Callbacks = 
{
    ['focus'] =         {},
    ['keypressed'] =    {},
    ['keyreleased'] =   {},
    ['mousefocus'] =    {},
    ['mousepressed'] =  {},
    ['mousereleased'] = {},
    ['textinput'] =     {},
    ['threaderror'] =   {},
    ['visible'] =       {},
    ['update'] =        {},
    ['draw'] =          {}
}

for strCallback in pairs (t_Callbacks) do
    love[strCallback] = function (...)
        for _,strCallbackFunc in ipairs (t_Callbacks[strCallback]) do
            _G[strCallbackFunc](...)
        end
    end
end

function registerGameCallBack (strCallback, strFunc)
    return table.insert (t_Callbacks[strCallback], strFunc)
end

function deregisterGameCallBack (strCallback, strFunc)
    for k,strCallbackFunc in ipairs (t_Callbacks[strCallback]) do
        if (strCallbackFunc == strFunc) then
            return table.remove (t_Callbacks[strCallback], k)
        end
    end
end

function love.draw (...)
    if (gui) then
        gui_do_render ()
    end
    for _,strCallbackFunc in ipairs (t_Callbacks.draw) do
        _G[strCallbackFunc](...)
    end
end

local time = 0

function love.update (dt)
    if (dt > 0.025) then return false end
    time = time + dt
    
    for _,strCallbackFunc in ipairs (t_Callbacks.update) do
        _G[strCallbackFunc](dt)
    end
end

function getTime ()
    return time
end

function love.load () 
    for i,file in ipairs (files) do
        require (file)
    end
end
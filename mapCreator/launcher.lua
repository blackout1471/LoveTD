maps = {images = {}, labels = {}}
mapDir = '/maps/'

function getMaps()
  local t = love.filesystem.getDirectoryItems(mapDir)
  local b = {}
  
  for _, map in ipairs(t) do
    table.insert(b, map)
  end
  
  return b
end

function make_maps()
  local maps_names = getMaps()
  local t = 1
  local counter = 0
  local max = 4
  for k, map in ipairs(maps_names) do
    table.insert(maps, {map, love.graphics.newImage(mapDir .. map)})
  end
  
  for k, imageMap in ipairs(maps) do
    if counter == max then
      t = t + 1
      counter = 1
    else
      counter = counter + 1
    end
    maps.images[k] = gui.createImage(counter*150, t*150, imageMap[2])
    maps.images[k].mapName = imageMap[1]
    maps.images[k]:setScale(0.15, 0.15)
    maps.images[k]:setHoverHandler('maps_hoverHandlerEnter', 'maps_hoverHandlerExit')
    maps.images[k]:setClickHandler('maps_clickHandler')
    maps.labels[k] = gui.createLabel(counter*150, t*150+100, imageMap[1], Colors.white, 'Maps')
  end
end

function maps_hoverHandlerEnter(button)
  button:setScale(0.18, 0.18)
end

function maps_clickHandler(button)
  loadMap(button:getImage(), button.mapName)
  maps_destroy()
end

function maps_hoverHandlerExit(button)
  button:setScale(0.15, 0.15)
end

function maps_destroy()
  for _, image in pairs(maps.images) do
    image:destroy()
  end
  for _, label in pairs(maps.labels) do
    label:destroy()
  end
  
  return true
end

--Load all maps, and make them to images
make_maps()
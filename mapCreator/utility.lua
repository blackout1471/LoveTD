function writeMapData()
  if #areas == 0 or #paths == 0 then return end
  local data = ''
  local file = love.filesystem.newFile(curMapName:sub(1,#curMapName-3) .. 'homie')
  for k, path in ipairs(paths) do
    for t, node in ipairs(path) do
      data = data .. node.x .. ',' .. node.y
      if t < #path then
        data = data .. '|'
      end
    end
    if k < #paths then
      data = data .. '_'
    end
  end
  
  data = data .. '/'
  
  for k, area in ipairs(areas) do
    for t, node in ipairs(area) do
      data = data .. node.x .. ',' .. node.y
      if t < #area then
        data = data .. '|'
      end
    end
    if k < #areas then
      data = data .. '_'
    end
  end
  
  file:open('w')
  file:write(data)
  file:close()
  
  return true
end

function loadMapData(file)
  if love.filesystem.getInfo(file) then
    local data = love.filesystem.read(file)
    
    return data
  else
    return false
  end
end

function string:split(sep)
   local sep, fields = sep or ":", {}
   local pattern = string.format("([^%s]+)", sep)
   self:gsub(pattern, function(c) fields[#fields+1] = c end)
   return fields
end

function utility_getMaps(dir)
  local maps = {}
  local files = love.filesystem.getDirectoryItems(dir)
  
  for k, map in ipairs(files) do
    if (map:sub(#map-2, #map)) == 'png' then
      table.insert(maps, dir..map)
    end
  end
  
  return maps
end
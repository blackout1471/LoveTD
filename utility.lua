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
      table.insert(maps, map)
    end
  end
  
  return maps
end

function isPointInsidePolygon(x,y,poly)
	-- poly is like { {x1,y1},{x2,y2} .. {xn,yn}}
	-- x,y is the point
	local inside = false
	local p1x = poly[1].x
	local p1y = poly[1].y

	for i=0,#poly do
		
		local p2x = poly[((i)%#poly)+1].x
		local p2y = poly[((i)%#poly)+1].y
		
		if y > math.min(p1y,p2y) then
			if y <= math.max(p1y,p2y) then
				if x <= math.max(p1x,p2x) then
					if p1y ~= p2y then
						xinters = (y-p1y)*(p2x-p1x)/(p2y-p1y)+p1x
					end
					if p1x == p2x or x <= xinters then
						inside = not inside
					end
				end
			end
		end
		p1x,p1y = p2x,p2y	
	end
	return inside
end

function isPointInsideBox (pX, pY, bX, bY, bX2, bY2)
    if ((pX > bX)
    and (pX < bX2)
    and (pY > bY)
    and (pY < bY2)) then
        return true
    end
    
    return false
end

function CheckCollision(x1,y1,w1,h1, x2,y2,w2,h2)
  return x1 < x2+w2 and
         x2 < x1+w1 and
         y1 < y2+h2 and
         y2 < y1+h1
end

function get2dDistance(x1, y1, x2, y2)
  return math.sqrt((x2 - x1)^2 + (y2 - y1)^2)
end

function get2dRotation(x1, y1, x2, y2)
  return math.atan2(x2 - x1, y2 - y1) * 180 / math.pi
end

function setAlphaInTable(t_color, intAlpha)
  return {t_color[1], t_color[2], t_color[3], intAlpha}
end
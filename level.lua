--[[

  LEVEL FILE, should be data from mapCreator, only for test

--]]

--[[

  Wave 1. {Enemies, interval, how many enemies}
  Wave 2. {Enemies, interval, how many enemies}
  
--]]

Level = 
{
  map1 = 
  {
    {enemyType = 'red', interval = 1, amount = 1},
    {enemyType = 'red', interval = 2, amount = 20},
    {enemyType = 'red', interval = 2, amount = 10}
  },
  spire =
  {
    {enemyType = 'red', interval = 1, amount = 300},
    {enemyType = 'red', interval = 2, amount = 20},
    {enemyType = 'red', interval = 2, amount = 10}  
  }
}

function level_get_max_waves(strMap)
  return table.getn(Level[strMap])
end
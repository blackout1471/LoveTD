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
    {enemyType = 'starter', interval = 1, amount = 10},
    {enemyType = 'starter1', interval = 1, amount = 10},
    {enemyType = 'starter2', interval = 1, amount = 10},
    {enemyType = 'starter3', interval = 1, amount = 10},
    {enemyType = 'starter4', interval = 1, amount = 10},
    {enemyType = 'starterfast', interval = 0.5, amount = 20},
    {enemyType = 'miniboss', interval = 2, amount = 5},
    {enemyType = 'boss', interval = 2, amount = 1},
    {enemyType = 'miniboss', interval = 1, amount = 10},
    {enemyType = 'secondmob', interval = 1, amount = 10}
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
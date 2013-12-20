world = {}
local utils = require('utils')
local settings = require('settings')

function world.add_plants(plants, jungle)
    -- add plant in general area
    local c, r = utils.random_pos(settings.width, settings.height)
    plants[c..":"..r] = {c = c, r = r}

    local idx = math.random(1,#jungle)
    local jcoords= jungle[idx]
    plants[jcoords[1]..":"..jcoords[2]] = {c = jcoords[1], r = jcoords[2]}

    return plants
end

function world.create_jungle()
    local jungle = {}
    for i=1,400 do
        local c,r = utils.random_pos(settings.width, settings.height)
        table.insert(jungle, {c, r})
    end
    return jungle
end

function world.create_plants()
    local plants = {}
    for i=1,50 do
        local c,r = utils.random_pos(settings.width, settings.height)
        plants[c..":"..r] = {c = c, r = r}
    end
    return plants
end

function world.register_animal(a, register)
   local index = a.c..":"..a.r
   if register[index] == nil then
      register[index] = {}
   end
   register[index][a.id] = a.index
end

function world.deregister_animal(a, register)
    local index = a.c..":"..a.r
    register[index][a.id] = nil
end

function world.change_registration(a, from, register)
    register[from][a.id] = nil
    world.register_animal(a, register)
end

return world

carnivore = {}

-- local animal = require('animal')
local settings = require('settings')
local inspect = require('inspect')

-- function carnivore.make(species)
--     local a = animal.make()
--     a.species = species
--     a.energy = settings.carnivore_energy
--     a.reproduction_energy = settings.carnivore_reprod
--     a.eaten = false
--     return a
-- end

function carnivore.eat(a, animals, animal_positions)
    local index = a.c..":"..a.r
    for i,k in pairs(animal_positions[index]) do
        if a.eaten == false and a.energy < 900 then
            if animals[k] ~= nil and animals[k].herbivore then
                a.energy = a.energy + settings.meat_energy
                a.eaten = true
                local prey = animals[k]
                world.deregister_animal(prey.id, prey.c..":"..prey.r, animal_positions)
                animals[prey.id] = nil
            end
        end
    end
    if a.energy < 500 then
        a.eaten = false
    end
end

-- function carnivore.reproduce(a)
--     return animal.reproduce(a)
-- end

return carnivore

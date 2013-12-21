herbivore = {}

local settings = require('settings')

function herbivore.eat(a, plants)
    local index = a.c..":"..a.r
    if plants[index] ~= nil then
        a.energy = a.energy + settings.plant_energy
        plants[index] = nil
    end
end

return herbivore

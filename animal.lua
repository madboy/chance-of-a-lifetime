animal = {}

local utils = require('utils')
local settings = require('settings')
local world = require('world')
local carnivore = require('carnivore')
local herbivore = require('herbivore')

local function random_genes()
    local genes = {}
    for i=1,settings.genes do
        table.insert(genes, math.random(10))
    end
    return genes
end

function animal.make()
    local a = {}
    local c, r = utils.random_pos(settings.width, settings.height)
    a.c = c
    a.r = r
    a.dir = 0
    a.genes = random_genes()
    a.id = utils.create_id()
    return a
end

local function mutate(a)
    local gene = math.random(1, settings.genes)
    a.genes[gene] = math.max(1, a.genes[gene] + math.random(-1,1))
end

function animal.clone(a)
    local child = {}
    for k,v in pairs(a) do
        child[k] = v
    end
    child.genes = utils.copy_table(a.genes)
    child.id = utils.create_id()
    mutate(child)
    return child
end

function animal.reproduce(a, animals, animal_positions)
    if a.energy > a.reproduction_energy then
        a.energy = a.energy / 2
        local child = animal.clone(a)
        -- child.index = #animals + 1
        animals[child.id] = child
        -- table.insert(animals, child)
        world.register_animal(child, animal_positions)
    end
end

local function sum_genes(t)
end

function animal.move(animal)
    -- body
end

function animal.turn(animal)
    -- body
end

function animal.eat(a, plants, animals, animal_positions)
    if a.herbivore then
        herbivore.eat(a, plants)
    else
        carnivore.eat(a, animals, animal_positions)
    end
end

function animal.count_species(animals)
    -- body
end

return animal

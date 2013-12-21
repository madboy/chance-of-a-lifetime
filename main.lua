-- using inspect from, https://github.com/kikito/inspect.lua
local inspect = require('inspect')
local settings = require('settings')
local utils = require('utils')
local world = require('world')
local animal = require('animal')

SPECIES_COUNT = {}

function random_genes()
   genes = {}
   for i = 1,settings.genes do
      table.insert(genes, math.random(10))
   end
   return genes
end

function make_animal(species, energy)
   local animal = {}
   local c,r = utils.random_pos(settings.width,settings.height)
   animal["c"] = c
   animal["r"] = r
   animal["energy"] = energy
   animal["reproduction_energy"] = settings.reproduction_energy
   animal["dir"] = 0
   animal["genes"] = random_genes()
   animal["species"] = species
   animal["id"] = utils.create_id()
   if species < 4 then
      animal["herbivore"] = false
   else
      animal["herbivore"] = true
   end
   return animal
end

function move_animal(animal)
   local pos = animal.c..":"..animal.r
   if animal.dir >= 2 and animal.dir < 5 then
      animal.c = animal.c + 1
   elseif animal.dir == 1 or animal.dir == 5 then
      animal.c = animal.c
   else
      animal.c = animal.c - 1
   end
   animal.c = (animal.c + settings.width) % settings.width
   if animal.dir >= 0 and animal.dir < 3 then
      animal.r = animal.r - 1
   elseif animal.dir >= 4 and animal.dir < 7 then
      animal.r = animal.r + 1
   end
   animal.r = (animal.r + settings.height) % settings.height
   local new_pos = animal.c..":"..animal.r
   if pos ~= new_pos then
      world.change_registration(animal, pos, animal_positions)
   end

   animal.energy = animal.energy - 1
end

function sum_genes(t)
   sum = 0
   for _,v in ipairs(t) do
      sum = sum + v
   end
   return sum
end

function turn_animal(animal)
   sum_genes(animal.genes)
   r = math.random(sum)
   for i,v in ipairs(animal.genes) do
      r = r - v
      if r < 0 then
	 animal.dir = (animal.dir + i) % 8
	 if settings.debug then print("we are turning, we are turning", animal.dir, "is the new new") end
	 break
      end
   end
end

function love.load()
   math.randomseed(os.time())
   selection = 1

   -- assets
   imgf = {"mug_shot_1", "animal_1", "mug_shot_2", "animal_2", "mug_shot_3", "animal_3", "mug_shot_4", "animal_4", "mug_shot_5", "animal_5", "mug_shot_6", "animal_6", "mug_shot_7", "animal_7", "mug_shot_8", "animal_8", "plant", "jungle", "ground"}
   imgs = {}
   for _,v in ipairs(imgf) do
      imgs[v] = love.graphics.newImage("assets/"..v..".png")
   end
   for _,v in ipairs(imgs) do
      v:setFilter("nearest", "nearest")
   end

   generation = 0

   plants = world.create_plants()

   jungle = world.create_jungle()

   animals = {}
   animal_positions = {}
   for i = 1,8 do
      -- local idx = #animals + 1
      local animal = make_animal(i, 1000)
      animals[animal.id] = animal
      -- table.insert(animals, animal)
      world.register_animal(animal, animal_positions)
   end
end

function love.keypressed(key, unicode)
   if key == "`" then
      --debug = not debug
      print(inspect(animals))
      --print(inspect(animal_positions))
   end
   if key == " " then
      settings.paused = not settings.paused
   end
   if key == "right" and settings.game_started ~= true then
      selection = selection + 1
      selection = math.min(selection, 8)
   end
   if key == "left" and settings.game_started ~= true then
      selection = selection - 1
      selection = math.max(selection, 1)
   end
end

function love.update(dt)
   if settings.paused or settings.game_over then return end
   generation = generation + 1

   if settings.debug then print("Number of animals", #animals) end
   for k,v in pairs(animals) do
      if v.energy <= 0 then
         world.deregister_animal(v.id, v.c..":"..v.r, animal_positions)
         animals[v.id] = nil
         if settings.debug then print("Removing an animal, population down to", #animals) end
      end
      move_animal(v)
      turn_animal(v)
      animal.eat(v, plants, animals, animal_positions)
      animal.reproduce(v, animals, animal_positions)
   end
   world.add_plants(plants, jungle)
   settings.game_started = true
end

function love.draw()
   love.graphics.setBackgroundColor(255,255,255)
   -- draw the species
   love.graphics.setColor(135,135,135)
   love.graphics.rectangle("fill", 100*(selection-1), 0, 100, 100)

   SPECIES_COUNT = world.count_species(animals)
   for i=1,8 do
      love.graphics.setColor(255,255,255)
      love.graphics.draw(imgs["mug_shot_"..i], 100*(i-1), 0)
      love.graphics.setColor(0, 0, 0)
      love.graphics.print(SPECIES_COUNT[i], 100*(i-1)+10, 85)
   end

   -- draw the ground
   love.graphics.setColor(255,255,255)
   for r = 0, settings.height-1 do
      for c = 0,settings.width-1 do
	 x,y = utils.get_coord(c, r)
	 love.graphics.draw(imgs["ground"], x, y)
      end
   end

   -- draw the jungle
   love.graphics.setColor(255,255,255)

   for _,v in ipairs(jungle) do
      local x, y = utils.get_coord(v[1], v[2])
      love.graphics.draw(imgs["jungle"], x, y)
   end

   -- draw the plants
   love.graphics.setColor(255,255,255)
   for k in pairs(plants) do
      x,y = utils.get_coord(plants[k].c, plants[k].r)
      love.graphics.draw(imgs["plant"], x, y)
   end

   -- draw the animals
   love.graphics.setColor(255,255,255)
   for k,v in pairs(animals) do
      x, y = utils.get_coord(v.c, v.r)
      love.graphics.draw(imgs["animal_"..v.species], x, y)
   end

   love.graphics.setColor(0,0,0)
   love.graphics.print("Tick: "..generation, 0, 100)

   if settings.game_started == false then
      love.graphics.setColor(255,0,22)
      love.graphics.print("Select your species by using the arrow keys", 400, 400)
      love.graphics.print("Start the game by pressing space", 400, 415)
   end
end

local inspect = require('inspect')
debug = false
paused = true
game_over = false
game_started = false

WIDTH = 100
HEIGHT = 50
PLANT_ENERGY = 80
ANIMAL_ENERGY = 100
REPRODUCTION_ENERGY = 200
GENES = 8
JUNGLE_START = {c = 20, r = 10}
JUNGLE_SIZE = {w = 20, h = 20}
SPECIES_COUNT = {}

function random_pos(w, h)
   local width = math.random(w)
   local height = math.random(h)
   return width, height
end

function random_genes()
   genes = {}
   for i = 1,GENES do
      table.insert(genes, math.random(10))
   end
   return genes
end

function get_coord(c, r)
   local x = 8*(c)
   local y = 10*(r) + 100
   return x, y
end

function create_id()
   local id = ""
   for i=1,20 do
      local c = math.random(97,122)
      id = id..string.char(c)
   end
   return id
end

function make_animal(species, energy, idx)
   local animal = {}
   local c,r = random_pos(WIDTH,HEIGHT)
   animal["c"] = c
   animal["r"] = r
   animal["energy"] = energy
   animal["dir"] = 0
   animal["genes"] = random_genes()
   animal["species"] = species
   animal["index"] = idx
   animal["id"] = create_id()
   if species < 4 then
      animal["herbivore"] = false
   else
      animal["herbivore"] = true
   end
   return animal
end

function clone_animal(animal, idx)
   local child = {}
   child["c"] = animal.c
   child["r"] = animal.r
   child["energy"] = animal.energy
   child["dir"] = 0
   child["genes"] = copy_table(animal.genes)
   child["species"] = animal.species
   child["index"] = idx
   child["id"] = create_id()
   child["herbivore"] = animal.herbivore
   return child
end

function register_animal(animal)
   local index = animal.c..":"..animal.r
   if animal_positions[index] == nil then
      animal_positions[index] = {}
   end
   local id = animal.id
   animal_positions[index][id] = animal.index
end

function change_address(animal, old_pos)
   local id = animal.id
   animal_positions[old_pos][id] = nil
   register_animal(animal)
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
   animal.c = (animal.c + WIDTH) % WIDTH
   if animal.dir >= 0 and animal.dir < 3 then
      animal.r = animal.r - 1
   elseif animal.dir >= 4 and animal.dir < 7 then
      animal.r = animal.r + 1
   end
   animal.r = (animal.r + HEIGHT) % HEIGHT
   local new_pos = animal.c..":"..animal.r
   if pos ~= new_pos then
      change_address(animal, pos)
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
	 if debug then print("we are turning, we are turning", animal.dir, "is the new new") end
	 break
      end
   end
end

function eat_animal(animal)
   local index = animal.c..":"..animal.r
   if animal.herbivore and plants[index] ~= nil then
      animal.energy = animal.energy + PLANT_ENERGY
      plants[index] = nil
   end

   if animal.herbivore == false then
      local eaten = false
      for v,k in pairs(animal_positions[index]) do
	 if eaten == false and v ~= animal.id and animals[k] ~= nil and animals[k].herbivore then
	    animal.energy = animal.energy + ANIMAL_ENERGY
	    local prey = animals[k]
	    animal_positions[prey.c..":"..prey.r][prey.id] = nil
	    table.remove(animals, k)
	    eaten = true
	 end
      end
   end
end

function mutate_animal(animal)
   local gene = math.random(1,GENES)
   animal.genes[gene] = math.max(1, animal.genes[gene] + math.random(-1,1))
end

function reproduce_animal(animal)
   if animal.energy > REPRODUCTION_ENERGY then
      animal.energy = animal.energy / 2
      local idx = #animals + 1
      child = clone_animal(animal, idx)
      mutate_animal(child)
      table.insert(animals, child)
      register_animal(child)
   end
end

function add_plants()
   -- add plant in general area
   for i=1,1 do
      c, r = random_pos(WIDTH, HEIGHT)
      plants[c..":"..r] = {c = c, r = r}
   end

   -- add plant in jungle
   c = math.random(JUNGLE_START.c, JUNGLE_SIZE.w + JUNGLE_START.c)
   r = math.random(JUNGLE_START.r, JUNGLE_SIZE.h + JUNGLE_START.r)
   plants[c..":"..r] = {c = c, r = r}
end

function count_the_species(a)
   population = {0,0,0,0,0,0,0,0}
   for _,v in ipairs(a) do
      population[v.species] = population[v.species] + 1
   end
   return population
end

function copy_table(t)
   local new_t = {}
   for _,v in ipairs(t) do
      table.insert(new_t, v)
   end
   return new_t
end

function print_table(t)
   values = "["
   for _,v in ipairs(t) do
      values = values..v..", "
   end
   print(values.."]")
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

   plants = {}
   for i = 1,50 do
      c, r = random_pos(WIDTH, HEIGHT)
      plants[c..":"..r] = {c = c, r = r}
   end

   jungles = {}
   for r = JUNGLE_START.r,JUNGLE_SIZE.h + JUNGLE_START.r do
      for c = JUNGLE_START.c,JUNGLE_SIZE.w + JUNGLE_START.c do
   	 jungles[c..":"..r] = {c = c, r = r}
      end
   end

   animals = {}
   animal_positions = {}
   for i = 1,8 do
      local idx = #animals + 1
      local animal = make_animal(i, 1000, idx)
      table.insert(animals, animal)
      register_animal(animal)
   end
end

function love.keypressed(key, unicode)
   if key == "`" then
      --debug = not debug
      --print(inspect(animals))
      print(inspect(animal_positions))
   end
   if key == " " then
      paused = not paused
   end
   if key == "right" and game_started ~= true then
      selection = selection + 1
      selection = math.min(selection, 8)
   end
   if key == "left" and game_started ~= true then
      selection = selection - 1
      selection = math.max(selection, 1)
   end
end

function love.update(dt)
   if paused or game_over then return end
   generation = generation + 1

   if SPECIES_COUNT[selection] == 0 then
      game_over = true
   end
   
   if debug then print("Number of animals", #animals) end
   for i,v in ipairs(animals) do
      if v.energy <= 0 then
	 table.remove(animals, i)
	 if debug then print("Removing an animal, population down to", #animals) end
      end
      move_animal(v)
      turn_animal(v)
      eat_animal(v)
      reproduce_animal(v)
   end
   add_plants()
   game_started = true
end

function love.draw()
   love.graphics.setBackgroundColor(255,255,255)
   -- draw the species
   love.graphics.setColor(135,135,135)
   love.graphics.rectangle("fill", 100*(selection-1), 0, 100, 100)

   SPECIES_COUNT = count_the_species(animals)
   for i=1,8 do
      love.graphics.setColor(255,255,255)
      love.graphics.draw(imgs["mug_shot_"..i], 100*(i-1), 0)
      love.graphics.setColor(0, 0, 0)
      love.graphics.print(SPECIES_COUNT[i], 100*(i-1)+10, 85)
   end

   -- draw the ground
   love.graphics.setColor(255,255,255)
   for r = 0, HEIGHT-1 do
      for c = 0,WIDTH-1 do
	 x,y = get_coord(c, r)
	 love.graphics.draw(imgs["ground"], x, y)
      end
   end

   -- draw the jungle
   love.graphics.setColor(255,255,255)
   for k in pairs(jungles) do
      x,y = get_coord(jungles[k].c, jungles[k].r)
      love.graphics.draw(imgs["jungle"], x, y)
   end
   
   -- draw the plants
   love.graphics.setColor(255,255,255)
   for k in pairs(plants) do
      x,y = get_coord(plants[k].c, plants[k].r)
      love.graphics.draw(imgs["plant"], x, y)
   end

   -- draw the animals
   love.graphics.setColor(255,255,255)
   for _,v in ipairs(animals) do
      x, y = get_coord(v.c, v.r)
      love.graphics.draw(imgs["animal_"..v.species], x, y)
   end

   love.graphics.setColor(0,0,0)
   love.graphics.print("Generation: "..generation, 0, 100)

   if game_started == false then
      love.graphics.setColor(255,0,22)
      love.graphics.print("Select your species by using the arrow keys", 400, 400)
      love.graphics.print("Start the game by pressing space", 400, 415)
   end

   if game_over then
      love.graphics.setColor(0,0,0)
      love.graphics.print("GAME OVER", 400, 400)
   end
end

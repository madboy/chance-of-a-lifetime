debug = false
paused = false
time_lapse = false

WIDTH = 100
HEIGHT = 50
PLANT_ENERGY = 80
REPRODUCTION_ENERGY = 200
GENES = 8
COLORS = {{255,0,0},
	  {0,255,0},
	  {0,0,255},
	  {120,0,0},
	  {0,120,0},
	  {0,0,120},
	  {120,120,120},
	  {255,255,0}}
JUNGLE_START = {c = 20, r = 10}
JUNGLE_SIZE = {w = 20, h = 20}

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

function make_animal(species, energy)
   local animal = {}
   local c,r = random_pos(WIDTH,HEIGHT)
   animal["c"] = c
   animal["r"] = r
   animal["energy"] = energy
   animal["dir"] = 0
   animal["genes"] = random_genes()
   animal["species"] = species
   animal["color"] = COLORS[species]
   return animal
end

function clone_animal(animal)
   local child = {}
   child["c"] = animal.c
   child["r"] = animal.r
   child["energy"] = animal.energy
   child["dir"] = 0
   child["genes"] = animal.genes
   child["species"] = animal.species
   child["color"] = animal.color
   return child
end


function move_animal(animal)
   if debug then print("before:", animal.c, animal.r) end
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
   animal.energy = animal.energy - 1
   if debug then print("after:", animal.c, animal.r) end
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
   if plants[index] ~= nil then
      if debug then print("Woho, we have found food at", index) end
      animal.energy = animal.energy + PLANT_ENERGY
      plants[index] = nil
      if debug then print("New energy level is", animal.energy) end
   end
end

function mutate_animal(animal)
   local gene = math.random(1,GENES)
   animal.genes[gene] = math.max(1, animal.genes[gene] + math.random(-1,1))
end

function reproduce_animal(animal)
   if animal.energy > REPRODUCTION_ENERGY then
      if debug then print("Getting a child") end
      animal.energy = animal.energy / 2
      if debug then print("Energy", animal.energy) end
      child = clone_animal(animal)
      if debug then print_table(child.genes) end
      mutate_animal(child)
      if debug then print_table(child.genes) end
      table.insert(animals, child)
   end
end

function add_plants()
   -- add plant in general area
   c, r = random_pos(WIDTH, HEIGHT)
   plants[c..":"..r] = {c = c, r = r}

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

function print_table(t)
   values = "["
   for _,v in ipairs(t) do
      values = values..v..", "
   end
   print(values.."]")
end

function love.load()
   math.randomseed(os.time())

   -- assets
   imgf = {"mug_shot_1", "animal_1", "mug_shot_2", "animal_2", "animal_3", "animal_4", "animal_5", "animal_6", "animal_7", "animal_8", "plant"}
   imgs = {}
   for _,v in ipairs(imgf) do
      imgs[v] = love.graphics.newImage("assets/"..v..".png")
   end
   for _,v in ipairs(imgs) do
      v:setFilter("nearest", "nearest")
   end
   
   generation = 0
   ground = {189, 183, 107}

   plants = {}
   plant = {139, 0, 139}
   for i = 1,50 do
      c, r = random_pos(WIDTH, HEIGHT)
      plants[c..":"..r] = {c = c, r = r}
   end

   jungles = {}
   jungle = {34, 139, 34}
   for r = JUNGLE_START.r,JUNGLE_SIZE.h + JUNGLE_START.r do
      for c = JUNGLE_START.c,JUNGLE_SIZE.w + JUNGLE_START.c do
   	 jungles[c..":"..r] = {c = c, r = r}
      end
   end

   animals = {}
   animal = {255, 20, 147}
   for i = 1,8 do
      table.insert(animals, make_animal(i, 1000))
   end
end

function love.keypressed(key, unicode)
   if key == "`" then
      debug = not debug
   end
   if key == " " then
      paused = not paused
   end
end

function love.update(dt)
   if paused then return end
   generation = generation + 1
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
end

function love.draw()
   -- draw the species
   species_count = count_the_species(animals)
   for i=1,8 do
      love.graphics.setColor(COLORS[i])
      if i < 3 then
	 love.graphics.setColor(255,255,255)
	 love.graphics.draw(imgs["mug_shot_"..i], 100*(i-1), 0)
      else
	 love.graphics.rectangle("fill", 100*(i-1), 0, 100, 100)
      end
      --love.graphics.print(i, 100*i, 50)
      love.graphics.setColor(0, 0, 0)
      love.graphics.print(species_count[i], 100*(i-1), 50)
   end

   -- draw the ground
   love.graphics.setColor(ground)
   for r = 0, HEIGHT-1 do
      for c = 0,WIDTH-1 do
	 x,y = get_coord(c, r)
	 love.graphics.rectangle("fill", x, y, 8, 10)
      end
   end

   -- draw the jungle
   love.graphics.setColor(jungle)
   for k in pairs(jungles) do
      x,y = get_coord(jungles[k].c, jungles[k].r)
      love.graphics.rectangle("fill", x, y, 8, 10)
   end
   
   -- draw the plants
   love.graphics.setColor(255,255,255)
   for k in pairs(plants) do
      x,y = get_coord(plants[k].c, plants[k].r)
      love.graphics.draw(imgs["plant"], x, y)
      --love.graphics.rectangle("fill", x, y, 8, 10)
   end

   -- draw the animals
   --love.graphics.setColor(animal)
   love.graphics.setColor(255,255,255)
   for _,v in ipairs(animals) do
      --love.graphics.setColor(v.color)
      x, y = get_coord(v.c, v.r)
      love.graphics.draw(imgs["animal_"..v.species], x, y)
   end

   love.graphics.setColor(0,0,0)
   love.graphics.print("Generation: "..generation, 0, 100)
end

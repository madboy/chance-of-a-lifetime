debug = false
paused = false
WIDTH = 100
HEIGHT = 50
PLANT_ENERGY = 100
REPRODUCTION_ENERGY = 200
GENES = 8

function random_pos(w, h)
   local width = math.random(w)
   local height = math.random(h)
   return width, height
end

function random_genes()
   genes = {}
   for i = 1,GENES do
      genes[#genes+1] = math.random(10)
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
   animal["color"] = {math.random(255), math.random(255), math.random(255)}
   return animal
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
   animal.genes[gene] = animal.genes[gene] + math.random(-1,1)
end

function reproduce_animal(animal)
   if animal.energy > REPRODUCTION_ENERGY then
      if debug then print("Getting a child") end
      animal.energy = animal.energy / 2
      if debug then print("Energy", animal.energy) end
      child = make_animal("child", animal.energy)
      if debug then print_table(child.genes) end
      mutate_animal(child)
      if debug then print_table(child.genes) end
      animals[#animals+1] = child
   end
end

function add_plants()
   for i = 1,2 do
      c, r = random_pos(WIDTH, HEIGHT)
      plants[c..":"..r] = {c = c, r = r}
   end
end

function print_table(t)
   values = "["
   for _,v in ipairs(t) do
      values = values..v..", "
   end
   print(values.."]")
end

function love.load()
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
   for r = 10,20 do
      for c = 50, 60 do
	 jungles[c..":"..r] = {c = c, r = r}
      end
   end

   animals = {}
   animal = {255, 20, 147}
   for i = 1,1 do
      animals[#animals+1] = make_animal("parent", 1000)
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
   colors = {{255,0,0},
	     {0,255,0},
	     {0,0,255},
	     {120,0,0},
	     {0,120,0},
	     {0,0,120},
	     {120,120,120},
	     {255,255,0}}
   -- draw the species
   for i=0,7 do
      love.graphics.setColor(colors[i+1])
      love.graphics.rectangle("fill", 100*i, 0, 100, 100)
      love.graphics.setColor(255,255,255)
      love.graphics.print(i, 100*i, 50)
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
   love.graphics.setColor(plant)
   for k in pairs(plants) do
      x,y = get_coord(plants[k].c, plants[k].r)
      love.graphics.rectangle("fill", x, y, 8, 10)
   end

   -- draw the animals
   --love.graphics.setColor(animal)
   for _,v in ipairs(animals) do
      love.graphics.setColor(v.color)
      x, y = get_coord(v.c, v.r)
      love.graphics.rectangle("fill", x, y, 8, 10)
   end

   love.graphics.setColor(0,0,0)
   love.graphics.print("Generation: "..generation, 0, 100)
end
debug = true
WIDTH = 100
HEIGHT = 50

function random_pos(w, h)
   local width = math.random(w)
   local height = math.random(h)
   return width, height
end

function random_genes()
   genes = {}
   for i = 1,8 do
      genes[#genes+1] = math.random(10)
   end
   return genes
end

function get_coord(c, r)
   local x = 8*(c)
   local y = 10*(r) + 100
   return x, y
end

function make_animal()
   local animal = {}
   local c,r = random_pos(WIDTH,HEIGHT)
   animal["c"] = c
   animal["r"] = r
   animal["energy"] = 1000
   animal["dir"] = 0
   animal["genes"] = random_genes
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
   print(sum_genes(animal.genes))
end

function print_table(t)
   for _,v in ipairs(t) do
      print(v)
   end
end

function love.load()
   game_clock = 0
   ground = {189, 183, 107}

   plants = {}
   plant = {139, 0, 139}
   for i = 1,10 do
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
      animals[#animals+1] = make_animal()
   end
end

function love.keypressed(key, unicode)
end

function love.update(dt)
   game_clock = game_clock + dt
   if game_clock > 0.5 then
      for _,v in ipairs(animals) do
	 move_animal(v)
      end
      game_clock = 0
   end
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
   love.graphics.setColor(animal)
   for _,v in ipairs(animals) do
      x, y = get_coord(v.c, v.r)
      love.graphics.rectangle("fill", x, y, 8, 10)
   end
end

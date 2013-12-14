debug = false
WIDTH = 100
HEIGHT = 50

function random_pos(w, h)
   local width = math.random(w)
   local height = math.random(h)
   return height, width
end

function random_genes()
   genes = {}
   for i = 1,8 do
      genes[#genes+1] = math.random(10)
   end
   return genes
end

function make_animal()
   local animal = {}
   local x,y = random_pos(WIDTH,HEIGHT)
   animal["x"] = x
   animal["y"] = y
   animal["energy"] = 1000
   animal["dir"] = 0
   animal["genes"] = random_genes
   return animal
end

function move_animal(animal)
   print(animal.x, animal.y)
   if animal.dir >= 2 and animal.dir < 5 then
      animal.x = animal.x + 1
   elseif animal.dir == 1 or animal.dir == 5 then
      animal.x = animal.x
   else
      animal.x = animal.x - 1
   end
   animal.x = (animal.x + WIDTH) % WIDTH
   if animal.dir >= 0 and animal.dir < 3 then
      animal.y = animal.y - 1
   elseif animal.dir >= 4 and animal.dir < 7 then
      animal.y = animal.y + 1
   end
   animal.y = (animal.y + HEIGHT) % HEIGHT
   print(animal.x, animal.y)
end

function print_table(t)
   for _,v in ipairs(t) do
      print(v)
   end
end

function love.load()
   ground = {189, 183, 107}
   plant = {139, 0, 139}
   world = {}
   for r = 1,50 do
      for c = 1,100 do
         world[r..":"..c] = {x = 8*(c-1), y = 10*(r-1) + 100, c = ground}
      end
   end
   jungles = {}
   jungle = {34, 139, 34}
   for r = 10,20 do
      for c = 50,60 do
	 jungles[r..":"..c] = {x = 8*(c-1), y = 10*(r-1) + 100, c = jungle}
	 --world[r..":"..c].c = jungle
      end
   end
   for i = 1,10 do
      x,y = random_pos(100, 50)
      world[x..":"..y].c = plant
   end
   animal = make_animal()
   world[animal.x..":"..animal.y].c = {255,20,147}
end

function love.keypressed(key, unicode)
end

function love.update(dt)
   move_animal(animal)
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

   -- draw the world
   for r = 1,50 do
      for c = 1,100 do
	 -- if c % 2 == 0 then
	 --    love.graphics.setColor(255,255,255)
	 -- else
	 --    love.graphics.setColor(0,255,0)
	 -- end
	 --love.graphics.rectangle("fill", 8*c, 10*r + 100, 8, 10)
	 index = r..":"..c
	 love.graphics.setColor(world[index].c)
	 love.graphics.rectangle("fill", world[index].x, world[index].y, 8, 10)
	 --love.graphics.rectangle("fill", 8*(c-1), 10*(r-1) + 100, 8, 10)
      end
   end
end

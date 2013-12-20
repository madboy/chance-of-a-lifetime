utils = {}

local alphabet = {'0', '1', '2', '3', '4', '5',
                  '6', '7', '8', '9', 'a', 'b',
                  'c', 'd', 'e', 'f', 'g', 'h',
                  'i', 'j', 'k', 'l', 'm', 'n',
                  'o', 'p', 'q', 'r', 's', 't',
                  'u', 'v', 'w', 'x', 'y', 'z',
                  'A', 'B', 'C', 'D', 'E', 'F',
                  'G', 'H', 'I', 'J', 'K', 'L',
                  'M', 'N', 'O', 'P', 'Q', 'R',
                  'S', 'T', 'U', 'V', 'W', 'X', 'Y', 'Z'}

local grid_width = 8
local grid_height = 10
local header_height = 100

function utils.get_coord(c, r)
   local x = grid_width*(c)
   local y = grid_height*(r) + header_height
   return x, y
end

function utils.random_pos(w,h)
   local width = math.random(w)
   local height = math.random(h)
   return width, height
end

function utils.copy_table(t)
   local new_t = {}
   for _,v in ipairs(t) do
      table.insert(new_t, v)
   end
   return new_t
end

function utils.create_id()
    local id = ""
    for i=1,20 do
        local idx = math.random(1,#alphabet)
        local c = alphabet[idx]
        id = id..(c)
    end
    return id
end

return utils

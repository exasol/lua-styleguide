-- This example demonstrates how to use Lua metatables to outfit a table with getter function for every field in the
-- table. It is intentionally kept minimal to focus on the metatable concept.

-- In a real-world scenario you would of course add error handling in case someone calls a getter for a non-existent
-- field.

local vegetables = {carrot = "orange", cucumber = "green", potato = "yellow"}

setmetatable(vegetables,
    {
        __index = function(tbl, key)
            local vegetable = string.gsub(key, "get_", "")
            return function() return tbl[vegetable]  end
        end
    }
)

print(vegetables.get_carrot())
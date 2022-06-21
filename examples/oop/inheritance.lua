--- Abstract base class of database objects.
-- Note that this class has no `new` method, making it obvious that you can't instantiate it.
-- @classmod AbstractDatabaseObject
-- @field name name that identifies the object
local AbstractDatabaseObject = {}

function AbstractDatabaseObject:_init(name)
    self._name = name
end

--- Get the name of the database object.
-- @treturn string name of the database object
function AbstractDatabaseObject:get_name()
    return self._name
end

--- Class representing a database table.
-- Derived from the `AbstractDatabaseObject`.
-- @classmod AbstractDatabaseObject
-- @field columns colum definitions
local Table = {}
Table.__index = Table
setmetatable(Table, {__index = AbstractDatabaseObject})

--- Create a new instance of a database table.
-- @tparam table list of columns with the column name as key and type as value
-- @treturn Table new instance
function Table:new(name, columns)
    assert(columns ~= nil, "A table needs at least one column.")
    local instance = setmetatable({}, self)
    instance:_init(name, columns)
    return instance
end

function Table:_init(name, columns)
    AbstractDatabaseObject._init(self, name)
    self._columns = columns
end

function Table:__tostring()
    local output = self:get_name() .. " ("
    local i = 0
    for column, datatype in pairs(self._columns) do
        output = output .. string.format("%s%s (%s)", (i > 0 and ", " or ""), column, datatype)
        i = i + 1
    end
    return output .. ")"
end

-- Example usage of the Table class
local the_table = Table:new("T", {C1 = "VARCHAR(10)", C2 = "BOOLEAN"})
print(the_table)
sssssssssssssssssssssssssssssss
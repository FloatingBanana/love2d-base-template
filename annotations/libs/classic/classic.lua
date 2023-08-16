--- @meta

--- Base class for all other classes. Uses the classic.lua library.
--- @class Object
local Object = {}


--- Creates a child class of this object.
--- @return Object|any
function Object:extend() end


--- Checks if this object belongs to this class.
--- @param T Object Class.
--- @return boolean
function Object:is(T) end

return Object
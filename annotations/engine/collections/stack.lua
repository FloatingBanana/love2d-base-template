--- @meta

---
--- A list of data that follows the "Last In, First Out" (LIFO) principle.
---
--- @class Stack: {[integer]: any}
---
--- @operator call: Stack
local Stack = {}


--- Pushes an item to the top of the stack
--- @param item any: Item to be pushed
function Stack:push(item) end


--- Removes the topmost item and returns it
--- @return any: The popped item
function Stack:pop() end


--- Returns the topmost item without removing it
--- @return any: The topmost item
function Stack:peek() end


return Stack
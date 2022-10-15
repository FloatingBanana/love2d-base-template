--- @meta

---
--- A list of data that follows the "First In, First Out" (FIFO) principle.
---
--- @class Queue
---
--- @operator call: Queue
local Queue = {}


--- Pushes an item to the top of the queue
--- @param item any: Item to be pushed
function Queue:push(item) end


--- Removes the bottommost item and returns it
--- @return any: The popped item
function Queue:pop() end


--- Returns the bottommost item without removing it
--- @return any: The bottommost item
function Queue:peek() end


--- Get the number of items in this queue
--- @return number: The number of items
function Queue:getLength() end


--- Gets item at the specified index
--- @param index number: Index of item
--- @return any: The item at the specified index
function Queue:getItem(index) end


--- Loops through all items in this Queue. Use this instead of `ipairs`
--- @return function: Iterator
--- @return Queue: This queue
--- @return number: First index
function Queue:iterate() end


return Queue
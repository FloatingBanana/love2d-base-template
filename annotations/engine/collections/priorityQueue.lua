--- @meta

---
--- A queue that's sorted based on the specified priority of each element. It uses the binary heap algorithm
---
--- @class PriorityQueue
---
--- @operator call: PriorityQueue
local PriorityQueue = {}


--- Pushes an item to the queue
--- @param priority integer: Item priority
--- @param item any: Item to be pushed
function PriorityQueue:push(priority, item) end


--- Removes the item with highest priority and returns it
--- @return number: Item priority
--- @return any: The popped item
function PriorityQueue:pop() end


--- Returns the item with highest priority without removing it
--- @return number: Item priority
--- @return any: The highest priotity item
function PriorityQueue:peek() end


--- Changes priority of the specified item
--- @param index number: Index of item
--- @param priority number: Priority to be set
function PriorityQueue:changePriority(index, priority) end


--- Removes the specified item and returns it
--- @param index number: Index of item
--- @return number: Item priority
--- @return any: The removed item
function PriorityQueue:remove(index) end


--- Get the number of items in this queue
--- @return number: The number of items
function PriorityQueue:getLength() end


--- Gets item at the specified index
--- @param index number: Index of item
--- @return number: Item priority
--- @return any: The item at the specified index
function PriorityQueue:getItem(index) end


--- Loops through all items in this queue. Use this instead of `ipairs`
---
--- The loop signature should be:
--- ```lua
--- for index, priority, item in this:iterate() do end`
--- ```
--- @return function: Iterator
--- @return PriorityQueue: This queue
--- @return number: First index
function PriorityQueue:iterate() end


return PriorityQueue
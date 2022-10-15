--- @meta

---
--- A double queue that can be pushed/popped from both sides.
---
--- @class Deque
---
--- @operator call: Deque
local Deque = {}


--- Pushes an item to the left side of the deque
--- @param item any: Item to be pushed
function Deque:pushLeft(item) end


--- Pushes an item to the right side of the deque
--- @param item any: Item to be pushed
function Deque:pushRight(item) end


--- Removes the leftmost item and returns it
--- @return any: The popped item
function Deque:popLeft() end


--- Removes the rightmost item and returns it
--- @return any: The popped item
function Deque:popRight() end


--- Returns the leftmost item without removing it
--- @return any: The leftmost item
function Deque:peekLeft() end


--- Returns the rightmost item without removing it
--- @return any: The rightmost item
function Deque:peekRight() end


--- Get the number of items in this deque
--- @return number: The number of items
function Deque:getLength() end


--- Gets item at the specified index
--- @param index number: Index of item
--- @return any: The item at the specified index
function Deque:getItem(index) end


--- Loops through all items in this deque. Use this instead of `ipairs`
--- @return function: Iterator
--- @return Deque: This deque
--- @return number: First index
function Deque:iterate() end

return Deque
--- @meta

---
--- A 3D vector that can represent a position, direction, color, etc
---
--- @class Vector3: CStruct
---
--- @field lenght number: The magnitude of this vector
--- @field lengthSquared number: The squared magnitude of this vector
--- @field normalized Vector3: Gets a copy of this vector with magnitude of 1
--- @field inverse Vector3: Gets a copy of this vector with the components inverted (i.e `1 / value`)
--- @field x number: X axis of the vector
--- @field y number: Y axis of the vector
--- @field z number: Z axis of the vector
---
--- @field width number: Alias to X
--- @field height number: Alias to Y
--- @field depht number: Alias to Z
--- @field red number: Alias to X
--- @field green number: Alias to Y
--- @field blue number: Alias to Z
--- @field pitch number: Alias to X
--- @field yaw number: Alias to Y
--- @field roll number: Alias to Z
---
--- @operator call: Vector3
--- @operator add: Vector3
--- @operator sub: Vector3
--- @operator mul: Vector3
--- @operator div: Vector3
--- @operator unm: Vector3
local Vector3 = {}


--- Peforms an addition operation on this vector (`self + other`)
--- @param other Vector3 | number: The right hand operand
--- @return Vector3: This vector
function Vector3:add(other) end


--- Peforms a subtraction operation on this vector (`self - other`)
--- @param other Vector3 | number: The right hand operand
--- @return Vector3: This vector
function Vector3:subtract(other) end


--- Peforms a multiplication operation on this vector (`self * other`)
--- @param other Vector3 | number: The right hand operand
--- @return Vector3: This vector
function Vector3:multiply(other) end


--- Peforms a division operation on this vector (`self / other`)
--- @param other Vector3 | number: The right hand operand
--- @return Vector3: This vector
function Vector3:divide(other) end


--- Negates all components of this vector
--- @return Vector3: This vector
function Vector3:negate() end


--- Make this vector have a magnitude of 1
--- @return Vector3: This vector
function Vector3:normalize() end


--- Invert (i.e make `1 / value`) all components of this vector
--- @return Vector3: This vector
function Vector3:invert() end


--- Reflect this vector along a `normal`
--- @param normal Vector3: Reflection normal
--- @return Vector3: This vector
function Vector3:reflect(normal) end


--- Clamp this vector's component between `min` and `max`
--- @param min Vector3: Minimum value
--- @param max Vector3: Maximum value
--- @return Vector3: This vector
function Vector3:clamp(min, max) end


--- Transform this vector by a matrix or quaternion
--- @param value Matrix | Quaternion: The transformation matrix or quaternion
--- @return Vector3: This vector
function Vector3:transform(value) end


--- Transform this vector from world space to screen space
--- @param screenMatrix Matrix: The full transformation matrix (`projection * view * world`)
--- @param screenSize Vector2: The resolution of the screen
--- @param minDepth number: The smallest depth value allowed
--- @param maxDepth number: The greatest depht value allowed
--- @return Vector3: This vector
function Vector3:worldToScreen(screenMatrix, screenSize, minDepth, maxDepth) end


--- Transform this vector from screen space to world space
--- @param screenMatrix Matrix: The full transformation matrix (`projection * view * world`)
--- @param screenSize Vector2: The resolution of the screen
--- @param minDepth number: The smallest depth value allowed
--- @param maxDepth number: The greatest depht value allowed
--- @return Vector3: This vector
function Vector3:screenToWorld(screenMatrix, screenSize, minDepth, maxDepth) end


--- Checks if any of the components is equal to `Nan`
--- @return boolean
function Vector3:isNan() end


--- Creates a new vector with the same component values of this one
--- @return Vector3: The new vector
function Vector3:clone() end


--- Deconstruct this vector into individual values
--- @return number X, number Y, number Z
function Vector3:split() end

----------------------------
----- Static functions -----
----------------------------


--- Calculates the dot product between two vectors
--- @param v1 Vector3: The first vector
--- @param v2 Vector3: the second vector
--- @return number: Result
function Vector3.dot(v1, v2) end


--- Calculates the cross product between two vectors
--- @param v1 Vector3: The first vector
--- @param v2 Vector3: the second vector
--- @return Vector3: Result
function Vector3.cross(v1, v2) end


--- Calculates the squared distance between two vectors
--- @param v1 Vector3: The first vector
--- @param v2 Vector3: the second vector
--- @return number: The resulting distance
function Vector3.distanceSquared(v1, v2) end


--- Calculates the distance between two vectors
--- @param v1 Vector3: The first vector
--- @param v2 Vector3: the second vector
--- @return number: The resulting distance
function Vector3.distance(v1, v2) end


--- Creates a vector with the minimum values of two vectors
--- @param v1 Vector3: The first vector
--- @param v2 Vector3: The second vector
--- @return Vector3: The minimum vector
function Vector3.min(v1, v2) end


-- Creates a vector with the maximum values of two vectors
--- @param v1 Vector3: The first vector
--- @param v2 Vector3: The second vector
--- @return Vector3: The maximum vector
function Vector3.max(v1, v2) end

return Vector3
--- @meta

---
--- A 2D vector that can represent a position, direction, etc
---
--- @class Vector2: CStruct
---
--- @field lenght number: The magnitude of this vector
--- @field lengthSquared number: The squared magnitude of this vector
--- @field normalized Vector3: Gets a new vector with magnitude of 1 pointing to the same direction of this one
--- @field inverse Vector3: Gets a new vector with the components inverted (i.e `1 / value`)
--- @field angle number: The angle this vector is pointing at
--- @field x number: X axis of the vector
--- @field y number: Y axis of the vector
---
--- @field width number: Alias to X
--- @field height number: Alias to Y
--- @field u number: Alias to X
--- @field v number: Alias to Y
---
--- @operator call:Vector2
--- @operator add:Vector2
--- @operator sub:Vector2
--- @operator mul:Vector2
--- @operator div:Vector2
--- @operator unm:Vector2
local Vector2 = {}


--- Peforms an addition operation on this vector (`self + other`)
--- @param other Vector2 | number: The right hand operand
--- @return Vector2: This vector
function Vector2:add(other) end


--- Peforms a subtraction operation on this vector (`self - other`)
--- @param other Vector2 | number: The right hand operand
--- @return Vector2: This vector
function Vector2:subtract(other) end


--- Peforms a multiplication operation on this vector (`self * other`)
--- @param other Vector2 | number: The right hand operand
--- @return Vector2: This vector
function Vector2:multiply(other) end


--- Peforms a division operation on this vector (`self / other`)
--- @param other Vector2 | number: The right hand operand
--- @return Vector2: This vector
function Vector2:divide(other) end


--- Negates all components of this vector
--- @return Vector2: This vector
function Vector2:negate() end


--- Make this vector have a magnitude of 1
--- @return Vector2: This vector
function Vector2:normalize() end


--- Invert (i.e make `1 / value`) all components of this vector
--- @return Vector2: This vector
function Vector2:invert() end


--- Reflect this vector along a `normal`
--- @param normal Vector2: Reflection normal
--- @return Vector2: This vector
function Vector2:reflect(normal) end


--- Clamp this vector's component between `min` and `max`
--- @param min Vector2: Minimum value
--- @param max Vector2: Maximum value
--- @return Vector2: This vector
function Vector2:clamp(min, max) end


--- Make this vector point to the specified `angle`
--- @param angle number: The angle this vector will point at
--- @return Vector2: This vector
function Vector2:setAngle(angle) end


--- Rotate this vector relative to the current angle
--- @param angle number: The angle to be applied
--- @return Vector2: This vector
function Vector2:rotateBy(angle) end


--- Checks if any of the components is equal to `Nan`
--- @return boolean
function Vector2:isNan() end


--- Creates a new vector with the same component values of this one
--- @return Vector2: The new vector
function Vector2:clone() end


--- Deconstruct this vector into individual values
--- @return number X, number Y
function Vector2:split() end


----------------------------
----- Static functions -----
----------------------------

--- Calculates the dot product between two vectors
--- @param v1 Vector2: The first vector
--- @param v2 Vector2: the second vector
--- @return number: Result
function Vector2.dot(v1, v2) end


--- Creates a new vector with the specified angle and magnitude
--- @param angle number: The angle of vector
--- @param magnitude number: The magnitude of vector
--- @return Vector2: Result
function Vector2.createAngled(angle, magnitude) end


--- Calculates the squared distance between two vectors
--- @param v1 Vector2: The first vector
--- @param v2 Vector2: the second vector
--- @return number: The resulting distance
function Vector2.distanceSquared(v1, v2) end


--- Calculates the distance between two vectors
--- @param v1 Vector2: The first vector
--- @param v2 Vector2: the second vector
--- @return number: The resulting distance
function Vector2.distance(v1, v2) end


--- Creates a vector with the minimum values of two vectors
--- @param v1 Vector2: The first vector
--- @param v2 Vector2: The second vector
--- @return Vector2: The minimum vector
function Vector2.min(v1, v2) end


--- Creates a vector with the maximum values of two vectors
--- @param v1 Vector2: The first vector
--- @param v2 Vector2: The second vector
--- @return Vector2: The maximum vector
function Vector2.max(v1, v2) end

return Vector2
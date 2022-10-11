--- @meta

---
--- An object that represents a 3D rotation
---
--- @class Quaternion: CStruct
---
--- @field x number: The X axis of this quaternion
--- @field y number: The Y axis of this quaternion
--- @field z number: The Z axis of this quaternion
--- @field w number: The rotation component of this quaternion
--- @field normalized Quaternion: Gets a new, normalized version of this quaternion
--- @field length number: The magnitude of this quaternion
--- @field lengthSquared number: The squared magnitude of this quaternion
---
--- @operator call: Quaternion
--- @operator add: Quaternion
--- @operator sub: Quaternion
--- @operator mul: Quaternion
--- @operator div: Quaternion
local Quaternion = {}

--------------------
------ Methods------
--------------------

--- Peforms an addition operation on this quaternion (`self + other`)
--- @param other Quaternion: The right hand operand
--- @return Quaternion: This quaternion
function Quaternion:add(other) end


--- Peforms a subtraction operation on this quaternion (`self - other`)
--- @param other Quaternion: The right hand operand
--- @return Quaternion: This quaternion
function Quaternion:subtract(other) end


--- Peforms a multiplication operation on this quaternion (`self * other`)
--- @param other Quaternion | number: The right hand operand
--- @return Quaternion: This quaternion
function Quaternion:multiply(other) end


--- Peforms a division operation on this quaternion (`self / other`)
--- @param other Quaternion | number: The right hand operand
--- @return Quaternion: This quaternion
function Quaternion:divide(other) end


--- Make this quaternion have a magnitude of 1
--- @return Quaternion: This quaternion
function Quaternion:normalize() end


--- Creates a new quaternion with the same component values of this one
--- @return Quaternion: The new quaternion
function Quaternion:clone() end


--- Deconstruct this quaternion into individual values
--- @return number X, number Y, number Z, number W
function Quaternion:split() end

--------------------------------
------ Static functions---------
--------------------------------

--- Creates a quaternion with components (X=0, Y=0, Z=0, W=1)
--- @return Quaternion
function Quaternion.identity() end


--- Creates a quaternion representing a linear interpolation between two quaternions
--- @param q1 Quaternion: Initial value
---	@param q2 Quaternion: Final value
---	@param progress number: Interpolation progress (0-1)
--- @return Quaternion: The interpolated quaternion
function Quaternion.lerp(q1, q2, progress) end



--- Creates a quaternion representing a spherical interpolation between two quaternions
--- @param q1 Quaternion: Initial value
---	@param q2 Quaternion: Final value
---	@param amount number: Interpolation progress (0-1)
--- @return Quaternion: The interpolated quaternion
function Quaternion.slerp(q1, q2, amount) end


--- Calculates the dot product between two quaternions
--- @param v1 Quaternion: First quaternion
--- @param v2 Quaternion: Second quaternion
--- @return Quaternion: Result
function Quaternion.dot(v1, v2) end


--- Creates a quaternion rotated by an `angle` around an `axis` 
--- @param axis Quaternion: The axis of rotation
--- @param angle Quaternion: The angle of rotation
--- @return Quaternion: Result
function Quaternion.createFromAxisAngle(axis, angle) end


--- Creates a quaternion with the equivalent yaw, pitch and roll
--- @param yaw number: Yaw around the Y axis
--- @param pitch number: Pitch around the X axis
--- @param roll number: Roll around the Z axis
--- @return Quaternion: Result
function Quaternion.createFromYawPitchRoll(yaw, pitch, roll) end


--- Creates a quaternion from a Matrix
--- @param mat Matrix: The rotation matrix
--- @return Quaternion: Result
function Quaternion.createFromRotationMatrix(mat) end


return Quaternion
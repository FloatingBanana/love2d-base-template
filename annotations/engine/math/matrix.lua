--- @meta

---
--- A right-handed 4x4 matrix. Mostly used to store 3D transformations.
---
--- @class Matrix: CStruct
---
--- @field translation Vector3: The translation part of this matrix (m41, m42, m43)
--- @field forward Vector3: The forward direction of this matrix (m31, m32, m33)
--- @field up Vector3: The up direction of this matrix (m21, m22, m23)
--- @field right Vector3: The right direction of this matrix (m11, m12, m13)
--- @field backward Vector3: The backward direction of this matrix (-m31, -m32, -m33)
--- @field down Vector3: The down direction of this matrix (-m21, -m22, -m23)
--- @field left Vector3: The left direction of this matrix (-m11, -m12, -m13)
---
--- @field scale Vector3: Gets the scaling factor of this matrix
--- @field rotation Quaternion: Gets the rotation factor of this matrix
--- @field transposed Matrix: Gets a copy of this matrix with the components transposed
--- @field inverse Matrix: Gets a copy of this matrix with the components inverted
--- @field m11 number
--- @field m12 number
--- @field m13 number
--- @field m14 number
--- @field m21 number
--- @field m22 number
--- @field m23 number
--- @field m24 number
--- @field m31 number
--- @field m32 number
--- @field m33 number
--- @field m34 number
--- @field m41 number
--- @field m42 number
--- @field m43 number
--- @field m44 number
---
--- @operator call: Matrix
--- @operator add: Matrix
--- @operator sub: Matrix
--- @operator mul: Matrix
--- @operator div: Matrix
--- @operator unm: Matrix
--- @operator len: number
local Matrix = {}


---------------------
------ Methods ------
---------------------

--- Peforms an addition operation on this matrix (`self + other`)
--- @param other Matrix | number: The right hand operand
--- @return Matrix: This matrix
function Matrix:add(other) end


--- Peforms a subtraction operation on this matrix (`self - other`)
--- @param other Matrix | number: The right hand operand
--- @return Matrix: This matrix
function Matrix:subtract(other) end


--- Peforms a multiplication operation on this matrix (`self * other`)
--- @param other Matrix | number: The right hand operand
--- @return Matrix: This matrix
function Matrix:multiply(other) end


--- Peforms a division operation on this matrix (`self / other`)
--- @param other Matrix | number: The right hand operand
--- @return Matrix: This matrix
function Matrix:divide(other) end


--- Negates all components of this matrix
--- @return Matrix: This matrix
function Matrix:negate() end


--- Swap the rows and colums of this matrix
--- @return Matrix: This matrix
function Matrix:transpose() end


--- Invert all components of this matrix
--- @return Matrix: This matrix
function Matrix:invert() end


--- Internaly converts this matrix to a 3x3 matrix
---
--- Only use this method if you want to send this matrix to a shader as a `mat3` uniform
--- @return Matrix: This matrix
function Matrix:to3x3() end


--- Checks if the translation, scale and rotation can be extracted from this matrix
--- @return boolean: `true` if this matrix can be decomposed, `false` otherwise
function Matrix:isDecomposable() end


--- Extracts the translation, scale and rotation of this matrix
--- @return Vector3 Translation, Vector3 Scale, Quaternion Rotation
function Matrix:decompose() end


--- Creates a new matrix with the same component values of this one
--- @return Matrix: The new matrix
function Matrix:clone() end


--- Deconstruct this matrix into individual values
--- @return number m11, number m12, number m13, number m14, number m21, number m22, number m23, number m24, number m31, number m32, number m33, number m34, number m41, number m42, number m43, number m44
function Matrix:split() end


----------------------------
----- Static functions -----
----------------------------

--- Creates an identity matrix
--- @return Matrix
function Matrix.identity() end


--- Creates a world matrix
--- @param position Vector3: The world position
--- @param forward Vector3: The forward direction
--- @param up Vector3: The up direction
--- @return Matrix: The resulting world matrix
function Matrix.createWorld(position, forward, up) end


--- Creates a matrix rotated by an `angle` around an `axis`
--- @param axis Vector3: The axis of rotation
--- @param angle number: The angle of rotation
--- @return Matrix: Result
function Matrix.createFromAxisAngle(axis, angle) end


--- Creates a rotation matrix with the equivalent yaw, pitch and roll
--- @param yaw number: Yaw around the Y axis
--- @param pitch number: Pitch around the X axis
--- @param roll number: Roll around the Z axis
--- @return Matrix: Result
function Matrix.createFromYawPitchRoll(yaw, pitch, roll) end


--- Creates a rotation matrix from a Quaternion
--- @param quat Quaternion: The Quaternion representing the rotation
--- @return Matrix: Result
function Matrix.createFromQuaternion(quat) end


--- Creates a view matrix looking at a specified direction
--- @param position Vector3: The view position
--- @param direction Vector3: The view direction
--- @param up Vector3: A vector pointing up from view's position
--- @return Matrix: Result
function Matrix.createLookAtDirection(position, direction, up) end


--- Creates a view matrix looking at a specified target
--- @param position Vector3: The view position
--- @param target Vector3: The view target
--- @param up Vector3: A vector pointing up from view's position
--- @return Matrix: Result
function Matrix.createLookAt(position, target, up) end


--- Creates a spherical billboard matrix that rotates around a specified position
--- @param objectPosition Vector3: Billboard position
--- @param cameraPosition Vector3: The view position
--- @param cameraUp Vector3: A vector pointing up from view's position
--- @param cameraForward Vector3: A vector pointing forward from view's position
--- @return Matrix: Result
function Matrix.createBillboard(objectPosition, cameraPosition, cameraUp, cameraForward) end


--- Creates a cylindrical billboard matrix that rotates around a specified axis
--- @param objectPosition Vector3: Billboard position
--- @param cameraPosition Vector3: The view position
--- @param rotateAxis Vector3: Axis of billboard rotation
--- @param cameraForward Vector3: A vector pointing forward from view's position
--- @param objectForward Vector3: A vector pointing forward from billboard's position
--- @return Matrix: Result
function Matrix.createConstrainedBillboard(objectPosition, cameraPosition, rotateAxis, cameraForward, objectForward) end


--- Creates an orthographic projection matrix
--- @param width number: Width of the view volume
--- @param height number: Height of the view volume
--- @param near number: Near plane depht
--- @param far number: Far plane depth
--- @return Matrix: Result
function Matrix.createOrtographic(width, height, near, far) end


--- Creates an orthographic projection matrix with a custom view volume
--- @param left number: Near plane's lower x value
--- @param right number: Near plane's upper x value
--- @param bottom number: Near plane's lower y value
--- @param top number: Near plane's upper Y value
--- @param near number: Near plane depth
--- @param far number: Far plane depht
--- @return Matrix: Result
function Matrix.createOrthographicOffCenter(left, right, bottom, top, near, far) end


--- Creates a perspective projection matrix
--- @param width number: Width of the view volume
--- @param height number: Height of the view volume
--- @param near number: Near plane distance
--- @param far number: Far plane distance
--- @return Matrix: Result
function Matrix.createPerspective(width, height, near, far) end


--- Creates a perspective projection matrix with a custom view volume
--- @param left number: Near plane's lower x value
--- @param right number: Near plane's upper x value
--- @param bottom number: Near plane's lower y value
--- @param top number: Near plane's upper Y value
--- @param near number: Near plane distance
--- @param far number: Far plane distance
--- @return Matrix: Result
function Matrix.createPerspectiveOffCenter(left, right, bottom, top, near, far) end


--- Creates a perspective projection matrix with a field of view
--- @param fov number: Field of view angle
--- @param aspectRatio number: Aspect ratio (i.e `width / height`) of the view volume
--- @param near number: Near plane distance
--- @param far number: Far plane distance. `math.huge` is also acceptable
--- @return Matrix: Result
function Matrix.createPerspectiveFOV(fov, aspectRatio, near, far) end


--- Creates a scaling matrix
--- @param scale Vector3: The scale value on each axis
--- @return Matrix: Result
function Matrix.createScale(scale) end


--- Creates a translation matrix
--- @param position Vector3: The translation coordinates
--- @return Matrix: Result
function Matrix.createTranslation(position) end


--- Creates a matrix with rotation, scale and translation informations
--- @param rotation Quaternion: The rotation factor
--- @param scale Vector3: The scaling factor
--- @param translation Vector3: The translation coordinates
--- @return Matrix: Result
function Matrix.createTransformationMatrix(rotation, scale, translation) end


return Matrix
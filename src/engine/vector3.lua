local CStruct = require "engine.cstruct"
local Vector3 = CStruct("vector3", [[
    float x, y, z;
]])

function Vector3:new(x, y, z)
    self.x = x
    self.y = y
    self.z = z
end

-----------------------
----- Metamethods -----
-----------------------

local predefined = {
    forward   = Vector3( 0, 0, 1),
    backwards = Vector3( 0, 0,-1),
    up        = Vector3( 0, 1, 0),
    down      = Vector3( 0,-1, 0),
    left      = Vector3( 1, 0, 0),
    right     = Vector3(-1, 0, 0),
}

local aliases = {
    width  = "x", red   = "x", r = "x", pitch = "x",
    height = "y", green = "y", g = "y", yaw   = "y",
    depth  = "z", blue  = "z", b = "z", roll  = "z"
}

function Vector3:__index(key)
    if aliases[key] then
        return self[aliases[key]]
    end

    if key == "lengthSquared" then
        return self.x*self.x + self.y*self.y + self.z*self.z
    end

    if key == "length" then
        return math.sqrt(self.lengthSquared)
    end

    if key == "normalized" then
        return self:clone():normalize()
    end

    if key == "inverse" then
        return self:clone():invert()
    end

    if predefined[key] then
        return predefined[key]:clone()
    end

    return Vector3[key]
end

function Vector3:__newindex(key, value)
    if aliases[key] then
        self[aliases[key]] = value
    end
end

function Vector3:__add(other)
    return self:clone():add(other)
end

function Vector3:__sub(other)
    return self:clone():subtract(other)
end

function Vector3:__mult(other)
    return self:clone():multiply(other)
end

function Vector3:__div(other)
    return self:clone():divide(other)
end

function Vector:__unm()
    return self:clone():negate()
end

function Vector3:__eq(other)
    return self.x == other.x and
           self.y == other.y and
           self.z == other.z
end

---------------------
------ Methods ------
---------------------

function Vector3:add(other)
    if type(other) == "number" then
        self.x = self.x + other
        self.y = self.y + other
        self.z = self.z + other
    else
        self.x = self.x + other.x
        self.y = self.y + other.y
        self.z = self.z + other.z
    end

    return self
end

function Vector3:subtract(other)
    if type(other) == "number" then
        self.x = self.x - other
        self.y = self.y - other
        self.z = self.z - other
    else
        self.x = self.x - other.x
        self.y = self.y - other.y
        self.z = self.z - other.z
    end

    return self
end

function Vector3:multiply(other)
    if type(other) == "number" then
        self.x = self.x * other
        self.y = self.y * other
        self.z = self.z * other
    else
        self.x = self.x * other.x
        self.y = self.y * other.y
        self.z = self.z * other.z
    end

    return self
end

function Vector3:divide(other)
    if type(other) == "number" then
        self:multiply(1 / other)
    else
        self.x = self.x / other.x
        self.y = self.y / other.y
        self.z = self.z / other.z
    end

    return self
end

function Vector3:negate()
    self.x = -self.x
    self.y = -self.y
    self.z = -self.z

    return self
end

function Vector3:normalize()
    self:divide(self.length)

    return self
end

function Vector3:invert()
    self.x = 1 / self.x
    self.y = 1 / self.y
    self.z = 1 / self.z

    return self
end


-- domo same desu

function Vector3:reflect(normal)
    local dot = Vector3.dot(self, normal)

    self.X = self.X - (2 * normal.X) * dot;
    self.Y = self.Y - (2 * normal.Y) * dot;
    self.Z = self.Z - (2 * normal.Z) * dot;

    return self
end

function Vector3:clamp(min, max)
    self.x = Lume.clamp(self.x, min.x, max.x)
    self.y = Lume.clamp(self.y, min.y, max.y)
    self.z = Lume.clamp(self.z, min.z, max.z)

    return self
end

function Vector3:transform(value)
    if value.typename == "quaternion" then
        local x = 2 * (value.y * self.z - value.z * self.y);
        local y = 2 * (value.z * self.x - value.x * self.z);
        local z = 2 * (value.x * self.y - value.y * self.x);

        self.x = self.x + x * value.w + (value.y * z - value.z * y);
        self.y = self.y + y * value.w + (value.z * x - value.x * z);
        self.z = self.z + z * value.w + (value.x * y - value.y * x);
    else
        -- Matrix
        self.x = (self.x * value.m11) + (self.y * value.m21) + (self.z * value.m31) + value.m41;
        self.y = (self.x * value.m12) + (self.y * value.m22) + (self.z * value.m32) + value.m42;
        self.z = (self.x * value.m13) + (self.y * value.m23) + (self.z * value.m33) + value.m43;
    end

    return self
end

function Vector3:isNan()
    return self.x ~= self.x or
           self.y ~= self.y or
           self.z ~= self.z
end

function Vector3:clone()
    return Vector3(self.x, self.y, self.z)
end

----------------------------
----- Static functions -----
----------------------------

function Vector3.dot(v1, v2)
    return v1.x*v2.x + v1.y*v2.y + v1.z*v2.z
end

function Vector3.cross(v1, v2)
    return Vector3(
          v1.y * v2.z - v2.y * v1.z,
        -(v1.x * v2.z - v2.x * v1.z),
          v1.x * v2.y - v2.x * v1.y
    )
end

function Vector3.distanceSquared(v1, v2)
    return (v2.x - v1.x) *
           (v2.y - v1.y) *
           (v2.z - v1.z)
end

function Vector3.distance(v1, v2)
    return math.sqrt(Vector3.distanceSquared(v1, v2))
end

return Vector3
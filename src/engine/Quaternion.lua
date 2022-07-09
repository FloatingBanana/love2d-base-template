-- Borrowed from https://github.com/MonoGame/MonoGame/blob/develop/MonoGame.Framework/Quaternion.cs

local CStruct = require "engine.cstruct"
local Quaternion = CStruct("quaternion", [[
    double x, y, z, w;
]])

function Quaternion:new(x, y, z, w)
    self.x = x
    self.y = y
    self.z = z
    self.w = w
end

function Quaternion:__add(other)
    return Quaternion(
        self.x + other.x,
        self.y + other.y,
        self.z + other.z,
        self.w + other.w
    )
end

function Quaternion:__sub(other)
    return Quaternion(
        self.x - other.x,
        self.y - other.y,
        self.z - other.z,
        self.w - other.w
    )
end

function Quaternion:__mult(other)
    if type(other) == "number" then
        return Quaternion(
            self.x * other,
            self.y * other,
            self.z * other,
            self.w * other
        )
    else
		local value1 = (self.y * other.z) - (self.z * other.y)
		local value2 = (self.z * other.x) - (self.x * other.z)
		local value3 = (self.x * other.y) - (self.y * other.x)
		local value4 = ((self.x * other.x) + (self.y * other.y)) + (self.z * other.z)

        return Quaternion(
		    ((self.x * other.w) + (other.x * self.w)) + value1,
		    ((self.y * other.w) + (other.y * self.w)) + value2,
		    ((self.z * other.w) + (other.z * self.w)) + value3,
		    (self.w * other.w) - value4
        )
    end
end

function Quaternion:__div(other)
    if type(other) == "number" then
        return Quaternion(
            self.x / other.x,
            self.y / other.y,
            self.z / other.z,
            self.w / other.w
        )
    else
        -- yeah, IDK either...
        local length = (((other.x * other.x) + (other.y * other.y)) + (other.z* other.z)) + (other.w * other.w);
        local invLength = 1 / length;
        local otX = -other.x * invLength;
        local otY = -other.y * invLength;
        local otZ = -other.z * invLength;
        local otW = other.w * invLength;
        local value1 = (self.y * otZ) - (self.z * otY);
        local value2 = (self.z * otX) - (self.x * otZ);
        local value3 = (self.x * otY) - (self.y * otX);
        local value4 = ((self.x * otX) + (self.y * otY)) + (self.z * otZ);

        return Quaternion(
            ((self.x * otW) + (otX * self.w)) + value1,
            ((self.y * otW) + (otY * self.w)) + value2,
            ((self.z * otW) + (otZ * self.w)) + value3,
            (self.w * otW) - value4
        )
    end
end

function Quaternion:__eq(other)
    return self.x == other.x and
           self.y == other.y and
           self.z == other.z and
           self.w == other.w
end


function Quaternion:Normalize()
    local num = 1 / math.sqrt((self.x * self.x) + (self.y * self.y) + (self.z * self.z) + (self.w * self.w));
	self.x = self.x * num;
	self.y = self.y * num;
	self.z = self.z * num;
	self.w = self.w * num;
end

--------------------------------
------ Static functions---------
--------------------------------

function Quaternion.CreateFromAxisAngle(axis, angle)
    local half = angle * 0.5;
	local sin = math.sin(half);
	local cos = math.cos(half);

	return Quaternion(axis.x * sin, axis.y * sin, axis.z * sin, cos);
end

function Quaternion.CreateFromYawPitchRoll(yaw, pitch, roll)
    local halfRoll = roll * 0.5;
    local halfPitch = pitch * 0.5;
    local halfYaw = yaw * 0.5;

    local sinRoll = math.sin(halfRoll);
    local cosRoll = math.cos(halfRoll);
    local sinPitch = math.sin(halfPitch);
    local cosPitch = math.cos(halfPitch);
    local sinYaw = math.sin(halfYaw);
    local cosYaw = math.cos(halfYaw);

    return Quaternion((cosYaw * sinPitch * cosRoll) + (sinYaw * cosPitch * sinRoll),
                      (sinYaw * cosPitch * cosRoll) - (cosYaw * sinPitch * sinRoll),
                      (cosYaw * cosPitch * sinRoll) - (sinYaw * sinPitch * cosRoll),
                      (cosYaw * cosPitch * cosRoll) + (sinYaw * sinPitch * sinRoll));
end
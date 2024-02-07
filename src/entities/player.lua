local Vector2 = require "engine.math.vector2"
local InputHelper = require "engine.misc.inputHelper"
local Body = require "entities.body"
local Player = Body:extend("Player")

function Player:new(world, position)
    Body.new(self, world, position, Vector2(32, 32), 1)

    self.speed = 100
end

function Player:update(dt)
    local direction = Vector2(
        InputHelper.getAxis("horizontal"),
        InputHelper.getAxis("vertical")
    )

    if direction.lengthSquared > 0 then
        local target = direction.normalized * (self.speed * dt)

        self:move(target)
    end
end

return Player
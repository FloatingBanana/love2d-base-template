local Vector2 = require "engine.vector2"
local InputHelper = require "engine.inputHelper"
local Body = require "entities.body"
local Player = Body:extend()

function Player:new(world, position)
    Body.new(self, world, position, Vector2(32, 32))

    self.speed = 100
end

function Player:update(dt)
    local direction = Vector2(
        InputHelper.getAxis("horizontal"),
        InputHelper.getAxis("vertical")
    )

    local target = direction.normalized * (self.speed * dt)

    self:move(target)
end

return Player
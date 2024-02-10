local InputHelper = require "engine.misc.inputHelper"
local Vector2 = require "engine.math.vector2"
local Component = require "engine.composition.component"

---@class PlayerControllerComponent: Component
---
---@field public speed number
---@overload fun(speed: number): PlayerControllerComponent
local PlayerController = Component:extend("PlayerControllerComponent")

function PlayerController:new(speed)
    self.speed = speed

    self.onGround = false
end

function PlayerController:update(entity, dt)
    local body = entity:getComponent("BodyComponent")---@type BodyComponent

    self.onGround = false
    for i, col in ipairs(body.collisions) do
        if col.normal.y == -1 then
            self.onGround = true
        end
    end


    body.velocity.x = InputHelper.getAxis("horizontal") * self.speed
end

function PlayerController:onBodyCollision(entity, col, moveOffset)
    
end

function PlayerController:keypressed(entity, k)
    local body = entity:getComponent("BodyComponent") ---@type BodyComponent

    if self.onGround and k == "space" then
        body.velocity.y = -500
    end
end

return PlayerController
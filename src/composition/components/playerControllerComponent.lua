local InputHelper = require "engine.misc.inputHelper"
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

function PlayerController:update(dt)
    local body = self.entity:getComponent("BodyComponent") --[[@as BodyComponent]]

    self.onGround = false
    for i, col in ipairs(body.collisions) do
        if col.normal.y == -1 then
            self.onGround = true
        end
    end


    body.velocity.x = InputHelper.getAxis("horizontal") * self.speed
end

function PlayerController:onBodyCollision(col, moveOffset)
    
end

function PlayerController:keypressed(k)
    local body = self.entity:getComponent("BodyComponent") --[[@as BodyComponent]]

    if self.onGround and k == "space" then
        body.velocity.y = -500
    end
end

return PlayerController
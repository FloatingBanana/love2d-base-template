local Rect = require "engine.math.rect"
local Component = require "engine.composition.component"

---@class Transform2dComponent: Component
---
---@field public position Vector2
---@field public size Vector2
---@field public rect Rect
---@overload fun(position: Vector2, size: Vector2): Transform2dComponent
local Transform = Component:extend("Transform2dComponent")

function Transform:new(position, size)
    self.position = position
    self.size = size

    self.rect = Rect(position, size)
end

function Transform:update(dt)
    self.rect.position = self.position
    self.rect.size = self.size
end

return Transform
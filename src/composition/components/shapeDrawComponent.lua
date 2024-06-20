local Component = require "engine.composition.component"


---@class ShapeDrawComponent: Component
---
---@field public type string
---@field public fill boolean
---@field public color number[]
---@field public thickness number
---@overload fun(type: "rectangle"|"circle", fill: boolean, color: number[], thickness: number?): ShapeDrawComponent
local ShapeDraw = Component:extend("ShapeDrawComponent")

function ShapeDraw:new(type, fill, color, thickness)
    self.type = type
    self.fill = fill
    self.color = color
    self.thickness = thickness or 1
end

function ShapeDraw:draw()
    local transform = self.entity:getComponent("Transform2dComponent") --[[@as Transform2dComponent]]
    local pos, size = transform.position, transform.size

    love.graphics.setColor(self.color)
    love.graphics.setLineWidth(self.thickness)
    local fillMode = self.fill and "fill" or "line"

    if self.type == "rectangle" then
        love.graphics.rectangle(fillMode, pos.x, pos.y, size.width, size.height)
    elseif self.type == "circle" then
        love.graphics.circle(fillMode, pos.x+size.width/2, pos.y+size.height/2, math.min(size.width, size.height) / 2)
    end

    love.graphics.setColor(1,1,1,1)
end

return ShapeDraw
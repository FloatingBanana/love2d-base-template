local Component = require "engine.composition.component"


---@class SpringComponent: Component
---
---@overload fun(): SpringComponent
local SpringComponent = Component:extend("SpringComponent")

function SpringComponent:new(force)
    self.force = force
end

function SpringComponent:onBodyCollision(col, offset)
    local otherBody = col.other:getComponent("BodyComponent") --[[@as BodyComponent]]

    if col.normal.y == -1 then
        otherBody.velocity.y = -self.force
    end
end

return SpringComponent
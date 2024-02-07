local Vector2 = require "engine.math.vector2"
local Base = require "entities.base"
local Body = Base:extend("Body")

function Body:new(world, position, size, layer)
    Base.new(self, position, layer)

    self.world = world
    self.size = size

    world:add(self, position.x, position.y, size.x, size.y)
end

function Body:draw()
    love.graphics.setColor(1,1,1,1)
    love.graphics.rectangle("fill", self.world:getRect(self))
end

function Body:moveTo(target, filter)
    local goalx, goaly, cols, len = self.world:move(self, target.x, target.y, filter)
    self.position = Vector2(goalx, goaly)

    for i = 1, len do
        self:onCollision(cols[i])
    end

    return cols
end

function Body:move(offset, filter)
    self:moveTo(self.position + offset, filter)
end

-- Callbacks
Body.onCollision = function()end

return Body
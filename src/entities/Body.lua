local Base = require "entities.base"
local Body = Base:extend()

function Body:init(world, position, size)
    Base.init(self, position)

    self.world = world
    self.size = size

    world:add(self, position.x, position.y, size.x, size.y)
end

function Body:moveTo(target, filter)
    local goalx, goaly, cols, len = self.world:move(self, target.x, target.y, filter)
    self.position = Vector(goalx, goaly)

    for i = 1, len do
        self:onCollision(cols[i])
    end

    return cols
end

function Body:move(offset, filter)
    self:moveTo(self.position + offset, filter)
end

-- Callbacks
Body.onCollision = NULLFUNC
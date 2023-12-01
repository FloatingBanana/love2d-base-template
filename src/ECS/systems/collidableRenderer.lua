local Concord = require "libs.concord"

local CollidableRenderer = Concord.system({
    pool = {"collidable"}
})

function CollidableRenderer:draw()
    for i, entity in ipairs(self.pool) do
        local collidable = entity.collidable
        local world = collidable.world

        love.graphics.setColor(1, 1, 1, 1)
        love.graphics.rectangle("fill", world:getRect(collidable))
    end
end

return CollidableRenderer
local CollidableRenderer = Concord.system({
    pool = {"collidable"}
})

function CollidableRenderer:draw()
    for i, entity in ipairs(self.pool) do
        local collidable = entity.collidable
        local world = collidable.world

        lg.setColor(1, 1, 1, 1)
        lg.rectangle("fill", world:getRect(collidable))
    end
end

return CollidableRenderer
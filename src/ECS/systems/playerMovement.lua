local InputHelper = require "InputHelper"

local PlayerMovement = Concord.system({
    pool = {"transform", "collidable", "player"}
})


function PlayerMovement:update(dt)
    for i, entity in ipairs(self.pool) do
        local transform = entity.transform
        local collidable = entity.collidable
        local player = entity.player

        local direction = Vector(
            InputHelper.getAxis("horizontal"),
            InputHelper.getAxis("vertical")
        )

        local target = transform.position + direction.normalized * (player.speed * dt)

        transform.position.x, transform.position.y = collidable.world:move(collidable, target.x, target.y)
    end
end

return PlayerMovement
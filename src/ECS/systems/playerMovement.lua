local InputHelper = require "engine.inputHelper"
local Vector2     = require "engine.vector2"

local PlayerMovement = Concord.system({
    pool = {"transform", "collidable", "player"}
})


function PlayerMovement:update(dt)
    for i, entity in ipairs(self.pool) do
        local transform = entity.transform
        local collidable = entity.collidable
        local player = entity.player

        local direction = Vector2(
            InputHelper.getAxis("horizontal"),
            InputHelper.getAxis("vertical")
        )

        local target = transform.position + direction.normalized * (player.speed * dt)

        transform.position.x, transform.position.y = collidable.world:move(collidable, target.x, target.y)
    end
end

return PlayerMovement
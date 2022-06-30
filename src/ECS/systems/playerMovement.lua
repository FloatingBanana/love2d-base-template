local InputHelper = require "InputHelper"

local PlayerMovement = Concord.system({
    pool = {"transform", "player"}
})

function PlayerMovement:init()
    self.draworder = Draworder()
end

function PlayerMovement:update(dt)
    for i, entity in ipairs(self.pool) do
        local transform = entity.transform
        local player = entity.player

        local offset = Vector(
            InputHelper.getAxis("horizontal"),
            InputHelper.getAxis("vertical")
        )

        transform.position = transform.position + offset * (player.speed * dt)
    end
end

return PlayerMovement
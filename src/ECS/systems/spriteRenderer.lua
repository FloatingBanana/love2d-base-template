local Draworder = require "libs.draworder"
local Concord   = require "libs.concord"

local SpriteRenderer = Concord.system({
    pool = {"transform", "sprite"}
})

function SpriteRenderer:init()
    self.draworder = Draworder()
end

function SpriteRenderer:draw()
    for i, entity in ipairs(self.pool) do
        local transform = entity.transform
        local sprite = entity.sprite

        love.graphics.setShader(sprite.shader)

        if sprite.quad then
            self.draworder.queue(
                love.graphics.draw,
                sprite.layer,

                sprite.image,
                sprite.quad,

                transform.position.x,
                transform.position.y,

                sprite.scale.x,
                sprite.scale.y,

                sprite.offset.x,
                sprite.offset.y
            )
        else
            self.draworder.queue(
                love.graphics.draw,
                sprite.layer,

                sprite.image,

                transform.position.x,
                transform.position.y,

                sprite.scale.x,
                sprite.scale.y,

                sprite.offset.x,
                sprite.offset.y
            )
        end

        love.graphics.setShader()
    end
end

return SpriteRenderer
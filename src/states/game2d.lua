local Vector2 = require "engine.math.vector2"
local Sprite  = require "engine.2D.sprite"
local Game = {}

local heartImg = love.graphics.newImage("assets/images/love_heart.png")
local sprites = {} ---@type Sprite[]

function Game:enter()
    math.randomseed(os.time())
    local rnd = math.random
    for i=1, 20 do
        sprites[i] = Sprite(heartImg, {rnd(),rnd(),rnd(),1}, Vector2(rnd() * 0.5), rnd(), Vector2(heartImg:getDimensions()) * 0.5)
    end
end

function Game:update(dt)
    for i, sprite in ipairs(sprites) do
        sprite.rotation = (sprite.rotation + dt) % (math.pi*2)
    end
end

function Game:draw()
    for i, sprite in ipairs(sprites) do
        local pos = Vector2(
            50 + (i * 150) % (SCREENSIZE.width - 100),
            50 + math.floor(i * 150 / (SCREENSIZE.width - 100)) * 150
        )

        sprite:draw(pos)
    end
end

return Game
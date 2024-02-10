local Vector2 = require "engine.math.vector2"
local Sprite  = require "engine.2D.sprite"
local LightRenderer2D = require "engine.2D.lightRenderer2d"
local Game = {}

local heartImg = love.graphics.newImage("assets/images/love_heart.png")
local sprites = {} ---@type Sprite[]

local screen = love.graphics.newCanvas(WIDTH, HEIGHT)
local renderer = LightRenderer2D(SCREENSIZE, {.2,.2,.2})

local light = renderer:addLight(Vector2(0,0), 150, {1,1,1})

function Game:enter()
    math.randomseed(os.time())
    local rnd = math.random
    for i=1, 18 do
        sprites[i] = Sprite(heartImg, {rnd(),rnd(),rnd(),1}, Vector2(.05 + rnd() * .95) * .5, rnd(), Vector2(heartImg:getDimensions()) * 0.5)
    end
end

function Game:update(dt)
    for i, sprite in ipairs(sprites) do
        sprite.rotation = (sprite.rotation + dt) % (math.pi*2)
    end

    light.pos = Vector2(love.mouse.getPosition())
end

function Game:draw()
    lg.setCanvas(screen)
    lg.clear(.2,.2,.2)

    for i, sprite in ipairs(sprites) do
        local pos = Vector2(
            50 + (i * 150) % (SCREENSIZE.width - 100),
            50 + math.floor(i * 150 / (SCREENSIZE.width - 100)) * 150
        )

        sprite:draw(pos)
    end

    lg.setCanvas()

    renderer:render(screen)

    -- lg.draw(light.shadowMap)
    lg.draw(renderer.lightMap)
end

function Game:mousepressed(x, y, button)
    if button == 1 then
        local rnd = math.random
        renderer:addLight(Vector2(love.mouse.getPosition()), rnd(100, 400), {rnd(),rnd(),rnd()})
    elseif button == 2 then
        renderer:addCircleOccluder(Vector2(love.mouse.getPosition()), 30, 20)
        -- renderer:addRectangleOccluder(Vector2(love.mouse.getPosition()), Vector2(30, 30))
    end
end

return Game
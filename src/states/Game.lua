local Game = {}

local Vector2 = require "engine.vector2"
local EM = require "engine.entityManager"
local world = nil

-- Entities
local Player = require "entities.player"
local Body = require "entities.Body"

function Game:enter(from, ...)
    world = Bump.newWorld(32)

    EM.add(Player(world, Vector2(200, 250)))
    EM.add(Body(world, Vector2(50, 200), Vector2(150, 32)))
end

function Game:draw()
    EM.emit("draw")
end

function Game:update(dt)
    EM.emit("update", dt)
end

function Game:keypressed(key)
    EM.emit("keypressed", key)
end

function Game:keyreleased(key)
    EM.emit("keyreleased", key)
end

function Game:mousepressed(button)
    EM.emit("mousepressed", button)
end

function Game:mousereleased(button)
    EM.emit("mousereleased", button)
end

return Game
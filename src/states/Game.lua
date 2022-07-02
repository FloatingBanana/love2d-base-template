local Game = {}

local EM = require "engine.entityManager"

function Game:enter(from, ...)
    
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
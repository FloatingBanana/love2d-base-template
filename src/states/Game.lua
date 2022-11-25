local Game = {}

local Vector2 = require "engine.math.vector2"
local PathfinderGrid = require "engine.AI.pathfinding.pathfindingGrid"
local Astar = require "engine.AI.pathfinding.astarFinder"
local EM = require "engine.entityManager"
local world = nil

-- Entities
local Player = require "entities.player"
local Body = require "entities.body"

local playerObj = nil
local grid = nil
local finder = Astar()

function Game:enter(from, ...)
    world = Bump.newWorld(32)

    EM.add(Body(world, Vector2(64, 192), Vector2(150, 32)))

    grid = PathfinderGrid(Vector2(WIDTH, HEIGHT) / 32, function(x, y)
        if #world:queryRect(x*32, y*32, 32, 32) > 0 then
            return "wall", 0
        end

        return "free", 0
    end)

    playerObj = Player(world, Vector2(200, 250))
    EM.add(playerObj)
end

function Game:draw()
    EM.emit("draw")

    local startPos = (playerObj.position / 32):floor()
    local endPos = Vector2(lm.getPosition()):divide(32):floor()
    local path = finder:findPath(grid, startPos, endPos)

    if path then
        for i, pos in ipairs(path) do
            lg.setColor(1,1,1,1)
            lg.rectangle("line", pos.x * 32, pos.y * 32, 32, 32)
        end
    end

    for i, pos in ipairs(finder.searched) do
        lg.setColor(1,0,0,0.1)
        lg.rectangle("fill", pos.x * 32, pos.y * 32, 32, 32)
    end
    lg.setColor(1,1,1,1)
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

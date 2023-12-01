local Game = {}

local Vector2        = require "engine.math.vector2"
local Camera         = require "engine.misc.camera"
local PathfinderGrid = require "engine.AI.pathfinding.pathfindingGrid"
local Astar          = require "engine.AI.pathfinding.astarFinder"
local EM             = require "engine.misc.entityManager"
local Bump           = require "libs.bump"
local Draworder      = require "libs.draworder"

-- Entities
local Player = require "entities.player"
local Body = require "entities.body"

local world = nil
local camera = nil
local playerObj = nil
local grid = nil
local finder = Astar()

function Game:enter(from, ...)
    world = Bump.newWorld(32)
    camera = Camera(Vector2(WIDTH, HEIGHT) / 2, 1)

    EM.add(Body(world, Vector2(64, 192), Vector2(150, 32), 0))

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
    camera:attach()

    for entity in pairs(EM.entities) do
        if entity.draw then
            Draworder.queue(entity.layer, entity.draw, entity)
        end
    end

    Draworder.present() --- @diagnostic disable-line
    camera:detach()

    local startPos = (playerObj.position / 32):floor()
    local endPos = Vector2(love.mouse.getPosition()):divide(32):floor()
    local path = finder:findPath(grid, startPos, endPos)

    if path then
        for i, pos in ipairs(path) do
            love.graphics.setColor(1,1,1,1)
            love.graphics.rectangle("line", pos.x * 32, pos.y * 32, 32, 32)
        end
    end

    for i, pos in ipairs(finder.searched) do
        love.graphics.setColor(1,0,0,0.1)
        love.graphics.rectangle("fill", pos.x * 32, pos.y * 32, 32, 32)
    end
    love.graphics.setColor(1,1,1,1)
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

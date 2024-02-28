local Game = {}

local Bump = require "libs.bump"
local Vector2 = require "engine.math.vector2"
local Manager = require "engine.composition.compositionManager"
local Entity = require "engine.composition.entity"

local Transform2d = require "composition.components.transform2dComponent"
local ShapeDraw = require "composition.components.shapeDrawComponent"
local Body = require "composition.components.bodyComponent"
local Spring = require "composition.components.springComponent"
local PlayerController = require "composition.components.playerControllerComponent"


local function newWallEntity(world, pos, size)
    local wall = Entity()
    wall:attachComponents(Transform2d(pos, size))
    wall:attachComponents(ShapeDraw("rectangle", true, {1,0,1}, 1))
    wall:attachComponents(Body(world, 0))

    return wall
end

local world = Bump.newWorld(32)

function Game:enter()
    Manager.clear()
    
    local player = Entity()
    player:attachComponents(Transform2d(Vector2(100, 100), Vector2(32, 32)))
    player:attachComponents(ShapeDraw("rectangle", false, {1,1,1}, 2))
    player:attachComponents(PlayerController(200))
    player:attachComponents(Body(world, 3))

    local box = Entity()
    box:attachComponents(Transform2d(Vector2(200, 100), Vector2(32, 32)))
    box:attachComponents(ShapeDraw("rectangle", false, {1,1,0}, 2))
    box:attachComponents(Body(world, 1))

    local spring = Entity()
    spring:attachComponents(Transform2d(Vector2(380, 368), Vector2(32, 32)))
    spring:attachComponents(ShapeDraw("rectangle", true, {1,1,0}, 1))
    spring:attachComponents(Body(world, 0))
    -- spring:attachComponents(Spring(400))
    spring:getComponent("BodyComponent").elasticity.y = 400

    
    Manager.addEntity(player)
    Manager.addEntity(box)
    Manager.addEntity(spring)
    Manager.addEntity(newWallEntity(world, Vector2(50, 200), Vector2(300, 32)))
    Manager.addEntity(newWallEntity(world, Vector2(280, 400), Vector2(300, 32)))
end

function Game:draw()
    Manager.broadcastToAllComponents("draw")
end

function Game:update(dt)
    Manager.broadcastToAllComponents("update", dt)
end

function Game:keypressed(key)
    Manager.broadcastToAllComponents("keypressed", key)
end

return Game
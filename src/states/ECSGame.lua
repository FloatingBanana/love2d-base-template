local Game = {}

local Systems = {}
Concord.utils.loadNamespace("ECS/components")
Concord.utils.loadNamespace("ECS/systems", Systems)

local ECSWorld = nil
local BumpWorld = nil

function Game:enter(from, ...)
    ECSWorld = Concord.world()
    BumpWorld = Bump.newWorld(32)

    ECSWorld:addSystems(Systems.collidableRenderer, Systems.playerMovement, Systems.spriteRenderer)

    -- Player entity
    Concord.entity(ECSWorld)
        :give("transform", Vector(200, 200))
        :give("player", 100)
        :give("collidable", BumpWorld, Vector(200, 200), Vector(32, 32))


    -- Wall
    Concord.entity(ECSWorld)
        :give("transform", Vector(50, 150))
        :give("collidable", BumpWorld, Vector(50, 150), Vector(250, 32))
end

function Game:draw()
    ECSWorld:emit("draw")
end

function Game:update(dt)
    ECSWorld:emit("update", dt)
end

function Game:keypressed(key)
    ECSWorld:emit("keypressed", key)
end

function Game:keyreleased(key)
    ECSWorld:emit("keyreleased", key)
end

function Game:mousepressed(button)
    ECSWorld:emit("mousepressed", button)
end

function Game:mousereleased(button)
    ECSWorld:emit("mousereleased", button)
end

return Game
local Vector2 = require "engine.math.vector2"
local Component = require "engine.composition.component"

---@alias BumpCoollisionSolver
---| "slide"
---| "touch"
---| "bounce"
---| "cross"

---@alias BumpCollisionDescription {item: any, other: any, type: BumpCollisionDescription, overlaps: boolean, ti: number, move: table, normal: table, touch: table, itemRect: table, otherRect: table}

---@class BodyComponent: Component
---
---@field public world table
---@field public mass number
---@field public velocity Vector2
---@field public pushable boolean
---@field public collisions BumpCollisionDescription[]
---
---@overload fun(world: table, mass: number): BodyComponent
local Body = Component:extend("BodyComponent")
Body.Gravity = Vector2(0, 500)

function Body:new(world, mass)
    self.world = world
    self.mass = mass
    self.velocity = Vector2()
    self.elasticity = Vector2(0,0)
    self.pushable = true

    self.collisions = {}
end


function Body:update(dt)
    if self.mass > 0 then
        self.velocity:add(Body.Gravity * (self.mass * dt))
        self:move(self.velocity * dt)
    end
end


function Body:move(offset)
    local transform = self.entity:getComponent("Transform2dComponent")

    local target = transform.position + offset
    local goalx, goaly, cols, len = self.world:move(self.entity, target.x, target.y)

    transform.position = Vector2(goalx, goaly)
    self.collisions = cols

    for i=1, len do
        self.entity:broadcastToComponents("onBodyCollision", cols[i], offset)
        cols[i].other:broadcastToComponents("onBodyCollision", cols[i], offset)
    end
end


function Body:onBodyCollision(col, moveOffset)
    local otherBody = col.other:getComponent("BodyComponent")

    if col.item == self.entity then
        if col.normal.x ~= 0 and math.abs(otherBody.velocity.x) < math.abs(self.velocity.x) then
            self.velocity.x = otherBody.velocity.x
        end
        if col.normal.y ~= 0 and math.abs(otherBody.velocity.y) < math.abs(self.velocity.y) then
            self.velocity.y = otherBody.velocity.y
        end

        self.velocity = self.velocity + otherBody.elasticity * Vector2(col.normal.x, col.normal.y)
        
        if otherBody.pushable and otherBody.mass > 0 then
            -- Push objects
            local push = moveOffset * (1 - col.ti) * math.min(self.mass / otherBody.mass, 1) * Vector2(math.abs(col.normal.x), math.abs(col.normal.y))
            otherBody:move(push)
        end
    end
end


function Body:onAttach(entity)
    self:_addToWorld(entity)
end
function Body:onEntityAdded(entity)
    self:_addToWorld(entity)
end
function Body:onDetach(entity)
    self:_removeFromWorld(entity)
end
function Body:onEntityRemoved(entity)
    self:_removeFromWorld(entity)
end

function Body:_addToWorld(entity)
    local transform = entity:getComponent("Transform2dComponent")
    local pos = transform.position
    local size = transform.size

    if not self.world:hasItem(entity) then
        self.world:add(entity, pos.x, pos.y, size.x, size.y)
    end
end

function Body:_removeFromWorld(entity)
    if self.world:hasItem(entity) then
        self.world:remove(entity)
    end
end

return Body
local Game = {}

local VerletBody       = require "engine.2D.verlet.verletBody"
local VerletConstraint = require "engine.2D.verlet.verletConstraint"
local Vector2          = require "engine.math.vector2"



local bodies = {}
local constraints = {}

local size = Vector2(20)
local space = 15

local pinned = {}
local dragged = nil
local texture = love.graphics.newImage("assets/images/skybox/back.jpg")
local mesh = love.graphics.newMesh(size.width*size.height, "triangles", "stream")
mesh:setTexture(texture)


local function index(x,y)
    return x + (y-1)*size.width
end

local function cellpos(i)
    i = i-1
    return Vector2(i % size.width, math.floor(i / size.y)) + 1
end

local function togglePin(body)
    if pinned[body] then
        pinned[body] = nil
    else
        pinned[body] = body.position:clone()
    end
end



function Game:enter()
    local meshVerts = {}
    local meshIndices = {}

    -- Create cloth bodies
    for x=1, size.width do
        for y=1, size.height do
            local cell = Vector2(x, y)

            local body = VerletBody(Vector2(100,100) + cell*space, 1)
            bodies[index(x,y)] = body

            local upBody = bodies[index(x,y-1)]
            if upBody then
                table.insert(constraints, VerletConstraint(body, upBody))
            end

            local leftBody = bodies[index(x-1,y)]
            if leftBody then
                table.insert(constraints, VerletConstraint(body, leftBody))
            end


            meshVerts[index(x,y)] = body.position:clone()
            if leftBody and upBody then
                table.insert(meshIndices, index(x-1,y-1))
                table.insert(meshIndices, index(x-1,y))
                table.insert(meshIndices, index(x,y-1))

                table.insert(meshIndices, index(x-1,y))
                table.insert(meshIndices, index(x,y-1))
                table.insert(meshIndices, index(x,y))
            end




            if y==1 then
                togglePin(body)
            end
        end
    end

    mesh:setVertexMap(meshIndices)
end


local vert = {0,0,0,0}
function Game:draw()
    love.graphics.draw(mesh)

    if love.keyboard.isDown("lctrl") then
        for i, body in ipairs(bodies) do
            love.graphics.circle("fill", body.position.x, body.position.y, 3)
        end

        for i, constraint in ipairs(constraints) do
            local p1 = constraint.body1.position
            local p2 = constraint.body2.position
            love.graphics.line(p1.x, p1.y, p2.x, p2.y)
        end
    end
end

function Game:update(dt)
    dt = math.min(love.timer.getAverageDelta(), 1/30)

    for i, body in ipairs(bodies) do
        body.force = Vector2(0, 200)
        body:update(dt)

        body.position:clamp(Vector2(0,0), SCREENSIZE)


        vert[1], vert[2] = body.position:split()
        vert[3], vert[4] = cellpos(i):divide(size):split()
        mesh:setVertex(i, vert)
    end

    for i, constraint in ipairs(constraints) do
        constraint:update(dt)
    end

    for body, pos in pairs(pinned) do
        body.position = pos
    end

    if dragged then
        local mousepos = Vector2(love.mouse.getPosition())
        dragged.position = mousepos

        if pinned[dragged] then
            pinned[dragged] = mousepos
        end
    end
end

function Game:mousepressed(x, y, button)
    if button == 1 then
        local mousepos = Vector2(x,y)
        local closest = nil
        local closestDist = math.huge

        for i, body in ipairs(bodies) do
            local dist = (mousepos - body.position).lengthSquared

            if dist < 10*10 and dist < closestDist then
                closest = body
                closestDist = dist
            end
        end

        dragged = closest
    end

    if button == 2 and dragged then
        togglePin(dragged)
    end
end

function Game:mousereleased(x, y, button)
    if button == 1 then
        dragged = nil
    end
end

return Game
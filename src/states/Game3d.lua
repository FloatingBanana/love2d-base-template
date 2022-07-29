local Game = {}

local Matrix = require "engine.matrix"
local Vector3 = require "engine.vector3"
local Model = require "engine.3DRenderer.model"
local InputHelper = require "engine.inputHelper"
local Quaternion  = require "engine.quaternion"

local myModel = Model("assets/models/untitled.obj")

function Game:enter(from, ...)
    
end

local pos = Vector3(0, 0, -2)
local dir = Vector3()

function Game:draw()
    local view = Matrix.createLookAt(pos, pos + dir, Vector3(0, 1, 0))
    local proj = Matrix.createPerspectiveFOV(math.rad(90), WIDTH/HEIGHT, 0.01, 1000)

    lg.setDepthMode("lequal", true)

    for name, mesh in pairs(myModel.meshes) do
        for i, part in ipairs(mesh.parts) do
            local material = part.material

            material.worldMatrix = Matrix.identity()
            material.viewMatrix = view
            material.projectionMatrix = proj

            part:draw()
        end
    end
    lg.setDepthMode()
    lg.setShader()
end

local yaw = 0
function Game:update(dt)
    yaw = yaw - InputHelper.getAxis("horizontal") * dt
    dir = Vector3(math.sin(yaw),0,math.cos(yaw))

    pos = pos + dir * -InputHelper.getAxis("vertical") * dt
end

function Game:keypressed(key)

end

function Game:keyreleased(key)

end

function Game:mousepressed(button)

end

function Game:mousereleased(button)

end

return Game
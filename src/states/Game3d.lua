local Game = {}

local Matrix = require "engine.matrix"
local Vector3 = require "engine.vector3"
local Model = require "engine.3DRenderer.model"
local InputHelper = require "engine.inputHelper"
local Quaternion  = require "engine.quaternion"

local myModel = Model("assets/models/untitled.obj")

function Game:enter(from, ...)
    lm.setRelativeMode(true)
end

local pos = Vector3(0, 0, -2)
local dir = Vector3()

local modelRot = 0

function Game:draw()
    local view = Matrix.createLookAt(pos, pos + dir, Vector3(0, 1, 0))
    local proj = Matrix.createPerspectiveFOV(math.rad(60), WIDTH/HEIGHT, 0.01, 1000)

    lg.setDepthMode("lequal", true)
    lg.setMeshCullMode("back")
    lg.setBlendMode("replace")

    for name, mesh in pairs(myModel.meshes) do
        for i, part in ipairs(mesh.parts) do
            local material = part.material

            if name == "Drawer" then
                material.worldMatrix = Matrix.createFromYawPitchRoll(modelRot, 0, 0)
            else
                material.worldMatrix = Matrix.identity()
            end

            material.viewMatrix = view
            material.projectionMatrix = proj

            material.viewPosition = pos
            material.directionalLight = {
                direction = Vector3(-1, -1, -1):normalize(),
                ambient = Vector3(1, 1, 1),
                diffuse = Vector3(1, 1, 1),
                specular = Vector3(1, 1, 1)
            }

            part:draw()
        end
    end

    lg.setBlendMode("alpha")
    lg.setMeshCullMode("none")
    lg.setDepthMode()
    lg.setShader()
end

local camRot = Vector3()
function Game:update(dt)
    local walkdir = Vector3(
        -InputHelper.getAxis("horizontal"),
        0,
        -InputHelper.getAxis("vertical")
    )

    local rot = Quaternion.createFromYawPitchRoll(camRot.yaw, camRot.pitch, camRot.roll)

    if walkdir.lengthSquared > 0 then
        pos = pos + walkdir:normalize():transform(rot) * dt
    end

    dir = Vector3(0, 0, 1):transform(rot)

    modelRot = modelRot + dt
end

function Game:mousemoved(x, y, dx, dy)
    local sensibility = 0.005
    camRot.yaw = camRot.yaw + -dx * sensibility
    camRot.pitch = camRot.pitch + dy * sensibility
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
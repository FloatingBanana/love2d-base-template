local Game = {}

local Matrix = require "engine.matrix"
local Vector3 = require "engine.vector3"
local Vector2 = require "engine.vector2"
local Quaternion  = require "engine.quaternion"
local InputHelper = require "engine.inputHelper"
local Model = require "engine.3DRenderer.model"
local PointLight = require "engine.3DRenderer.lights.pointLight"
local SpotLight = require "engine.3DRenderer.lights.spotLight"
local DirectionalLight = require "engine.3DRenderer.lights.directionalLight"
local Lightmanager     = require "engine.3DRenderer.lights.lightmanager"

local myModel = Model("assets/models/untitled.obj")

local pos = Vector3(0, 0, -2)
local dir = Vector3()

local modelRot = 0

local shadowmap = lg.newCanvas(2048, 2048)

local depthRendererShader = lg.newShader [[
uniform sampler2D u_depthMap;

vec4 effect(vec4 color, sampler2D texture, vec2 texcoords, vec2 screencoords) {
    float depth = Texel(u_depthMap, texcoords).r;
    return vec4(vec3(depth), 1.0);
}
]]

local lightmng = Lightmanager()
local light1 = DirectionalLight(Vector3(3, 3, 0), Color(.2,.2,.2), Color.WHITE, Color.WHITE)
local light = SpotLight(Vector3(0), Vector3(0,0,1), math.rad(17), math.rad(25.5), Color(.2,.2,.2), Color.WHITE, Color.WHITE)
local light2 = PointLight(Vector3(0), 1, 0.005, 0.04, Color(.4,.4,.4), Color.WHITE, Color.WHITE)
function Game:enter(from, ...)
    lm.setRelativeMode(true)

    lightmng:addLights(light, light2)

    for name, mesh in pairs(myModel.meshes) do
        lightmng:addMeshParts(Matrix.identity(), unpack(mesh.parts))
    end
end

function Game:draw()
    lg.clear(Color.BLUE * 0.2)
    lightmng:applyLighting()

    lg.setDepthMode("lequal", true)
    lg.setBlendMode("replace")
    lg.setMeshCullMode("back")

    local view = Matrix.createLookAt(pos, pos + dir, Vector3(0, 1, 0))
    local proj = Matrix.createPerspectiveFOV(math.rad(60), WIDTH/HEIGHT, 0.01, 1000)

    for name, mesh in pairs(myModel.meshes) do
        for i, part in ipairs(mesh.parts) do
            local material = part.material
            local world = nil

            if name == "Drawer" then
                world = Matrix.createFromYawPitchRoll(modelRot, 0, 0)
            else
                world = Matrix.identity()
            end

            lightmng:setMeshPartMatrix(part, world)

            material.worldMatrix = world
            material.viewMatrix = view
            material.projectionMatrix = proj

            material.viewPosition = pos
            material.shininess = 32

            part:draw()
        end
    end

    lg.setBlendMode("alpha")
    lg.setMeshCullMode("none")
    lg.setDepthMode()

    if lk.isDown("r") then
        lg.setShader(depthRendererShader)
        depthRendererShader:send("u_depthMap", light.shadowmap)
        lg.draw(shadowmap,0,0,0, .25, .25)
    end

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
        pos:add(walkdir:normalize():transform(rot) * dt)
    end

    pos:add(Vector3(0, lk.isDown("space") and 1 or lk.isDown("lshift") and -1 or 0, 0) * dt)

    dir = Vector3(0, 0, 1):transform(rot)

    modelRot = modelRot + dt

    if lm.isDown(2) then
        light2.position = pos:clone()
    end

    if lm.isDown(1) then
        light.position, light.direction = pos:clone(), dir:clone()
    end
end

function Game:mousemoved(x, y, dx, dy)
    local sensibility = 0.005
    camRot.yaw = camRot.yaw - dx * sensibility
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
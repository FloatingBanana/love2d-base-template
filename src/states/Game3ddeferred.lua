local Game = {}

local Matrix           = require "engine.math.matrix"
local Vector3          = require "engine.math.vector3"
local Vector2          = require "engine.math.vector2"
local Quaternion       = require "engine.math.quaternion"
local InputHelper      = require "engine.inputHelper"
local Model            = require "engine.3DRenderer.model"
local PointLight       = require "engine.3DRenderer.lights.pointLight"
local SpotLight        = require "engine.3DRenderer.lights.spotLight"
local DirectionalLight = require "engine.3DRenderer.lights.directionalLight"
local Lightmanager     = require "engine.3DRenderer.lights.lightmanager"
local DeferredMaterial = require "engine.3DRenderer.materials.deferredPhong"
local RenderDevice     = require "engine.3DRenderer.3DRenderDevice"
local SkyboxClass      = require "engine.3DRenderer.postProcessing.skybox"
local SSAOClass        = require "engine.3DRenderer.postProcessing.ssao"
local BloomClass       = require "engine.3DRenderer.postProcessing.bloom"
local HDRClass         = require "engine.3DRenderer.postProcessing.hdr"

local deferredLightPassShader = lg.newShader(Utils.preprocessShader((lfs.read("engine/shaders/3D/deferred/lightPass.frag"))))


local myModel = Model("assets/models/untitled_uv.fbx", {
    materials = {
        drawer = DeferredMaterial,
        ground = DeferredMaterial,
        emissive = DeferredMaterial,
    }
})

local cloudSkybox = SkyboxClass({
    "assets/images/skybox/right.jpg",
    "assets/images/skybox/left.jpg",
    "assets/images/skybox/top.jpg",
    "assets/images/skybox/bottom.jpg",
    "assets/images/skybox/front.jpg",
    "assets/images/skybox/back.jpg"
})

local renderer = nil
local ssao = nil
local hdr = nil
local bloom = nil

local hdrExposure = 1

local pos = Vector3(0, 0, -2)
local dir = Vector3()
local modelRot = 0

local lightmng = Lightmanager()
local light1 = DirectionalLight(Vector3(3, 3, 0), Color(.2,.2,.2), Color.WHITE, Color.WHITE)
local light = SpotLight(Vector3(0), Vector3(0,0,1), math.rad(17), math.rad(25.5), Color(.2,.2,.2), Color.WHITE, Color.WHITE)
local light2 = PointLight(Vector3(0), 1, 0.005, 0.04, Color(.4,.4,.4), Color.WHITE, Color.WHITE)
function Game:enter(from, ...)
    lm.setRelativeMode(true)

    ssao = SSAOClass(Vector2(WIDTH, HEIGHT), 32, 0.5)
    bloom = BloomClass(Vector2(WIDTH, HEIGHT), 6, 1)
    hdr = HDRClass(Vector2(WIDTH, HEIGHT), hdrExposure)

    renderer = RenderDevice("deferred", Vector2(WIDTH, HEIGHT), {
        cloudSkybox,
        ssao,
        bloom,
        hdr
    })

    lightmng:addLights(light)
    lightmng:addMaterial({shader = deferredLightPassShader})

    for name, mesh in pairs(myModel.meshes) do
        -- if name ~= "light1" and name ~= "light2" then
            lightmng:addMeshParts(Matrix.Identity(), unpack(mesh.parts))
        -- end
    end
end

function Game:draw()
    local view = Matrix.CreateLookAtDirection(pos, dir, Vector3(0, 1, 0))
    local proj = Matrix.CreatePerspectiveFOV(math.rad(60), WIDTH/HEIGHT, 0.01, 1000)

    lightmng:applyLighting()
    renderer:beginDeferredRendering()

    for name, mesh in pairs(myModel.meshes) do
        for i, part in ipairs(mesh.parts) do
            local material = part.material
            local world = mesh.transformation * Matrix.CreateScale(Vector3(0.01))

            if name == "Drawer" then
                world = world * Matrix.CreateFromYawPitchRoll(modelRot, 0, 0)
            end

            lightmng:setMeshPartMatrix(part, world)

            material.worldMatrix = world
            material.viewProjectionMatrix = view * proj

            part:draw()
        end
    end

    renderer:endDeferredRendering(deferredLightPassShader, pos, view, proj)

    if lk.isDown("q") then
        -- lg.draw(light.shadowmap)
    end

    lg.print("HDR exposure: "..hdrExposure, 0, 30)
end

local camRot = Vector3()
function Game:update(dt)
    local walkdir = Vector3(
        -InputHelper.getAxis("horizontal"),
        0,
        -InputHelper.getAxis("vertical")
    )

    local rot = Quaternion.CreateFromYawPitchRoll(camRot.yaw, camRot.pitch, camRot.roll)

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

function Game:wheelmoved(x, y)
    hdrExposure = math.max(hdrExposure + y * 0.1, 0)
    hdr:setExposure(hdrExposure)
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
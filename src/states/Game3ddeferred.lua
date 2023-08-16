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
local AmbientLight     = require "engine.3DRenderer.lights.ambientLight"
local DeferredMaterial = require "engine.3DRenderer.materials.deferredPhong"
local DeferredRenderer = require "engine.3DRenderer.renderers.deferredRenderer"
local SkyboxClass      = require "engine.3DRenderer.postProcessing.skybox"
local SSAOClass        = require "engine.3DRenderer.postProcessing.ssao"
local BloomClass       = require "engine.3DRenderer.postProcessing.bloom"
local HDRClass         = require "engine.3DRenderer.postProcessing.hdr"
local Camera           = require "engine.camera3d"

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

local playerCam = Camera(Vector3(0, 1, -2), Quaternion.Identity(), math.rad(60), WIDTH/HEIGHT, 0.1, 1000)
local modelRot = 0
local drawerMesh = nil

local ambient = AmbientLight(Color(.2,.2,.2))
local light = SpotLight(Vector3(0), Vector3(0,0,1), math.rad(17), math.rad(25.5), Color.WHITE, Color.WHITE)
local light2 = PointLight(Vector3(0), 1, 0.005, 0.04, Color(.2,.2,.2), Color.WHITE, Color.WHITE)
function Game:enter(from, ...)
    lm.setRelativeMode(true)

    ssao = SSAOClass(Vector2(WIDTH, HEIGHT), 32, 0.5)
    bloom = BloomClass(Vector2(WIDTH, HEIGHT), 6, 1)
    hdr = HDRClass(Vector2(WIDTH, HEIGHT), hdrExposure)

    renderer = DeferredRenderer(Vector2(WIDTH, HEIGHT), {
        cloudSkybox,
        ssao,
        bloom,
        hdr
    })

    for name, mesh in pairs(myModel.meshes) do
        renderer:addMeshPart(mesh.parts, {
            castShadows = true,
            ignoreLighting = false,
            worldMatrix = mesh.transformation * Matrix.CreateScale(Vector3(0.01))
        })

        if name == "Drawer" then
            drawerMesh = mesh
        end
    end

    renderer:addLights(ambient, light)
end

function Game:draw()
    for i, part in ipairs(drawerMesh.parts) do
        local settings = renderer:getMeshpartSettings(part)
        settings.worldMatrix = drawerMesh.transformation * Matrix.CreateScale(Vector3(0.01)) * Matrix.CreateFromYawPitchRoll(modelRot, 0, 0)
    end

    renderer:render(playerCam.position, playerCam.viewMatrix, playerCam.projectionMatrix)

    if lk.isDown("q") then
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

    local camRotation = Quaternion.CreateFromYawPitchRoll(camRot.yaw, camRot.pitch, camRot.roll)

    if walkdir.lengthSquared > 0 then
        playerCam.position:add(walkdir:normalize():transform(camRotation) * dt)
    end

    playerCam.position.y = playerCam.position.y + (lk.isDown("space") and 1 or lk.isDown("lshift") and -1 or 0) * dt
    playerCam.rotation = camRotation

    modelRot = modelRot + dt

    if lm.isDown(2) then
        light2.position = playerCam.position:clone()
    end

    if lm.isDown(1) then
        light.position, light.direction = playerCam.position:clone(), Vector3(0,0,1):transform(camRotation)
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
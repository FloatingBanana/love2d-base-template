local Game = {}

local Matrix           = require "engine.math.matrix"
local Vector3          = require "engine.math.vector3"
local Quaternion       = require "engine.math.quaternion"
local InputHelper      = require "engine.misc.inputHelper"
local Model            = require "engine.3D.model.model"
local Camera           = require "engine.misc.camera3d"
local CubemapUtils     = require "engine.misc.cubemapUtils"
local Lume             = require "engine.3rdparty.lume"

local PointLight       = require "engine.3D.lights.pointLight"
local SpotLight        = require "engine.3D.lights.spotLight"
local DirectionalLight = require "engine.3D.lights.directionalLight"
local AmbientLight     = require "engine.3D.lights.ambientLight"

local DeferredRenderer = require "engine.3D.renderers.deferredRenderer"
local ForwardRenderer  = require "engine.3D.renderers.forwardRenderer"

local PhongMaterial    = require "engine.3D.materials.phongMaterial"
local PBRMaterial      = require "engine.3D.materials.PBRMaterial"

local SSAOClass        = require "engine.postProcessing.ssao"
local BloomClass       = require "engine.postProcessing.bloom"
local HDRClass         = require "engine.postProcessing.hdr"
local ColorCorrection  = require "engine.postProcessing.colorCorrection"
local FogClass         = require "engine.postProcessing.fog"
local FXAAClass        = require "engine.postProcessing.fxaa"
local MotionBlurClass  = require "engine.postProcessing.motionBlur"
local PhysBloomClass   = require "engine.postProcessing.physicalBloom"

local Color = require "libs.color"

local debugWindows = {
    rendererInfo = {isOpen = true, draw = require "states.debugDisplay.3DRendererWindow"},
    modelInfo    = {isOpen = true, draw = require "states.debugDisplay.modelViewerWindow"}
}

local graphicsStatsInfo = love.graphics.getStats()

local renderer = nil ---@type BaseRenderer
local myModel = nil ---@type Model
local personAnimator = nil --- @type ModelAnimator

local lockControls = true
local useDeferredRendering = false


-- Post processing effects
-- local bloom = BloomClass(SCREENSIZE, 6, 1)
-- local fog = FogClass(SCREENSIZE, 5, 100, Color(.4,.4,.4))
-- local motionBlur = MotionBlurClass(SCREENSIZE, 0.35)
local ssao = SSAOClass(SCREENSIZE, 32, 0.5)
local bloom = PhysBloomClass(SCREENSIZE)
local hdr = HDRClass(SCREENSIZE, 3)
local colorCorr = ColorCorrection(SCREENSIZE, 1, 0, 1, 1, Color(1,1,1))
local fxaa = FXAAClass(SCREENSIZE)

local playerCam = Camera(Vector3(0, 1, -2), Quaternion.Identity(), math.rad(60), WIDTH/HEIGHT, 0.1, 1000)
local modelRot = 0

local ambient = AmbientLight(Color(.2,.2,.2))
local light = SpotLight(Vector3(0), Vector3(0,0,1), math.rad(17), math.rad(25.5), Color(20,20,20), Color(20,20,20))
local light2 = PointLight(Vector3(0), 1, 0.005, 0.04, Color.WHITE, Color.WHITE)
-- local light3 = DirectionalLight(Vector3(-1, 1, -1), Color(1,1,1), Color(1,1,1))
function Game:enter(from, ...)
    love.mouse.setRelativeMode(lockControls)

    if useDeferredRendering then
        local gbuffer, shader = PBRMaterial.GenerateGBuffer(SCREENSIZE)
        renderer = DeferredRenderer(SCREENSIZE, playerCam, gbuffer, shader)
    else
        renderer = ForwardRenderer(SCREENSIZE, playerCam)
    end

    renderer:addPostProcessingEffects(
        ssao,
        -- fog,
        bloom,
        hdr,
        fxaa,
        -- motionBlur,
        colorCorr
    )

    renderer:addLights(ambient, light, light2)

    local environmentTexture = love.graphics.newImage("assets/images/environment.exr")
    renderer.skyBoxTexture = CubemapUtils.equirectangularMapToCubeMap(environmentTexture, "rg11b10f")

    renderer.irradianceMap = CubemapUtils.getIrradianceMap(renderer.skyBoxTexture)
    renderer.preFilteredEnvironment = CubemapUtils.getPreFilteredEnvironment(renderer.skyBoxTexture)


    myModel = Model("assets/models/untitled.gltf", {
        materials = {
            default = PBRMaterial
        },
        triangulate = true,
        flipUVs = true,
        removeUnusedMaterials = true
    })

    personAnimator = myModel.animations["running"]:getNewAnimator(myModel.armatures.Armature, myModel.nodes.Person:getGlobalMatrix())
    personAnimator:play()
end

function Game:draw()
    for name, mesh in pairs(myModel.meshes) do
        for i, part in ipairs(mesh.parts) do
            local config = renderer:pushMeshPart(part)
            config.material = part.material

            if name == "Drawer" then
                config.worldMatrix = mesh:getGlobalMatrix()-- * Matrix.CreateFromYawPitchRoll(love.timer.getTime(), 0, 0)
            else
                config.worldMatrix = mesh:getGlobalMatrix()
            end

            if name == "Person" then
                config.animator = personAnimator
            end

            if name == "light1" or name == "light2" then
                config.castShadows = false
                config.ignoreLighting = true
            end
        end
    end

    renderer:render(playerCam)


    for i, light in ipairs(renderer.lights) do ---@diagnostic disable-line invisible
        local pos = (light.position or Vector3(0)):clone():worldToScreen(playerCam.viewProjectionMatrix, SCREENSIZE, 0, 1)

        if pos.z > 0 and pos.z < 1 then
            local z = 1 - pos.z
            love.graphics.circle("fill", pos.x, pos.y, z*300)
            love.graphics.rectangle("fill", pos.x-z*100, pos.y, z*200, z*450)
        end
    end

    love.graphics.getStats(graphicsStatsInfo)
end


local camRot = Vector3()
function Game:update(dt)
    modelRot = modelRot + dt

    personAnimator:update(dt)

    if lockControls then
        local walkdir = Vector3()
        walkdir.x = -InputHelper.getAxis("horizontal")
        walkdir.z = -InputHelper.getAxis("vertical")

        local roll = (love.keyboard.isDown("e") and 30 or love.keyboard.isDown("q") and -30 or 0)
        camRot.roll = Lume.lerp(camRot.roll, math.rad(roll), dt * 5)

        local camRotation = Quaternion.CreateFromYawPitchRoll(camRot.yaw, camRot.pitch, camRot.roll)

        if walkdir.lengthSquared > 0 then
            playerCam.position:add(walkdir:normalize():transform(camRotation) * dt)
        end

        playerCam.position.y = playerCam.position.y + (love.keyboard.isDown("space") and 1 or love.keyboard.isDown("lshift") and -1 or 0) * dt
        playerCam.rotation = camRotation


        if love.mouse.isDown(2) then
            light2.position = playerCam.position:clone()
        end

        if love.mouse.isDown(1) then
            light.position, light.direction = playerCam.position:clone(), Vector3(0,0,1):transform(camRotation)
        end
    else
        debugWindows.rendererInfo.isOpen = debugWindows.rendererInfo.draw(debugWindows.rendererInfo.isOpen, renderer, graphicsStatsInfo)
        debugWindows.modelInfo.isOpen = debugWindows.modelInfo.draw(debugWindows.modelInfo.isOpen, myModel)
    end
end

function Game:mousemoved(x, y, dx, dy)
    local sensibility = 0.005
    camRot.yaw = camRot.yaw - dx * sensibility
    camRot.pitch = camRot.pitch + dy * sensibility
end

function Game:keypressed(key)
    if key == "f1" then
        lockControls = not lockControls
        love.mouse.setRelativeMode(lockControls)
    end
end


return Game
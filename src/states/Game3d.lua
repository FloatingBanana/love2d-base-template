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
local ToonMaterial     = require "engine.3D.materials.toonMaterial"

local SSAOClass        = require "engine.postProcessing.ssao"
local BloomClass       = require "engine.postProcessing.bloom"
local HDRClass         = require "engine.postProcessing.hdr"
local ColorCorrection  = require "engine.postProcessing.colorCorrection"
local FogClass         = require "engine.postProcessing.fog"
local FXAAClass        = require "engine.postProcessing.fxaa"
local MotionBlurClass  = require "engine.postProcessing.motionBlur"
local PhysBloomClass   = require "engine.postProcessing.physicalBloom"
local SobelOutline     = require "engine.postProcessing.sobelOutline"

local GS = require "libs.gamestate"
local Color = require "libs.color"
local DebugDisplayState = require "states.debugDisplay"

local cubeShader = love.graphics.newShader [[
uniform mat4 u_viewProj;

vec4 position(mat4 transformProjection, vec4 position) {
    return u_viewProj * position;
}
]]


local graphicsStatsInfo = love.graphics.getStats()

local renderer = nil ---@type BaseRenderer
local myModel = nil ---@type Model
local personAnimator = nil --- @type ModelAnimator

local showAABB = false
local useDeferredRendering = true


-- Post processing effects
-- local bloom = BloomClass(SCREENSIZE, 6, 1)
-- local fog = FogClass(SCREENSIZE, 5, 100, Color(.4,.4,.4))
-- local motionBlur = MotionBlurClass(SCREENSIZE, 0.35)
local ssao = SSAOClass(SCREENSIZE, 32, 0.5)
local bloom = PhysBloomClass(SCREENSIZE)
local hdr = HDRClass(SCREENSIZE, 3)
local colorCorr = ColorCorrection(SCREENSIZE, 1, 0, 1, 1, Color(1,1,1))
local fxaa = FXAAClass(SCREENSIZE)
local sobelOutline = SobelOutline(SCREENSIZE, 2, {0,0,0,.5})

local playerCam = Camera(Vector3(0, 1, -2), Quaternion.Identity(), math.rad(60), SCREENSIZE, 0.1, 1000)

local ambient = AmbientLight(Color(.2,.2,.2))
local light = SpotLight(Vector3(0), Vector3(0,0,1), math.rad(17), math.rad(25.5), Color(50,50,50), Color(50,50,50)):setShadowMapping(1024, false)
local light2 = PointLight(Vector3(0), 0, 0, 1, Color(50,50,50), Color(50,50,50)):setShadowMapping(512, false)
-- local light3 = DirectionalLight(Vector3(-1, 1,-1), -Vector3(1,-1, 1):normalize(), Color(1,1,1), Color(1,1,1)):setShadowMapping(2048, false)

function Game:enter(from, ...)
    love.mouse.setRelativeMode(true)

    if useDeferredRendering then
        renderer = DeferredRenderer(SCREENSIZE, playerCam, PBRMaterial())
    else
        renderer = ForwardRenderer(SCREENSIZE, playerCam)
    end

    renderer:addPostProcessingEffects(
        ssao,
        -- fog,
        bloom,
        hdr,
        fxaa,
        -- sobelOutline,
        -- motionBlur,
        colorCorr
    )

    renderer:addLights(ambient, light, light2)

    local environmentTexture = love.graphics.newImage("assets/images/environment.exr")
    local irradianceTexture = love.graphics.newImage("assets/images/environment_irradiance.dds")
    local radianceTexture = love.graphics.newImage("assets/images/environment_radiance.dds")
    renderer.skyBoxTexture = CubemapUtils.equirectangularMapToCubeMap(environmentTexture, "rg11b10f")
    renderer.environmentRadianceMap = CubemapUtils.equirectangularMapToCubeMap(radianceTexture, "rg11b10f")
    renderer.irradianceMap = CubemapUtils.equirectangularMapToCubeMap(irradianceTexture, "rg11b10f")

    -- renderer.irradianceMap = CubemapUtils.getIrradianceMap(renderer.skyBoxTexture)
    -- renderer.environmentRadianceMap = CubemapUtils.getEnvironmentRadianceMap(renderer.skyBoxTexture)


    myModel = Model("assets/models/untitled.gltf", {
        materials = {
            default = PBRMaterial()
        },
        triangulate = true,
        flipUVs = true,
        removeUnusedMaterials = true
    })

    personAnimator = myModel.animations["running"]:getNewAnimator(myModel.armatures.Armature, myModel.nodes.Person:getGlobalMatrix())
    personAnimator:play()
end

function Game:draw()
    love.graphics.draw(renderer:render())

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

    love.graphics.setBlendMode("alpha", "alphamultiply")
    love.graphics.getStats(graphicsStatsInfo)


    for i, light in ipairs(renderer.lights) do ---@diagnostic disable-line: invisible
        local pos = (light.position or Vector3(0)):clone():worldToScreen(playerCam.viewPerspectiveMatrix, SCREENSIZE, 0, 1) ---@diagnostic disable-line: undefined-field

        if pos.z > 0 and pos.z < 1 then
            local z = 1 - pos.z
            love.graphics.circle("fill", pos.x, pos.y, z*300)
            love.graphics.rectangle("fill", pos.x-z*100, pos.y, z*200, z*450)
        end
    end

    if showAABB then
        love.graphics.push("all")
        love.graphics.setWireframe(true)
        love.graphics.setMeshCullMode("front")
        love.graphics.setShader(cubeShader)

        for c, config in ipairs(renderer.meshParts) do
            local min, max = config.meshPart.aabb:getMinMaxTransformed(config.worldMatrix)
            local worldMatrix = Matrix.CreateScale((max - min) / 2) * Matrix.CreateTranslation((min + max) * 0.5)

            cubeShader:send("u_viewProj", "column", (worldMatrix * playerCam.viewPerspectiveMatrix):toFlatTable())
            love.graphics.draw(CubemapUtils.cubeMesh)
        end
        love.graphics.pop()
    end
end


local camRot = Vector3()
function Game:update(dt)
    personAnimator:update(dt)

    if GS.current() == Game then
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
    end
end

function Game:mousemoved(x, y, dx, dy)
    local sensibility = 0.005
    camRot.yaw = camRot.yaw - dx * sensibility
    camRot.pitch = camRot.pitch + dy * sensibility
end

function Game:keypressed(key)
    if key == "f1" then
        GS.push(DebugDisplayState, {renderer = renderer, model = myModel, graphicsStatsInfo = graphicsStatsInfo})
    end

    if key == "f2" then
        showAABB = not showAABB
    end
end


return Game
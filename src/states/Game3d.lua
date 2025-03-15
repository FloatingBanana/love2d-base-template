local Game = {}

local Matrix4          = require "engine.math.matrix4"
local Vector3          = require "engine.math.vector3"
local Vector2          = require "engine.math.vector2"
local Quaternion       = require "engine.math.quaternion"
local InputHelper      = require "engine.misc.inputHelper"
local Model            = require "engine.3D.model.model"
local Camera           = require "engine.misc.camera3d"
local CubemapUtils     = require "engine.misc.cubemapUtils"
local SH9Color         = require "engine.math.SH9Color"
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

local IrradianceVolume = require "engine.3D.renderers.irradianceVolume"

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
local sobelOutline = SobelOutline(SCREENSIZE, 2, {0,0,0,.5})

local playerCam = Camera(Vector3(0, 1, -2), Quaternion.Identity(), math.rad(60), SCREENSIZE, 0.1, 1000)

local ambient = AmbientLight(Color(.2,.2,.2))
local light = SpotLight(Vector3(0), Vector3(0,0,1), math.rad(17), math.rad(25.5), Color(50,50,50), Color(50,50,50)):setShadowMapping(1024, false)
local light2 = PointLight(Vector3(0), 0, 0, 1, Color(50,50,50), Color(50,50,50)):setShadowMapping(512, false)
-- local light3 = DirectionalLight(Vector3(-1, 1,-1), -Vector3(1,-1, 1):normalize(), Color(1,1,1), Color(1,1,1)):setShadowMapping(2048, false)

local irrVolume = IrradianceVolume(Matrix4.CreateTransformationMatrix(Quaternion.Identity(), Vector3(15,3,15), Vector3(0,1,0)), 32, Vector3(1), Vector2(0.1, 100))

function Game:enter(from, ...)
    love.mouse.setRelativeMode(true)

    local environmentTexture = CubemapUtils.equirectangularMapToCubeMap(love.graphics.newImage("assets/images/environment.exr"), "rgba16f")
    -- local irradianceTexture = CubemapUtils.equirectangularMapToCubeMap(love.graphics.newImage("assets/images/environment_irradiance.dds"), "rg11b10f")
    -- local radianceTexture = CubemapUtils.equirectangularMapToCubeMap(love.graphics.newImage("assets/images/environment_radiance.dds"), "rg11b10f")

    local radianceTexture = CubemapUtils.environmentRadianceMap(environmentTexture, Vector2(128))


    -- local irrSH = SH9Color.CreateFromEquirectangularMap(love.image.newImageData("assets/images/environment_irradiance.dds"))

    local defaultMaterial = PBRMaterial(radianceTexture)

    if useDeferredRendering then
        renderer = DeferredRenderer(SCREENSIZE, playerCam, defaultMaterial)
    else
        renderer = ForwardRenderer(SCREENSIZE, playerCam)
    end

    renderer.skyBoxTexture = environmentTexture

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


    myModel = Model("assets/models/untitled.gltf", {
        materials = {
            default = defaultMaterial
        },
        triangulate = true,
        flipUVs = true,
        removeUnusedMaterials = true
    })

    personAnimator = myModel.animations["running"]:getNewAnimator(myModel.armatures.Armature, myModel.nodes.Person:getGlobalMatrix())
    personAnimator:play()


    irrVolume.renderer.skyBoxTexture = environmentTexture

    local lv = IrradianceVolume(Matrix4.Identity(), 1, Vector3(1), Vector2(0.1, 100))
    lv:mapProbes(function (probe, index)
        return
            (SH9Color.ProjectDirection(Vector3(1,0,0)):multiply(Vector3(30)) +
            SH9Color.ProjectDirection(Vector3(-1,0,0)):multiply(Vector3(30)) +
            SH9Color.ProjectDirection(Vector3(0,1,0)):multiply(Vector3(30)) +
            SH9Color.ProjectDirection(Vector3(0,-1,0)):multiply(Vector3(30)) +
            SH9Color.ProjectDirection(Vector3(0,0,1)):multiply(Vector3(30)) +
            SH9Color.ProjectDirection(Vector3(0,0,-1)):multiply(Vector3(30))) * (1/6)
    end)

    irrVolume.renderer:addLights(ambient)

    myModel.contentLoader:loadAll()
    for name, mesh in pairs(myModel.meshes) do
        for i, part in ipairs(mesh.parts) do
            local config = irrVolume.renderer:pushMeshPart(part)
            config.worldMatrix = mesh:getGlobalMatrix()

            part.material.environmentRadianceMap = radianceTexture
            part.material.irradianceVolumeProbeBuffer = lv.probeBuffer
            part.material.irradianceVolumeInvTransform = lv.transform.inverse
            part.material.irradianceVolumeGridSize = lv.gridSize
        end
    end

    irrVolume:bake()
end

function Game:draw()
    love.graphics.draw(renderer:render())
    renderer:clearMeshParts()

    for name, mesh in pairs(myModel.meshes) do
        for i, part in ipairs(mesh.parts) do
            local config = renderer:pushMeshPart(part)
            config.material = part.material

            if name == "Drawer" then
                config.worldMatrix = mesh:getGlobalMatrix()-- * Matrix4.CreateFromYawPitchRoll(love.timer.getTime(), 0, 0)
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

            part.material.irradianceVolumeProbeBuffer = irrVolume.probeBuffer
            part.material.irradianceVolumeInvTransform = irrVolume.transform.inverse
            part.material.irradianceVolumeGridSize = irrVolume.gridSize
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



    local neighbors = {irrVolume:getNeighborCells(playerCam.position)}

    for i=1, #irrVolume.probes do
        local cell = irrVolume:getCell(i)
        local pos = irrVolume:getPositionFromCell(cell):worldToScreen(playerCam.viewPerspectiveMatrix, SCREENSIZE, 0, 1) ---@diagnostic disable-line: undefined-field

        if pos.z > 0 and pos.z < 1 then
            local z = 1 - pos.z

            love.graphics.setColor(1,1,1,1)
            for _, n in ipairs(neighbors) do
                if n == cell then
                    love.graphics.setColor(1,0,0,1)
                    break
                end
            end

            love.graphics.circle("fill", pos.x, pos.y, z*300)
        end
    end

    love.graphics.setColor(1,1,1,1)

    for i, n in ipairs(neighbors) do
        love.graphics.print(tostring(n), 10, 10 + i * 20)
    end

    if showAABB then
        love.graphics.push("all")
        love.graphics.setWireframe(true)
        love.graphics.setMeshCullMode("front")
        love.graphics.setShader(cubeShader)

        for c, config in ipairs(renderer.meshParts) do ---@diagnostic disable-line: invisible
            local min, max = config.meshPart.aabb:getMinMaxTransformed(config.worldMatrix)
            local worldMatrix = Matrix4.CreateScale((max - min) / 2) * Matrix4.CreateTranslation((min + max) * 0.5)

            cubeShader:send("u_viewProj", "column", (worldMatrix * playerCam.viewPerspectiveMatrix):toFlatTable())
            love.graphics.draw(CubemapUtils.cubeMesh)
        end


        for i=1, #irrVolume.probes do
            cubeShader:send("u_viewProj", "column", (Matrix4.CreateTransformationMatrix(Quaternion.Identity(), irrVolume.gridSize.inverse * 0.5, irrVolume:getCell(i) / irrVolume.gridSize + irrVolume.gridSize.inverse * 0.5 - 0.5) * irrVolume.transform * playerCam.viewPerspectiveMatrix):toFlatTable())
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
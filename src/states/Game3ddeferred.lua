local Game = {}

local Matrix = require "engine.math.matrix"
local Vector3 = require "engine.math.vector3"
local Vector2 = require "engine.math.vector2"
local Quaternion  = require "engine.math.quaternion"
local InputHelper = require "engine.inputHelper"
local Model = require "engine.3DRenderer.model"
local PointLight = require "engine.3DRenderer.lights.pointLight"
local SpotLight = require "engine.3DRenderer.lights.spotLight"
local DirectionalLight = require "engine.3DRenderer.lights.directionalLight"
local Lightmanager     = require "engine.3DRenderer.lights.lightmanager"
local Skybox           = require "engine.3DRenderer.skybox"
local DeferredMaterial = require "engine.3DRenderer.materials.deferredPhong"
local RenderDevice = require "engine.3DRenderer.3DRenderDevice"
local Stack = require "engine.collections.stack"

local myModel = Model("assets/models/untitled_uv.fbx", {
    materials = {
        drawer = DeferredMaterial,
        ground = DeferredMaterial,
        emissive = DeferredMaterial,
    }
})

local cloudSkybox = Skybox({
    "assets/images/skybox/right.jpg",
    "assets/images/skybox/left.jpg",
    "assets/images/skybox/top.jpg",
    "assets/images/skybox/bottom.jpg",
    "assets/images/skybox/front.jpg",
    "assets/images/skybox/back.jpg"
})

local deferredLightPassShader = lg.newShader(Utils.preprocessShader((lfs.read("engine/shaders/3D/deferred/lightPass.frag"))))
local display = lg.newCanvas(WIDTH, HEIGHT)

-- G-buffer
local gPosition = lg.newCanvas(WIDTH, HEIGHT, {format = "rgba16f"})
local gNormal = lg.newCanvas(WIDTH, HEIGHT, {format = "rgba16f"})
local gAlbedoSpec = lg.newCanvas(WIDTH, HEIGHT)

local renderer = RenderDevice(Vector2(WIDTH, HEIGHT), 8, .6, 5)


-- SSAO https://learnopengl.com/Advanced-Lighting/SSAO
local ssaoKernel = Stack()
for i=0, 32-1 do
    local sample = Vector3(
        math.random() * 2 - 1,
        math.random() * 2 - 1,
        math.random()
    )

    local scale = i / 32
    scale = Lume.lerp(0.1, 1, scale*scale)

    sample:normalize():multiply(scale)
    ssaoKernel:push({sample:split()})
end


local ssaoNoiseData = love.image.newImageData(4, 4, "rg8")
for i=0, 15 do
    local x = i % 4
    local y = math.floor(i/4)

    ssaoNoiseData:setPixel(x, y, math.random(), math.random(), 0, 0)
end
local ssaoNoise = lg.newImage(ssaoNoiseData)
ssaoNoise:setWrap("repeat")

local ssaoCanvas = lg.newCanvas(WIDTH, HEIGHT, {format = "r8"})
local ssaoShader = lg.newShader("engine/shaders/3D/deferred/ssao.frag")



local pos = Vector3(0, 0, -2)
local dir = Vector3()
local modelRot = 0

local lightmng = Lightmanager()
local light1 = DirectionalLight(Vector3(3, 3, 0), Color(.2,.2,.2), Color.WHITE, Color.WHITE)
local light = SpotLight(Vector3(0), Vector3(0,0,1), math.rad(17), math.rad(25.5), Color(.2,.2,.2), Color.WHITE, Color.WHITE)
local light2 = PointLight(Vector3(0), 1, 0.005, 0.04, Color(.4,.4,.4), Color.WHITE, Color.WHITE)
function Game:enter(from, ...)
    lm.setRelativeMode(true)

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
    lg.setCanvas({gPosition, gNormal, gAlbedoSpec, depth = true})
    lg.clear(Color.BLACK, Color.BLACK, Color.BLACK)

    lg.setDepthMode("lequal", true)
    lg.setBlendMode("replace")
    lg.setMeshCullMode("back")

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

    lg.setCanvas({gAlbedoSpec, depth = true})
    cloudSkybox:render(view, proj)

    lg.setCanvas()
    lg.setBlendMode("alpha", "alphamultiply")
    lg.setMeshCullMode("none")
    lg.setDepthMode()


    -- SSAO
    lg.setCanvas(ssaoCanvas)
    lg.setShader(ssaoShader)
    lg.clear()
    ssaoShader:send("u_gPosition", gPosition)
    ssaoShader:send("u_gNormal", gNormal)
    ssaoShader:send("u_noiseTex", ssaoNoise)
    ssaoShader:send("u_samples", unpack(ssaoKernel))
    ssaoShader:send("u_view", "column", view:toFlatTable())
    ssaoShader:send("u_projection", "column", proj:toFlatTable())
    lg.draw(display)
    lg.setCanvas()

    deferredLightPassShader:send("u_viewPosition", pos:toFlatTable())
    deferredLightPassShader:send("u_gPosition", gPosition)
    deferredLightPassShader:send("u_gNormal", gNormal)
    deferredLightPassShader:send("u_gAlbedoSpec", gAlbedoSpec)
    deferredLightPassShader:send("u_ssaoTex", ssaoCanvas)

    renderer:beginRendering()
    lg.setShader(deferredLightPassShader)
    lg.draw(display)
    lg.setShader()
    renderer:endRendering()

    if lk.isDown("q") then
        lg.draw(ssaoCanvas)
        -- lg.draw(light.shadowmap)
        -- lg.draw(gNormal)
    end

    lg.print("HDR exposure: "..renderer.hdrExposure, 0, 30)
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
    renderer.hdrExposure = math.max(renderer.hdrExposure + y * 0.1, 0)
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
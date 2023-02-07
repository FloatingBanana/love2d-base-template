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
local EmissiveMaterial = require "engine.3DRenderer.materials.emissiveMaterial"
local ForwardMaterial = require "engine.3DRenderer.materials.forwardRenderingMaterial"

local myModel = Model("assets/models/untitled_uv.fbx", {
    materials = {
        drawer = ForwardMaterial,
        ground = ForwardMaterial,
        emissive = EmissiveMaterial,
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

local brightFilterShader = lg.newShader [[
vec4 effect(vec4 color, sampler2D texture, vec2 texcoords, vec2 screencoords) {
    vec3 pixel = Texel(texture, texcoords).rgb;
    float brightness = dot(pixel, vec3(0.2126, 0.7152, 0.0722));
    float luminance = max(0.0, brightness - 1.0);

    return vec4(pixel * sign(luminance), 1.0);
}
]]

local hdrExposure = 0.6
local hdrShader = lg.newShader("engine/shaders/postprocessing/hdr.frag")
local blurShader = lg.newShader("engine/shaders/postprocessing/gaussianBlurOptimized.frag")
local hdrCanvas = lg.newCanvas(WIDTH, HEIGHT, {format = "rgba16f"})
local bloomCanvas = lg.newCanvas(WIDTH, HEIGHT, {format = "rgba16f"})

blurShader:send("texSize", {WIDTH, HEIGHT})
local blurCanvases = {
    [true] = lg.newCanvas(WIDTH, HEIGHT),
    [false] = lg.newCanvas(WIDTH, HEIGHT)
}

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

    for name, mesh in pairs(myModel.meshes) do
        if name ~= "light1" and name ~= "light2" then
            lightmng:addMeshParts(Matrix.identity(), unpack(mesh.parts))
        end
    end

    hdrShader:send("exposure", hdrExposure)
end

function Game:draw()
    lightmng:applyLighting()

    lg.setCanvas({hdrCanvas, depth = true})
    lg.clear(Color.BLUE * 0.2, Color.BLACK) ---@diagnostic disable-line

    lg.setDepthMode("lequal", true)
    lg.setBlendMode("replace")
    lg.setMeshCullMode("back")

    local view = Matrix.createLookAtDirection(pos, dir, Vector3(0, 1, 0))
    local proj = Matrix.createPerspectiveFOV(math.rad(60), WIDTH/HEIGHT, 0.01, 1000)

    for name, mesh in pairs(myModel.meshes) do
        for i, part in ipairs(mesh.parts) do
            local material = part.material
            local world = mesh.transformation * Matrix.createScale(Vector3(0.01))

            if name == "Drawer" then
                world = world * Matrix.createFromYawPitchRoll(modelRot, 0, 0)
            else
                world = world * Matrix.identity()
            end

            if name ~= "light1" and name ~= "light2" then
                lightmng:setMeshPartMatrix(part, world)
                material.viewPosition = pos
            end

            material.worldMatrix = world
            material.viewProjectionMatrix = view * proj

            part:draw()
        end
    end

    -- Skybox
    cloudSkybox:render(view, proj)

    lg.setCanvas(bloomCanvas)
    lg.setShader(brightFilterShader)
    lg.draw(hdrCanvas)

    -- Bloom
    local amount = 10
    lg.setShader(blurShader)
    lg.setBlendMode("alpha", "premultiplied")
    for i=1, amount do
        local horizontal = (i % 2) == 1
        local blurDir = horizontal and Vector2(1,0) or Vector2(0,1)

        blurShader:send("direction", blurDir:toFlatTable())
        lg.setCanvas(blurCanvases[horizontal])
        lg.draw(i==1 and bloomCanvas or blurCanvases[not horizontal])
    end

    lg.setCanvas()

    -- Render final result
    lg.setShader(hdrShader)
    hdrShader:send("bloomBlur", blurCanvases[false])
    lg.draw(hdrCanvas)

    lg.setBlendMode("alpha")
    lg.setMeshCullMode("none")
    lg.setDepthMode()

    lg.setShader()

    lg.print("HDR exposure: "..hdrExposure, 0, 30)
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

function Game:wheelmoved(x, y)
    hdrExposure = math.max(hdrExposure + y * 0.1, 0)
    hdrShader:send("exposure", hdrExposure)
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
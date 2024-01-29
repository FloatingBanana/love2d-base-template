local Game = {}

local ffi              = require "ffi"
local Matrix           = require "engine.math.matrix"
local Vector3          = require "engine.math.vector3"
local Quaternion       = require "engine.math.quaternion"
local InputHelper      = require "engine.misc.inputHelper"
local Model            = require "engine.3D.model.model"
local Camera           = require "engine.misc.camera3d"
local Mesh             = require "engine.3D.model.modelMesh"
local Meshpart         = require "engine.3D.model.meshpart"

local PointLight       = require "engine.3D.lights.pointLight"
local SpotLight        = require "engine.3D.lights.spotLight"
local DirectionalLight = require "engine.3D.lights.directionalLight"
local AmbientLight     = require "engine.3D.lights.ambientLight"

local DeferredRenderer = require "engine.3D.renderers.deferredRenderer"
local DeferredMaterial = require "engine.3D.materials.deferredMaterial"

local ForwardRenderer  = require "engine.3D.renderers.forwardRenderer"
local ForwardMaterial  = require "engine.3D.materials.forwardMaterial"
local EmissiveMaterial = require "engine.3D.materials.forwardEmissiveMaterial"

local SkyboxClass      = require "engine.postProcessing.skybox"
local SSAOClass        = require "engine.postProcessing.ssao"
local BloomClass       = require "engine.postProcessing.bloom"
local HDRClass         = require "engine.postProcessing.hdr"
local ColorCorrection  = require "engine.postProcessing.colorCorrection"
local FogClass         = require "engine.postProcessing.fog"
local FXAAClass        = require "engine.postProcessing.fxaa"
local MotionBlurClass  = require "engine.postProcessing.motionBlur"
local PhysBloomClass   = require "engine.postProcessing.physicalBloom"

local Color = require "libs.color"
local Imgui = require "libs.cimgui"


local renderer = nil ---@type BaseRenderer
local myModel = nil ---@type Model
local personAnimator = nil --- @type ModelAnimator
local drawer = 0

local lockControls = true
local useDeferredRendering = false


-- Post processing effects
local ssao = SSAOClass(SCREENSIZE, 32, 0.5, useDeferredRendering and "deferred" or "accurate")
-- local bloom = BloomClass(SCREENSIZE, 6, 1)
local bloom = PhysBloomClass(SCREENSIZE)
local hdr = HDRClass(SCREENSIZE, 1)
local colorCorr = ColorCorrection(SCREENSIZE, 1, 0, 1, 1, Color(1,1,1))
-- local fog = FogClass(SCREENSIZE, 5, 100, Color(.4,.4,.4))
local fxaa = FXAAClass(SCREENSIZE)
local motionBlur = MotionBlurClass(SCREENSIZE, 0.35)
local skybox = SkyboxClass({
    "assets/images/skybox/right.jpg",
    "assets/images/skybox/left.jpg",
    "assets/images/skybox/top.jpg",
    "assets/images/skybox/bottom.jpg",
    "assets/images/skybox/front.jpg",
    "assets/images/skybox/back.jpg"
})


local playerCam = Camera(Vector3(0, 1, -2), Quaternion.Identity(), math.rad(60), WIDTH/HEIGHT, 0.1, 1000)
local modelRot = 0

local ambient = AmbientLight(Color(.2,.2,.2))
local light = SpotLight(Vector3(0), Vector3(0,0,1), math.rad(17), math.rad(25.5), Color.WHITE, Color.WHITE)
local light2 = PointLight(Vector3(0), 1, 0.005, 0.04, Color(.2,.2,.2), Color.WHITE, Color.WHITE)
function Game:enter(from, ...)
    love.mouse.setRelativeMode(lockControls)

    local pplist = {
        skybox,
        ssao,
        -- fog,
        bloom,
        hdr,
        fxaa,
        motionBlur,
        colorCorr
    }


    local materials = {}
    if useDeferredRendering then
        materials.default = DeferredMaterial

        renderer = DeferredRenderer(SCREENSIZE, pplist)
    else
        materials.default = ForwardMaterial
        materials.emissive = EmissiveMaterial

        renderer = ForwardRenderer(SCREENSIZE, pplist)
    end

    myModel = Model("assets/models/untitled.fbx", {
        materials = materials,
        flags = {"triangulate", "sort by p type", "optimize meshes", "flip uvs", "calc tangent space"}
    })

    personAnimator = myModel.animations["Armature|Action"]:getNewAnimator(myModel.nodes.Armature, myModel.nodes.Person:getGlobalMatrix())
    personAnimator:play()

    -- Adding meshes to the scene
    for name, mesh in pairs(myModel.meshes) do
        local isEmissive = (name == "light1" or name == "light2")

        local id = renderer:addMesh({
            mesh = mesh,
            castShadows = not isEmissive,
            ignoreLighting = isEmissive,
            worldMatrix = mesh:getGlobalMatrix(),
            animator = (name == "Person" and personAnimator or nil)
        })

        if name == "Drawer" then
            drawer = id

            -- renderer:addMesh({
            --     mesh = mesh,
            --     castShadows = true,
            --     ignoreLighting = false,
            --     worldMatrix = mesh:getGlobalMatrix() * Matrix.CreateTranslation(Vector3(5, 0, 0)),
            --     animator = nil
            -- })
        end
    end

    renderer:addLights(ambient, light, light2)
end

function Game:draw()
    renderer:render(playerCam)

    -- Drawer anima
    local drawerConfig = renderer:getMeshConfig(drawer)
    drawerConfig.worldMatrix = myModel.meshes.Drawer:getGlobalMatrix() * Matrix.CreateFromYawPitchRoll(love.timer.getTime(), 0, 0)


    for i, light in ipairs(renderer.lights) do ---@diagnostic disable-line invisible
        local pos = light.position:clone():worldToScreen(playerCam.viewProjectionMatrix, SCREENSIZE, 0, 1)

        if pos.z > 0 and pos.z < 1 then
            local z = 1 - pos.z
            love.graphics.circle("fill", pos.x, pos.y, z*300)
            love.graphics.rectangle("fill", pos.x-z*100, pos.y, z*200, z*450)
        end
    end
end


local camRot = Vector3()
function Game:update(dt)
    modelRot = modelRot + dt

    personAnimator:update(dt)

    if lockControls then
        local walkdir = Vector3(
            -InputHelper.getAxis("horizontal"),
            0,
            -InputHelper.getAxis("vertical")
        )

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
        Game:debugGui()
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



local names = {
    [SkyboxClass]      = "Skybox",
    [SSAOClass]        = "SSAO",
    [BloomClass]       = "Bloom",
    [PhysBloomClass]   = "Physical Bloom",
    [HDRClass]         = "HDR",
    [ColorCorrection]  = "Color correction",
    [FogClass]         = "Fog",
    [FXAAClass]        = "FXAA",
    [MotionBlurClass]  = "Motion blur",
    [AmbientLight]     = "Ambient light",
    [DirectionalLight] = "Directional light",
    [SpotLight]        = "Spot light",
    [PointLight]       = "Point light",
}

local boolPtr = ffi.new("bool[1]")
local intPtr = ffi.new("int[1]")
local floatPtr = ffi.new("float[3]")
local strArrayPtr = ffi.new("const char*[3]")

local isDemoWindowOpen = ffi.new("bool[1]", false)
local isSceneWindowOpen = ffi.new("bool[1]", true)

--- @param node ModelNode
local function renderTree(node)
    local flag = #node.children == 0 and Imgui.ImGuiTreeNodeFlags_Leaf or Imgui.ImGuiTreeNodeFlags_None
    local nodeType = node:is(Mesh) and "Mesh" or node:is(Meshpart) and "Mesh Part" or "Empty"

    if Imgui.TreeNodeEx_Str(("%s (%s)"):format(node.name, nodeType), flag) then
        for i, child in ipairs(node.children) do
            renderTree(child)
        end
        Imgui.TreePop()
    end
end

---@diagnostic disable invisible
function Game:debugGui()
    if Imgui.BeginMainMenuBar() then
        if Imgui.BeginMenu("Windows") then
            Imgui.MenuItem_BoolPtr("Show scene window", nil, isSceneWindowOpen, true)
            Imgui.MenuItem_BoolPtr("Show demo window", nil, isDemoWindowOpen, true)

            Imgui.EndMenu()
        end
        Imgui.EndMainMenuBar()
    end

    if isSceneWindowOpen[0] and Imgui.Begin("3D Scene", isSceneWindowOpen, Imgui.ImGuiWindowFlags_None) then
        if Imgui.BeginTabBar("tabs", Imgui.ImGuiTabBarFlags_None) then

            if Imgui.BeginTabItem("General") then
                Imgui.Text("Rendering mode: "..(useDeferredRendering and "Deferred" or "Forward"))
                Imgui.Text(("Memory usage: %fmb"):format(collectgarbage("count") / 1024))

                Imgui.SeparatorText("Camera")

                floatPtr[0], floatPtr[1], floatPtr[2] = playerCam.position.x, playerCam.position.y, playerCam.position.z
                if Imgui.InputFloat3("Position", floatPtr) then
                    playerCam.position = Vector3(floatPtr[0], floatPtr[1], floatPtr[2])
                end

                floatPtr[0] = math.deg(playerCam.fov)
                if Imgui.SliderFloat("Field of view", floatPtr, 0, 180) then
                    playerCam.fov = math.rad(floatPtr[0])
                end

                Imgui.Separator()

                if renderer:is(DeferredRenderer) then ---@cast renderer DeferredRenderer
                    if Imgui.TreeNode_Str("Deferred renderer") then
                        Imgui.SeparatorText("G-buffer")
                        local imgSize = Imgui.ImVec2_Float(128, 128)
                        
                        Imgui.Image(renderer.gbuffer.normal, imgSize)
                        Imgui.SetItemTooltip("Normal")
                        Imgui.SameLine()

                        Imgui.Image(renderer.gbuffer.albedoSpec, imgSize)
                        Imgui.SetItemTooltip("Albedo + specular")
                        Imgui.SameLine()

                        Imgui.TreePop()
                    end
                end

                Imgui.EndTabItem()
            end

            if Imgui.BeginTabItem("Models") then
                if Imgui.TreeNode_Str("Scene") then
                    renderTree(myModel.rootNode)
                    Imgui.TreePop()
                end
                Imgui.EndTabItem()
            end

            if Imgui.BeginTabItem("Lights") then
                for i, light in ipairs(renderer.lights) do
                    if Imgui.TreeNode_Str(names[getmetatable(light)]) then

                        boolPtr[0] = light.enabled
                        if Imgui.Checkbox("Enabled", boolPtr) then
                            light.enabled = boolPtr[0]
                        end

                        if light:is(AmbientLight) then

                            floatPtr[0], floatPtr[1], floatPtr[2] = light.color.r, light.color.g, light.color.b
                            if Imgui.ColorEdit3("Ambient color", floatPtr) then
                                light.color = Color(floatPtr[0], floatPtr[1], floatPtr[2])
                            end
                        else
                            floatPtr[0], floatPtr[1], floatPtr[2] = light.position.x, light.position.y, light.position.z
                            if Imgui.InputFloat3("Position", floatPtr) then
                                light.position = Vector3(floatPtr[0], floatPtr[1], floatPtr[2])
                            end

                            floatPtr[0], floatPtr[1], floatPtr[2] = light.diffuse.r, light.diffuse.g, light.diffuse.b
                            if Imgui.ColorEdit3("Diffuse color", floatPtr) then
                                light.diffuse = Color(floatPtr[0], floatPtr[1], floatPtr[2])
                            end

                            floatPtr[0], floatPtr[1], floatPtr[2] = light.specular.r, light.specular.g, light.specular.b
                            if Imgui.ColorEdit3("Specular color", floatPtr) then
                                light.specular = Color(floatPtr[0], floatPtr[1], floatPtr[2])
                            end

                            floatPtr[0] = light.near
                            if Imgui.InputFloat("Near plane", floatPtr, 0, 200) then
                                light.near = floatPtr[0]
                            end

                            floatPtr[0] = light.far
                            if Imgui.InputFloat("Far plane", floatPtr, 0, 200) then
                                light.far = floatPtr[0]
                            end

                            if light:is(SpotLight) then ---@cast light SpotLight
                                floatPtr[0] = light.innerAngle
                                if Imgui.SliderFloat("Inner angle", floatPtr, 0, math.pi) then
                                    light.innerAngle = floatPtr[0]
                                end

                                floatPtr[0] = light.outerAngle
                                if Imgui.SliderFloat("Outer angle", floatPtr, 0, math.pi) then
                                    light.outerAngle = floatPtr[0]
                                end
                            end

                            if light:is(PointLight) then ---@cast light PointLight
                                floatPtr[0] = light.constant
                                if Imgui.SliderFloat("Constant", floatPtr, 0, 10) then
                                    light.constant = floatPtr[0]
                                end

                                floatPtr[0] = light.linear
                                if Imgui.SliderFloat("Linear", floatPtr, 0, 2) then
                                    light.linear = floatPtr[0]
                                end

                                floatPtr[0] = light.quadratic
                                if Imgui.SliderFloat("Quadratic", floatPtr, 0, 2) then
                                    light.quadratic = floatPtr[0]
                                end

                                Imgui.Text("Radius: "..light:getLightRadius())
                            end

                            if Imgui.TreeNode_Str("Shadow map") then
                                if light:is(PointLight) then
                                else
                                    local size = Imgui.ImVec2_Float(128, 128)
                                    Imgui.Image(light.shadowmap, size)
                                end

                                Imgui.TreePop()
                            end
                        end

                        Imgui.TreePop()
                    end
                end

                Imgui.EndTabItem()
            end

            if Imgui.BeginTabItem("Post processing") then
                for i, effect in ipairs(renderer.ppeffects) do
                    if Imgui.TreeNode_Str(names[getmetatable(effect)]) then

                        if effect:is(SSAOClass) then ---@cast effect SSAO
                            intPtr[0] = effect.algorithm == "naive" and 0 or effect.algorithm == "accurate" and 1 or 2
                            strArrayPtr[0], strArrayPtr[1], strArrayPtr[2] = "naive", "accurate", "deferred"

                            if Imgui.Combo_Str_arr("Algorithm", intPtr, strArrayPtr, 3, 3) then
                                effect = SSAOClass(SCREENSIZE, effect.kernelSize, effect.kernelRadius, ffi.string(strArrayPtr[intPtr[0]]))
                                renderer.ppeffects[i] = effect
                            end

                            intPtr[0] = effect.kernelSize
                            if Imgui.SliderInt("Kernel size", intPtr, 1, 64) then
                                effect:setKernelSize(intPtr[0])
                            end

                            floatPtr[0] = effect.kernelRadius
                            if Imgui.SliderFloat("Kernel radius", floatPtr, 0, 2) then
                                effect:setKernelRadius(floatPtr[0])
                            end
                        end

                        if effect:is(HDRClass) then ---@cast effect HDR
                            floatPtr[0] = effect.exposure
                            if Imgui.SliderFloat("Exposure", floatPtr, 0, 5) then
                                effect:setExposure(floatPtr[0])
                            end
                        end

                        if effect:is(BloomClass) then ---@cast effect Bloom
                            intPtr[0] = effect.strenght
                            if Imgui.SliderInt("Strenght", intPtr, 0, 15) then
                                effect.strenght = intPtr[0]
                            end

                            floatPtr[0] = effect.luminanceTreshold
                            if Imgui.SliderFloat("Luminance treshold", floatPtr, 0, 2) then
                                effect:setLuminanceTreshold(floatPtr[0])
                            end
                        end

                        if effect:is(PhysBloomClass) then ---@cast effect PhysicalBloom
                            floatPtr[0] = effect.bloomAmount
                            if Imgui.SliderFloat("Bloom amount", floatPtr, 0, 1) then
                                effect.bloomAmount = floatPtr[0]
                            end

                            floatPtr[0] = effect.filterRadius
                            if Imgui.SliderFloat("Filter radius", floatPtr, 0, 0.1) then
                                effect.filterRadius = floatPtr[0]
                            end

                            intPtr[0] = #effect.mipmaps
                            if Imgui.SliderInt("Mipmap count", intPtr, 1, 9) then
                                effect.mipmaps = effect:generateMipmaps(SCREENSIZE, intPtr[0])
                            end
                        end

                        if effect:is(MotionBlurClass) then ---@cast effect MotionBlur
                            floatPtr[0] = effect.amount
                            if Imgui.SliderFloat("amount", floatPtr, 0, 1) then
                                effect.amount = floatPtr[0]
                            end
                        end

                        if effect:is(FogClass) then ---@cast effect Fog
                            floatPtr[0], floatPtr[1] = effect.min, effect.max
                            if Imgui.SliderFloat2("Treshold", floatPtr, 0, 100) then
                                effect:setTreshold(floatPtr[0], floatPtr[1])
                            end

                            floatPtr[0], floatPtr[1], floatPtr[2] = effect.color.r, effect.color.g, effect.color.b
                            if Imgui.ColorEdit3("Fog color", floatPtr) then
                                effect:setColor(Color(floatPtr[0], floatPtr[1], floatPtr[2]))
                            end
                        end

                        if effect:is(ColorCorrection) then ---@cast effect ColorCorrection
                            floatPtr[0] = effect.brightness
                            if Imgui.SliderFloat("Brightness", floatPtr, -1, 1) then
                                effect:setBrightness(floatPtr[0])
                            end

                            floatPtr[0] = effect.contrast
                            if Imgui.SliderFloat("Contrast", floatPtr, 0, 2) then
                                effect:setContrast(floatPtr[0])
                            end

                            floatPtr[0] = effect.exposure
                            if Imgui.SliderFloat("Exposure", floatPtr, 0, 10) then
                                effect:setExposure(floatPtr[0])
                            end

                            floatPtr[0] = effect.saturation
                            if Imgui.SliderFloat("Saturation", floatPtr, 0, 2) then
                                effect:setSaturation(floatPtr[0])
                            end

                            floatPtr[0], floatPtr[1], floatPtr[2] = effect.colorFilter.r, effect.colorFilter.g, effect.colorFilter.b
                            if Imgui.ColorEdit3("Color filter", floatPtr) then
                                effect:setColorFilter(Color(floatPtr[0], floatPtr[1], floatPtr[2]))
                            end
                        end

                       Imgui.TreePop()
                    end
                end

                Imgui.EndTabItem()
            end

            Imgui.EndTabBar()
        end
    end
    Imgui.End()

    if isDemoWindowOpen[0] then
        Imgui.ShowDemoWindow(isDemoWindowOpen)
    end
end
---@diagnostic enable invisible

return Game
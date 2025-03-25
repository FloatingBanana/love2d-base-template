local DebugDisplay = {}

local DeferredRenderer = require "engine.3D.renderers.deferredRenderer"
local SSAOClass = require "engine.postProcessing.ssao"
local Vector3 = require "engine.math.vector3"
local Utils = require "engine.misc.utils"
local GS = require "libs.gamestate"
local Imgui = require "libs.cimgui"
local ffi = require "ffi"


local boolPtr = ffi.new("bool[10]")
local intPtr = ffi.new("int[10]")
local floatPtr = ffi.new("float[10]")
local strArrayPtr = ffi.new("const char*[3]")

local isRendererWindowOpen = true
local isModelWindowOpen = true
local prevState = {}
local debugData = {
    renderer = nil, ---@type BaseRenderer
    model = nil, ---@type Model
    graphicsStatsInfo = nil, ---@type table
}

local function fillPointer(pointer, ...)
    for i=1, select("#",...) do
        pointer[i-1] = select(i,...)
    end
    return pointer
end


--- @param node ModelNode
local function renderTree(node)
    local flag = #node.children == 0 and Imgui.ImGuiTreeNodeFlags_Leaf or Imgui.ImGuiTreeNodeFlags_None

    if Imgui.TreeNodeEx_Str(("%s (%s)"):format(node.name, node.ClassName), flag) then
        for i, child in ipairs(node.children) do
            renderTree(child)
        end
        Imgui.TreePop()
    end
end


function DebugDisplay:enter(from, data)
    prevState = from
    debugData = data
    love.mouse.setRelativeMode(false)
end

function DebugDisplay:update(dt)
    prevState:update(dt)

    ---@diagnostic disable: invisible

    if isRendererWindowOpen and Imgui.Begin("3D Renderer", fillPointer(boolPtr, isRendererWindowOpen), Imgui.ImGuiWindowFlags_None) then
        isRendererWindowOpen = boolPtr[0]

        if Imgui.BeginTabBar("rendererTabBar", Imgui.ImGuiTabBarFlags_None) then

            if Imgui.BeginTabItem("General") then
                Imgui.Text("Rendering mode:      "..(debugData.renderer:is(DeferredRenderer) and "Deferred" or "Forward"))
                Imgui.Text(("Memory usage:       %fmb"):format(collectgarbage("count") / 1024 / 1024))
                Imgui.Text(("Texture Memory:     %fmb"):format(debugData.graphicsStatsInfo.texturememory / 1024 / 1024))
                Imgui.Text(("Draw calls:         %d"):format(debugData.graphicsStatsInfo.drawcalls))
                Imgui.Text(("Batched draw calls: %d"):format(debugData.graphicsStatsInfo.drawcallsbatched))
                Imgui.Text(("Shader switches:    %d"):format(debugData.graphicsStatsInfo.shaderswitches))
                Imgui.Text(("Canvas switches:    %d"):format(debugData.graphicsStatsInfo.canvasswitches))
                Imgui.Text(("Loaded images:      %d"):format(debugData.graphicsStatsInfo.images))
                Imgui.Text(("Loaded canvas:      %d"):format(debugData.graphicsStatsInfo.canvases))
                Imgui.Text(("Loaded fonts:       %d"):format(debugData.graphicsStatsInfo.fonts))

                Imgui.SeparatorText("Camera")

                if Imgui.InputFloat3("Position", fillPointer(floatPtr, debugData.camera.position:split())) then
                    debugData.camera.position = Vector3(floatPtr[0], floatPtr[1], floatPtr[2])
                end

                if Imgui.SliderFloat("Field of view", fillPointer(floatPtr, math.deg(debugData.camera.fov)), 0, 180) then
                    debugData.camera.fov = math.rad(floatPtr[0])
                end

                Imgui.Separator()

                if debugData.renderer:is(DeferredRenderer) then ---@cast renderer DeferredRenderer
                    if Imgui.TreeNode_Str("Deferred renderer") then
                        Imgui.SeparatorText("G-buffer")
                        local imgSize = Imgui.ImVec2_Float(128, 128)

                        for i, buffer in ipairs(debugData.renderer.gbuffer) do
                            Imgui.Image(buffer, imgSize)
                            Imgui.SameLine()
                        end

                        Imgui.TreePop()
                    end
                end

                Imgui.EndTabItem()
            end

            if Imgui.BeginTabItem("Lights") then
                for i, light in ipairs(debugData.renderer.lights) do
                    if Imgui.TreeNode_Str(light.ClassName.."##"..i) then

                        if Imgui.Checkbox("Enabled", fillPointer(boolPtr, light.enabled)) then
                            light.enabled = boolPtr[0]
                        end

                        if light.ClassName == "AmbientLight" then
                            if Imgui.ColorEdit3("Ambient color", fillPointer(floatPtr, unpack(light.color))) then
                                light.color = {floatPtr[0], floatPtr[1], floatPtr[2]}
                            end
                        else
                            if Imgui.InputFloat3("Position", fillPointer(floatPtr, light.position:split())) then
                                light.position = Vector3(floatPtr[0], floatPtr[1], floatPtr[2])
                            end

                            if Imgui.ColorEdit3("Light color", fillPointer(floatPtr, unpack(light.color))) then
                                light.color = {floatPtr[0], floatPtr[1], floatPtr[2]}
                            end

                            if Imgui.ColorEdit3("Specular color", fillPointer(floatPtr, unpack(light.specular))) then
                                light.specular = {floatPtr[0], floatPtr[1], floatPtr[2]}
                            end

                            if Imgui.InputFloat("Near plane", fillPointer(floatPtr, light.nearPlane), 0, 200) then
                                light.nearPlane = floatPtr[0]
                            end

                            if Imgui.InputFloat("Far plane", fillPointer(floatPtr, light.farPlane), 0, 200) then
                                light.farPlane = floatPtr[0]
                            end

                            if light.ClassName == "SpotLight" then ---@cast light SpotLight
                                if Imgui.SliderFloat("Inner angle", fillPointer(floatPtr, light.innerAngle), 0, math.pi) then
                                    light.innerAngle = floatPtr[0]
                                end

                                if Imgui.SliderFloat("Outer angle", fillPointer(floatPtr, light.outerAngle), 0, math.pi) then
                                    light.outerAngle = floatPtr[0]
                                end
                            end

                            if light.ClassName == "PointLight" then ---@cast light PointLight
                                if Imgui.SliderFloat("Constant", fillPointer(floatPtr, light.constant), 0, 10) then
                                    light.constant = floatPtr[0]
                                end

                                if Imgui.SliderFloat("Linear", fillPointer(floatPtr, light.linear), 0, 2) then
                                    light.linear = floatPtr[0]
                                end

                                if Imgui.SliderFloat("Quadratic", fillPointer(floatPtr, light.quadratic), 0, 2) then
                                    light.quadratic = floatPtr[0]
                                end

                                Imgui.Text("Radius: "..light:getLightRadius())
                            end

                            -- if Imgui.TreeNode_Str("Shadow map") then
                            --     if light.ClassName == "PointLight" then
                            --     else
                            --         local size = Imgui.ImVec2_Float(128, 128)
                            --         Imgui.Image(light.shadowMap, size)
                            --     end

                            --     Imgui.TreePop()
                            -- end
                        end

                        Imgui.TreePop()
                    end
                end

                Imgui.EndTabItem()
            end

            if Imgui.BeginTabItem("Post processing") then
                for i, effect in ipairs(debugData.renderer.postProcessingEffects) do
                    if Imgui.TreeNode_Str(effect.ClassName) then

                        if effect.ClassName == "SSAO" then ---@cast effect SSAO
                            if Imgui.SliderInt("Kernel size", fillPointer(intPtr, effect.kernelSize), 1, 64) then
                                effect:setKernelSize(intPtr[0])
                            end

                            if Imgui.SliderFloat("Kernel radius", fillPointer(floatPtr, effect.kernelRadius), 0, 2) then
                                effect:setKernelRadius(floatPtr[0])
                            end

                            Imgui.Image(effect.ssaoCanvas, Imgui.ImVec2_Float(128, 128))
                        end

                        if effect.ClassName == "HDR" then ---@cast effect HDR
                            if Imgui.SliderFloat("Exposure", fillPointer(floatPtr, effect.exposure), 0, 5) then
                                effect.exposure = floatPtr[0]
                            end
                        end

                        if effect.ClassName == "Bloom" then ---@cast effect Bloom
                            if Imgui.SliderInt("Strenght", fillPointer(intPtr, effect.strenght), 0, 15) then
                                effect.strenght = intPtr[0]
                            end

                            if Imgui.SliderFloat("Luminance treshold", fillPointer(floatPtr, effect.luminanceTreshold), 0, 2) then
                                effect:setLuminanceTreshold(floatPtr[0])
                            end
                        end

                        if effect.ClassName == "PhysicalBloom" then ---@cast effect PhysicalBloom
                            if Imgui.SliderFloat("Bloom amount", fillPointer(floatPtr, effect.bloomAmount), 0, 1) then
                                effect.bloomAmount = floatPtr[0]
                            end

                            if Imgui.SliderFloat("Filter radius", fillPointer(floatPtr, effect.filterRadius), 0, 0.1) then
                                effect.filterRadius = floatPtr[0]
                            end

                            local maxMips = math.log(math.max(effect.blurCanvas:getDimensions()), 2)
                            if Imgui.SliderInt("Mipmap count", fillPointer(intPtr, #effect.mipmaps), 1, maxMips) then
                                effect.mipmaps = effect:generateMipmaps(intPtr[0])
                            end
                        end

                        if effect.ClassName == "MotionBlur" then ---@cast effect MotionBlur
                            if Imgui.SliderFloat("amount", fillPointer(floatPtr, effect.amount), 0, 1) then
                                effect.amount = floatPtr[0]
                            end
                        end

                        if effect.ClassName == "Fog" then ---@cast effect Fog
                            if Imgui.SliderFloat2("Treshold", fillPointer(floatPtr, effect.min, effect.max), 0, 100) then
                                effect:setTreshold(floatPtr[0], floatPtr[1])
                            end

                            if Imgui.ColorEdit3("Fog color", fillPointer(floatPtr, unpack(effect.color))) then
                                effect:setColor({floatPtr[0], floatPtr[1], floatPtr[2]})
                            end
                        end

                        if effect.ClassName == "ColorCorrection" then ---@cast effect ColorCorrection
                            if Imgui.SliderFloat("Brightness", fillPointer(floatPtr, effect.brightness), -1, 1) then
                                effect:setBrightness(floatPtr[0])
                            end

                            if Imgui.SliderFloat("Contrast", fillPointer(floatPtr, effect.contrast), 0, 2) then
                                effect:setContrast(floatPtr[0])
                            end

                            if Imgui.SliderFloat("Exposure", fillPointer(floatPtr, effect.exposure), 0, 10) then
                                effect:setExposure(floatPtr[0])
                            end

                            if Imgui.SliderFloat("Saturation", fillPointer(floatPtr, effect.saturation), 0, 2) then
                                effect:setSaturation(floatPtr[0])
                            end

                            if Imgui.ColorEdit3("Color filter", fillPointer(floatPtr, unpack(effect.colorFilter))) then
                                effect:setColorFilter({floatPtr[0], floatPtr[1], floatPtr[2]})
                            end
                        end

                        if effect.ClassName == "SobelOutline" then ---@cast effect SobelOutline
                            if Imgui.SliderFloat("Thickness", fillPointer(floatPtr, effect.thickness), 0, 10) then
                                effect.thickness = floatPtr[0]
                            end

                            if Imgui.ColorEdit4("Outline color", fillPointer(floatPtr, unpack(effect.color))) then
                                effect.color = {floatPtr[0], floatPtr[1], floatPtr[2], floatPtr[3]}
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






    if isModelWindowOpen and Imgui.Begin("Model Viewer", fillPointer(boolPtr, isModelWindowOpen), Imgui.ImGuiWindowFlags_None) then
        isModelWindowOpen = boolPtr[0]

        if Imgui.BeginTabBar("modelViewTabBar", Imgui.ImGuiTabBarFlags_None) then
            if Imgui.BeginTabItem("Node Hierarchy") then
                if Imgui.TreeNode_Str("Scene") then
                    renderTree(debugData.model.rootNode)
                    Imgui.TreePop()
                end

                Imgui.EndTabItem()
            end


            if Imgui.BeginTabItem("Armatures") then
                for armatureName, armature in pairs(debugData.model.armatures) do
                    if Imgui.TreeNode_Str(armatureName) then
                        for boneName, bone in pairs(armature.rootBones) do
                            renderTree(bone)
                        end

                        Imgui.TreePop()
                    end
                end

                Imgui.EndTabItem()
            end

            if Imgui.BeginTabItem("Materials") then
                for name, mat in pairs(debugData.model.materials) do
                    if Imgui.TreeNode_Str(("%s (%s)"):format(name, mat.ClassName)) then

                        if Imgui.BeginTable("MaterialAttributes", 3, Imgui.ImGuiTableFlags_BordersOuter) then
                            Imgui.TableSetupColumn("Name")
                            Imgui.TableSetupColumn("Uniform")
                            Imgui.TableSetupColumn("Value")
                            Imgui.TableHeadersRow()

                            for attrName, attr in pairs(mat.__attrs) do
                                Imgui.TableNextRow()

                                Imgui.TableSetColumnIndex(0)
                                Imgui.Text(attrName)

                                Imgui.TableSetColumnIndex(1)
                                Imgui.Text(attr.uniform)

                                Imgui.TableSetColumnIndex(2)
                                local attrType = Utils.getType(attr.value)
                                local labelID = "##"..attrName

                                if attrType == "number" and Imgui.InputFloat(labelID, fillPointer(floatPtr, attr.value)) then
                                    attr.value = floatPtr[0]
                                end

                                if attrType == "boolean" and Imgui.Checkbox(labelID, fillPointer(boolPtr, attr.value)) then
                                    attr.value = boolPtr[0]
                                end

                                if attrType == "table" and type(attr.value[1]) == "number" and #attr.value == 3 and Imgui.ColorEdit3(labelID, fillPointer(floatPtr, attr.value)) then
                                    attr.value = {floatPtr[0], floatPtr[1], floatPtr[2]}
                                end

                                if attrType == "table" and type(attr.value[1]) == "number" and #attr.value == 4 and Imgui.ColorEdit4(labelID, fillPointer(floatPtr, attr.value)) then
                                    attr.value = {floatPtr[0], floatPtr[1], floatPtr[2], floatPtr[3]}
                                end

                                if attrType == "Image" or attrName == "Canvas" then
                                    Imgui.Text(tostring(attr.value))

                                    if Imgui.BeginItemTooltip() then
                                        local size = Imgui.ImVec2_Float(128, 128)
                                        Imgui.Image(attr.value, size)

                                        Imgui.EndTooltip()
                                    end
                                end

                            end

                            Imgui.EndTable()
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

    ---@diagnostic enable: invisible
end

function DebugDisplay:draw()
    prevState:draw()
end


function DebugDisplay:keypressed(key)
    if key == "f4" then
        isModelWindowOpen = true
        isRendererWindowOpen = true
    end

    if key == "f1" then
        GS.pop()
        love.mouse.setRelativeMode(true)
    end
end

return DebugDisplay
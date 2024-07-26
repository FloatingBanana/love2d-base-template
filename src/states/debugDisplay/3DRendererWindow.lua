---@diagnostic disable: invisible

local DeferredRenderer = require "engine.3D.renderers.deferredRenderer"
local SSAOClass = require "engine.postProcessing.ssao"
local Vector3 = require "engine.math.vector3"
local Imgui = require "libs.cimgui"
local ffi = require "ffi"

local boolPtr = ffi.new("bool[10]")
local intPtr = ffi.new("int[10]")
local floatPtr = ffi.new("float[10]")
local strArrayPtr = ffi.new("const char*[3]")

local function fillPointer(pointer, ...)
    for i=1, select("#",...) do
        pointer[i-1] = select(i,...)
    end
    return pointer
end


---@param isWindowOpen boolean
---@param renderer BaseRenderer
---@param graphicsStatsInfo table
---@return boolean
local function render(isWindowOpen, renderer, graphicsStatsInfo)
    if isWindowOpen and Imgui.Begin("3D Renderer", fillPointer(boolPtr, isWindowOpen), Imgui.ImGuiWindowFlags_None) then
        isWindowOpen = boolPtr[0]

        if Imgui.BeginTabBar("rendererTabBar", Imgui.ImGuiTabBarFlags_None) then

            if Imgui.BeginTabItem("General") then
                Imgui.Text("Rendering mode:      "..(renderer:is(DeferredRenderer) and "Deferred" or "Forward"))
                Imgui.Text(("Memory usage:       %fmb"):format(collectgarbage("count") / 1024 / 1024))
                Imgui.Text(("Texture Memory:     %fmb"):format(graphicsStatsInfo.texturememory / 1024 / 1024))
                Imgui.Text(("Draw calls:         %d"):format(graphicsStatsInfo.drawcalls))
                Imgui.Text(("Batched draw calls: %d"):format(graphicsStatsInfo.drawcallsbatched))
                Imgui.Text(("Shader switches:    %d"):format(graphicsStatsInfo.shaderswitches))
                Imgui.Text(("Canvas switches:    %d"):format(graphicsStatsInfo.canvasswitches))
                Imgui.Text(("Loaded images:      %d"):format(graphicsStatsInfo.images))
                Imgui.Text(("Loaded canvas:      %d"):format(graphicsStatsInfo.canvases))
                Imgui.Text(("Loaded fonts:       %d"):format(graphicsStatsInfo.fonts))

                Imgui.SeparatorText("Camera")

                if Imgui.InputFloat3("Position", fillPointer(floatPtr, renderer.camera.position:split())) then
                    renderer.camera.position = Vector3(floatPtr[0], floatPtr[1], floatPtr[2])
                end

                if Imgui.SliderFloat("Field of view", fillPointer(floatPtr, math.deg(renderer.camera.fov)), 0, 180) then
                    renderer.camera.fov = math.rad(floatPtr[0])
                end

                Imgui.Separator()

                if renderer:is(DeferredRenderer) then ---@cast renderer DeferredRenderer
                    if Imgui.TreeNode_Str("Deferred renderer") then
                        Imgui.SeparatorText("G-buffer")
                        local imgSize = Imgui.ImVec2_Float(128, 128)

                        for i, bufferPart in ipairs(renderer.gbuffer) do
                            Imgui.Image(bufferPart.buffer, imgSize)
                            Imgui.SetItemTooltip(bufferPart.uniform)
                            Imgui.SameLine()
                        end

                        Imgui.TreePop()
                    end
                end

                Imgui.EndTabItem()
            end

            if Imgui.BeginTabItem("Lights") then
                for i, light in ipairs(renderer.lights) do
                    if Imgui.TreeNode_Str(light.ClassName) then

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
                for i, effect in ipairs(renderer.postProcessingEffects) do
                    if Imgui.TreeNode_Str(effect.ClassName) then

                        if effect.ClassName == "SSAO" then ---@cast effect SSAO
                            if Imgui.SliderInt("Kernel size", fillPointer(intPtr, effect.kernelSize), 1, 64) then
                                effect:setKernelSize(intPtr[0])
                            end

                            if Imgui.SliderFloat("Kernel radius", fillPointer(floatPtr, effect.kernelRadius), 0, 2) then
                                effect:setKernelRadius(floatPtr[0])
                            end

                            Imgui.Image(effect.ssaoCanvas, Imgui.ImVec2_Float(128, 128))

                            Imgui.TreePop()
                        end

                        if effect.ClassName == "HDR" then ---@cast effect HDR
                            if Imgui.SliderFloat("Exposure", fillPointer(floatPtr, effect.exposure), 0, 5) then
                                effect:setExposure(floatPtr[0])
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
                                effect.mipmaps = effect:generateMipmaps(SCREENSIZE, intPtr[0])
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

                        Imgui.TreePop()
                    end
                end

                Imgui.EndTabItem()
            end

            Imgui.EndTabBar()
        end
    end
    Imgui.End()

    return isWindowOpen
end

return render
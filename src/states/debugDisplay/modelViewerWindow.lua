---@diagnostic disable: invisible

local Utils = require "engine.misc.utils"
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


---@param isWindowOpen boolean
---@param model Model
---@return boolean
local function render(isWindowOpen, model)
    if isWindowOpen and Imgui.Begin("Model Viewer", fillPointer(boolPtr, isWindowOpen), Imgui.ImGuiWindowFlags_None) then
        isWindowOpen = boolPtr[0]

        if Imgui.BeginTabBar("modelViewTabBar", Imgui.ImGuiTabBarFlags_None) then
            if Imgui.BeginTabItem("Node Hierarchy") then
                if Imgui.TreeNode_Str("Scene") then
                    renderTree(model.rootNode)
                    Imgui.TreePop()
                end

                Imgui.EndTabItem()
            end

            if Imgui.BeginTabItem("Materials") then
                for name, mat in pairs(model.materials) do
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

                                if attrType == "number" and Imgui.InputFloat("", fillPointer(floatPtr, attr.value)) then
                                    attr.value = floatPtr[0]
                                end

                                if attrType == "boolean" and Imgui.Checkbox("", fillPointer(boolPtr, attr.value)) then
                                    attr.value = boolPtr[0]
                                end

                                if attrType == "table" and type(attr.value[1]) == "number" and #attr.value == 3 and Imgui.ColorEdit3("", fillPointer(floatPtr, attr.value)) then
                                    attr.value = {floatPtr[0], floatPtr[1], floatPtr[2]}
                                end

                                if attrType == "table" and type(attr.value[1]) == "number" and #attr.value == 4 and Imgui.ColorEdit4("", fillPointer(floatPtr, attr.value)) then
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

    return isWindowOpen
end

return render
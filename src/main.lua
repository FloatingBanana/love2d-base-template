-- VS Code debugger
if os.getenv("LOCAL_LUA_DEBUGGER_VSCODE") == "1" then
    require("lldebugger").start()
end

-- Misc
local GS = require "libs.gamestate"
local Imgui = require "libs.cimgui"
local Utils = require "engine.misc.utils"
local InputHelper = require "engine.misc.inputHelper"
local TransitionManager = require "engine.transitions.transitionManager"

local Game = require "states.Game3d"
local Splash = require "states.Splash2"

function love.load(args)
    Imgui.love.Init()

    InputHelper.registerAxis("horizontal", {"a", "left"}, {"d", "right"})
    InputHelper.registerAxis("vertical", {"w", "up"}, {"s", "down"})

    GS.registerEvents({"update"})
    GS.switch(Game)
end


function love.draw() ---@diagnostic disable-line: duplicate-set-field
    GS.draw()

    TransitionManager.draw()

    Imgui.Render()
    Imgui.love.RenderDrawLists()

    Utils.setFont(13)
    love.graphics.setColor(1,1,1,1)
    love.graphics.print("FPS: " .. love.timer.getFPS())
end

function love.update(dt)
    Imgui.love.Update(dt)
    Imgui.NewFrame()

    TransitionManager.update(dt)
end



function love.keypressed(key)
    if key == "escape" then
        love.event.quit()
    end

    Imgui.love.KeyPressed(key)
    if Imgui.love.GetWantCaptureKeyboard() then
        return
    end

    GS.keypressed(key)
end

function love.keyreleased(key, ...)
    Imgui.love.KeyReleased(key)
    if Imgui.love.GetWantCaptureKeyboard() then
        return
    end

    GS.keyreleased(key, ...)
end

function love.textinput(t)
    Imgui.love.TextInput(t)
    if Imgui.love.GetWantCaptureKeyboard() then
        return
    end

    GS.textinput(t)
end

function love.mousemoved(x, y, ...)
    Imgui.love.MouseMoved(x, y)
    if Imgui.love.GetWantCaptureMouse() then
        return
    end

    GS.mousemoved(x, y, ...)
end

function love.mousepressed(x, y, button, ...)
    Imgui.love.MousePressed(button)
    if Imgui.love.GetWantCaptureMouse() then
        return
    end

    GS.mousepressed(x, y, button, ...)
end

function love.mousereleased(x, y, button, ...)
    Imgui.love.MouseReleased(button)
    if Imgui.love.GetWantCaptureMouse() then
        return
    end

    GS.mousereleased(x, y, button, ...)
end

function love.wheelmoved(x, y)
    Imgui.love.WheelMoved(x, y)
    if Imgui.love.GetWantCaptureMouse() then
        return
    end

    GS.wheelmoved(x, y)
end

function love.quit()
    return Imgui.love.Shutdown()
end
-- VS Code debugger
if os.getenv("LOCAL_LUA_DEBUGGER_VSCODE") == "1" then
    require("lldebugger").start()
end

NULLFUNC = function()end

-- Aliases
lg = love.graphics
la = love.audio
lm = love.mouse
lk = love.keyboard
lfs = love.filesystem

-- Libs
GS = require "libs.gamestate"
Timer = require "libs.timer"
Lume = require "libs.lume"
Object = require "libs.classic.classic"
Bump = require "libs.bump"
Anim8 = require "libs.anim8"
Draworder = require "libs.draworder"
Concord = require "libs.concord"
Color = require "libs.color"
Imgui = require "libs.cimgui"

Utils = require "engine.misc.init"
DebugUtils = require "engine.debug.debugUtils"
GLdebug = require "engine.debug.openglDebug"

-- Misc
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
    lg.setColor(1,1,1,1)
    lg.print("FPS: " .. love.timer.getFPS())
end

function love.update(dt)
    Imgui.love.Update(dt)
    Imgui.NewFrame()

    TransitionManager.update(dt)
    Timer.update(dt)
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
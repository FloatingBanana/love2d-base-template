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

Utils = require "engine.utils"

-- Misc
local InputHelper = require "engine.inputHelper"
local TransitionManager = require "engine.transitionManager"

local Game = require "states.Game3d"
local Splash = require "states.Splash2"

function love.load(args)
    InputHelper.registerAxis("horizontal", {"a", "left"}, {"d", "right"})
    InputHelper.registerAxis("vertical", {"w", "up"}, {"s", "down"})

    GS.registerEvents({"update", "mousepressed", "mousereleased", "mousemoved", "keypressed", "keyreleased"})
    GS.switch(Game)
end

function love.draw()
    GS.draw()

    TransitionManager.draw()

    Utils.setFont(13)
    lg.setColor(1,1,1,1)
    lg.print("FPS: " .. love.timer.getFPS())
end

function love.update(dt)
    TransitionManager.update(dt)
    Timer.update(dt)
end

function love.keypressed(key)
    if key == "escape" then
        love.event.quit()
    end
end
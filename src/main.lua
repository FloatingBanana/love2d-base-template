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
Vector = require "libs.brinevector"
Lume = require "libs.lume"
Object = require "libs.classic.classic"
Bump = require "libs.bump"
Anim8 = require "libs.anim8"
Draworder = require "libs.draworder"
Concord = require "libs.concord"

Utils = require "engine.utils"

-- Misc
local Game = require "states.Game"
local ECSGame = require "states.ECSGame"
local InputHelper = require "engine.inputHelper"

function love.load(args)
    InputHelper.registerAxis("horizontal", {"a", "left"}, {"d", "right"})
    InputHelper.registerAxis("vertical", {"w", "up"}, {"s", "down"})

    GS.registerEvents({"update", "mousepressed", "mousereleased", "keypressed", "keyreleased"})
    GS.switch(ECSGame)
end

function love.draw()
    GS.draw()

    lg.print("FPS: " .. love.timer.getFPS())
end

function love.update(dt)
    
end

function love.keypressed(key)
    if key == "escape" then
        love.event.quit()
    end
end
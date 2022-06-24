-- VS Code debugger
if os.getenv("LOCAL_LUA_DEBUGGER_VSCODE") == "1" then
    require("lldebugger").start()
end

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

-- Misc
local Game = require "states.Game"

function love.load(args)
    GS.registerEvents({"update", "mousepressed", "mousereleased", "keypressed", "keyreleased"})

    GS.switch(Game)
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
local UITest = {}
local Vector2 = require "engine.math.vector2"
local Rect = require "engine.math.rect"
local Textinput = require "engine.UI.textinput"
local Lume = require "engine.3rdparty.lume"

local input = Textinput(Rect(Vector2(100, 300), Vector2(200, 100)))
local hotswapOffset = 0

function UITest:enter(...)
    love.keyboard.setKeyRepeat(true)
end

function UITest:draw()
    input:draw()
end

function UITest:update(dt)
    input:update(dt)

    -- hotswapOffset = hotswapOffset + dt
    -- if hotswapOffset > 1 and not love.window.hasFocus() then
    --     hotswapOffset = 0

    --     Lume.hotswap("engine.UI.textinput")
    --     Textinput = require "engine.UI.textinput"
    --     input = Textinput(Rect(Vector2(100, 300), Vector2(200, 100)))
    -- end
end

function UITest:textinput(t)
    input:textinput(t)
end

function UITest:keypressed(k)
    input:keypressed(k)
end

return UITest
-- https://slembcke.github.io/SuperFastHardShadows
local inputHelper = require "engine.inputHelper"
local Vector2     = require "engine.vector2"
local PolyShadow  = require "engine.2DLighting.polygonShadowLighting"
local LT = {}

local light = nil
local light2 = nil
local body = {
    300, 100,
    400, 100,
    450, 150,
    400, 200,
    300, 200
}
local body2 = {
    300+200, 100+200,
    400+200, 100+200,
    450+200, 150+200,
    400+200, 200+200,
    300+200, 200+200
}

local lighting = PolyShadow(Color(.3,.3,.3,1))

function LT:enter()
    lighting:addOccluder(body, "cw")
    lighting:addOccluder(body2, "cw")
    light = lighting:addLight(Vector2(100, 100), 200, Color.RED, 1, 0.09, 0.032)
    light2 = lighting:addLight(Vector2(100, 100), 150, Color.WHITE, 1, 0.09, 0.032)
end

function LT:draw()
    lg.clear(Color("#6495ed") * 0.5)
    lg.setColor(1,1,1,1)
    lg.circle("fill", light.position.x, light.position.y, 10)

    lg.setColor(0,0,1,1)
    lg.polygon("line", body)
    lg.polygon("line", body2)

    lighting:renderLighting()
end

function LT:update(dt)
    walk = Vector2(
        inputHelper.getAxis("horizontal"),
        inputHelper.getAxis("vertical")
    )

    light.position = light.position + walk * (100 * dt)
    light2.position = Vector2(lm.getPosition())
end

return LT
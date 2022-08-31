local Game = {}

local Matrix = require "engine.matrix"
local Vector3 = require "engine.vector3"
local Quaternion  = require "engine.quaternion"
local InputHelper = require "engine.inputHelper"
local Model = require "engine.3DRenderer.model"

local myModel = Model("assets/models/untitled.obj")

local pos = Vector3(0, 0, -2)
local dir = Vector3()

local modelRot = 0

local shadowmap = lg.newCanvas(1024, 1024)
local depthmap = lg.newCanvas(1024, 1024, {format = "depth16", readable = true})
depthmap:setFilter("nearest", "nearest")
depthmap:setWrap("clamp")

local depthShader = lg.newShader [[
#ifdef VERTEX
uniform mat4 viewProj;
uniform mat4 world;

vec4 position(mat4 transformProjection, vec4 position) {
    position.y *= 1.0;
    return viewProj * world * position;
}
#endif

#ifdef PIXEL
vec4 effect(vec4 color, sampler2D texture, vec2 texcoords, vec2 screencoords) {
    return vec4(0);
}
#endif
]]

local depthRendererShader = lg.newShader [[
uniform sampler2D u_depthMap;

vec4 effect(vec4 color, sampler2D texture, vec2 texcoords, vec2 screencoords) {
    float depth = Texel(u_depthMap, texcoords).r;
    return vec4(vec3(depth), 1.0);
}
]]

function Game:enter(from, ...)
    lm.setRelativeMode(true)
end

function Game:draw()
    lg.setDepthMode("lequal", true)
    lg.setMeshCullMode("back")
    lg.setBlendMode("replace")

    -- Shadow mapping
    local lpos = Vector3(-10, 10, 0)
    local lightview = Matrix.createLookAt(lpos, Vector3(0,0,0), Vector3(0,1,0))
    local lightproj = Matrix.createOrthographicOffCenter(-10, 10, -10, 10, 1, 27.5)

    lg.setCanvas {depthstencil = depthmap}
    lg.clear()
    for name, mesh in pairs(myModel.meshes) do
        for i, part in ipairs(mesh.parts) do
            if name == "Drawer" then
                depthShader:send("world", "column", Matrix.createFromYawPitchRoll(modelRot, 0, 0):toFlatTable())
            else
                depthShader:send("world", "column", Matrix.identity():toFlatTable())
            end
            
            depthShader:send("viewProj", "column", (lightview * lightproj):toFlatTable())

            lg.setShader(depthShader)
            lg.draw(part.mesh)
        end
    end
    lg.setCanvas()

    -- Normal rendering
    local view = Matrix.createLookAt(pos, pos + dir, Vector3(0, 1, 0))
    local proj = Matrix.createPerspectiveFOV(math.rad(60), WIDTH/HEIGHT, 0.01, 1000)

    for name, mesh in pairs(myModel.meshes) do
        for i, part in ipairs(mesh.parts) do
            local material = part.material

            if name == "Drawer" then
                material.worldMatrix = Matrix.createFromYawPitchRoll(modelRot, 0, 0)
            else
                material.worldMatrix = Matrix.identity()
            end

            material.viewMatrix = view
            material.projectionMatrix = proj

            material.viewPosition = pos
            material.shininess = 32

            -- material.shader:send("u_spotLightsCount", 1)
            -- material.shader:send("u_spotLights[0].position", lightpos:toFlatTable())
            -- material.shader:send("u_spotLights[0].direction", lightdir:toFlatTable())

            -- material.shader:send("u_spotLights[0].ambient", {.2,.2,.2})
            -- material.shader:send("u_spotLights[0].diffuse", {.3,1,.7})
            -- material.shader:send("u_spotLights[0].specular", {.3,1,.7})

            -- material.shader:send("u_spotLights[0].cutOff", math.cos(math.rad(12)))
            -- material.shader:send("u_spotLights[0].outerCutOff", math.cos(math.rad(17.5)))

            material.shader:send("u_directionalLightsCount", 1)
            material.shader:send("u_directionalLights[0].position", lpos:toFlatTable())
            material.shader:send("u_directionalLights[0].ambient", {.2,.2,.2})
            material.shader:send("u_directionalLights[0].diffuse", {1,1,1})
            material.shader:send("u_directionalLights[0].specular", {1,1,1})
            material.shader:send("u_shadowMap", depthmap)
            material.shader:send("u_lightViewProj", "column", (lightview * lightproj):toFlatTable())

            part:draw()
        end
    end

    lg.setBlendMode("alpha")
    lg.setMeshCullMode("none")
    lg.setDepthMode()

    -- lg.setShader(depthRendererShader)
    -- depthRendererShader:send("u_depthMap", depthmap)
    -- lg.draw(shadowmap,0,0,0, .5, .5)

    lg.setShader()
end

local camRot = Vector3()
function Game:update(dt)
    local walkdir = Vector3(
        -InputHelper.getAxis("horizontal"),
        0,
        -InputHelper.getAxis("vertical")
    )

    local rot = Quaternion.createFromYawPitchRoll(camRot.yaw, camRot.pitch, camRot.roll)

    if walkdir.lengthSquared > 0 then
        pos:add(walkdir:normalize():transform(rot) * dt)
    end

    pos:add(Vector3(0, lk.isDown("space") and 1 or lk.isDown("lshift") and -1 or 0, 0) * dt)

    dir = Vector3(0, 0, 1):transform(rot)

    modelRot = modelRot + dt

    if lm.isDown(1) then
        lightpos, lightdir = pos:clone(), dir:clone()
    end
end

function Game:mousemoved(x, y, dx, dy)
    local sensibility = 0.005
    camRot.yaw = camRot.yaw - dx * sensibility
    camRot.pitch = camRot.pitch + dy * sensibility
end

function Game:keypressed(key)

end

function Game:keyreleased(key)

end

function Game:mousepressed(button)

end

function Game:mousereleased(button)

end

return Game
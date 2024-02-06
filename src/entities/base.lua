local Object = require "engine.3rdparty.classic.classic"
local Base   = Object:extend("Base")

function Base:new(position, layer)
    self.position = position
    self.layer = layer
    assert(layer, "invalid layer")
end

Base.onRemove = function()end

return Base
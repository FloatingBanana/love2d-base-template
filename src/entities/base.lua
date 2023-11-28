local Base = Object:extend()

function Base:new(position, layer)
    self.position = position
    self.layer = layer
    assert(layer, "invalid layer")
end

Base.onRemove = function()end

return Base
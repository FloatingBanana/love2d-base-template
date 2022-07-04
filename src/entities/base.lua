local Base = Object:extend()

function Base:new(position)
    self.position = position
end

Base.onRemove = NULLFUNC

return Base
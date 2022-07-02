local Base = Object:extend()

function Base:init(position)
    self.position = position
end

Base.onRemove = NULLFUNC
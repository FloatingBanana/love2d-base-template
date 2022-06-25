local Base = Object:extend()

function Base:init(position)
    self.position = position
end

Base.draw = NULLFUNC
Base.update = NULLFUNC
Base.keypressed = NULLFUNC
Base.keyreleased = NULLFUNC
Base.mousepressed = NULLFUNC
Base.mousereleased = NULLFUNC
Concord.component("collidable", function(comp, world, position, size)
    comp.world = world
    comp.size = size

    world:add(comp, position.x, position.y, size.x, size.y)
end)
local Concord = require "libs.concord"

Concord.component("transform", function(comp, position)
    comp.position = position
end)
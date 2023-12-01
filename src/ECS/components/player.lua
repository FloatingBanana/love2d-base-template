local Concord = require "libs.concord"

Concord.component("player", function(comp, speed)
    comp.speed = speed
end)
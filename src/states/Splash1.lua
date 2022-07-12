local Splash = {}

local Game = require "states.Game"

local TransitionManager = require "engine.transitionManager"
local Fade = require "engine.transitionManager.transitions.fade"

local heartImg = lg.newImage("assets/images/love_heart.png")
local backImg = lg.newImage("assets/images/love_back.png")

local heart = {x = CENTERX, y = HEIGHT+100, r = 0}
local back  = {x = CENTERX, y = HEIGHT+100}
local text  = {x = CENTERX - 50}
local text2 = {y = HEIGHT+100}

function Splash:enter(from, ...)
    Timer.script(function(wait)
		wait(.4)

		Timer.tween(.7, back, {y = CENTERY}, "out-quad")

        wait(.1)

        Timer.tween(.7, heart, {y = CENTERY}, "out-quad")

        wait(.9)

		Timer.tween(.7, heart, {x = heart.x + 100, r = math.pi*2}, "out-quad")
        Timer.tween(.7, back,  {x = back.x  + 100}, "out-quad")
		Timer.tween(.7, text,  {x = text.x  - 200}, "out-quad")
		Timer.tween(.8, text2, {y = text2.y - 150}, "out-quad")

        wait(2.5)

        TransitionManager.play(Fade(1, true, Color.BLACK))

        wait(1)

		GS.switch(Game)
	end)
end

function Splash:draw()
	lg.setColor(1,1,1,1)

    Utils.setFont("handy_andy", 28)
	lg.printf("Made with", text.x, CENTERY-40, 400, "center")

	Utils.setFont("handy_andy", 60)
	lg.printf("LÖVE", text.x, CENTERY-5, 400, "center")

	lg.setColor(0,0,0,1)
	lg.rectangle("fill", CENTERX+50, 0, CENTERX, HEIGHT)

	lg.setColor(1,1,1,1)
	lg.draw(backImg, back.x, back.y, 0, .3, .3, backImg:getWidth()/2, backImg:getHeight()/2)
	lg.draw(heartImg, heart.x, heart.y, heart.r, .3, .3, heartImg:getWidth()/2, heartImg:getHeight()/2)

    -- Left text
	Utils.setFont("handy_andy", 30)
	lg.printf("By FloatingBanana", 0, text2.y, CENTERX, "center")

    -- Right text
	Utils.setFont("polished", 30)
	lg.printf("Game JaaJ V", CENTERX, text2.y, CENTERX, "center")
end

return Splash
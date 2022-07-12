local Splash = {}

local Game = require "states.Game"

local heartImg = lg.newImage("assets/images/love_heart.png")
local backImg = lg.newImage("assets/images/love_back.png")

local TransitionManager = require "engine.transitionManager"
local Fade = require "engine.transitionManager.transitions.fade"

local heart    = {x = CENTERX, y = CENTERY, s = 0}
local back     = {x = CENTERX, y = CENTERY, s = 0, r = 0}
local opacity  = Color(1,1,1,0)
local opacity2 = Color(1,1,1,0)

function Splash:enter(from)
	Timer.script(function(wait)
		Timer.tween(.5, heart, {s = 0.36}, "out-back")

		wait(.5)

		Timer.tween(.6, back, {y = back.y - 133, r = math.pi*2, s = .3}, "out-cubic")

		wait(.1)

		Timer.tween(.6, heart, {y = heart.y - 133, s = .3}, "out-cubic")
		Timer.tween(1, opacity, {alpha = 1}, "linear")

		wait(.5)

		Timer.tween(1, opacity2, {alpha = 1}, "linear")

		wait(2)

		TransitionManager.play(Fade(1, true, Color.BLACK))

		wait(1)

		GS.switch(Game)
	end)
end

function Splash:draw()
	Utils.setFont("handy_andy", 28)
	lg.setColor(opacity)
	lg.printf("Made with", 0, CENTERY-40, WIDTH, "center")

	Utils.setFont("handy_andy", 60)
	lg.printf("LÖVE", 0, CENTERY-5, WIDTH, "center")

	Utils.setFont("handy_andy", 40)
	lg.setColor(opacity2)
	lg.printf("By FloatingBanana", 0, CENTERY+150, WIDTH, "center")

	lg.setColor(1,1,1,1)
	lg.draw(backImg, back.x, back.y, back.r, back.s, back.s, backImg:getWidth()/2, backImg:getHeight()/2)
	lg.draw(heartImg, heart.x, heart.y, heart.r, heart.s, heart.s, heartImg:getWidth()/2, heartImg:getHeight()/2)
end

return Splash
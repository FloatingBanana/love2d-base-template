local Splash = {}

local Game = require "states.Game"

local TransitionManager = require "engine.transitionManager"
local Fade = require "engine.transitionManager.transitions.fade"

local centerX = WIDTH/2
local centerY = HEIGHT/2

local heartImg = lg.newImage("assets/images/love_heart.png")
local backImg = lg.newImage("assets/images/love_back.png")

local values = {
    heart = {x = centerX, y = HEIGHT+100, r = 0},
	back  = {x = centerX, y = HEIGHT+100},
	text  = {x = centerX - 50},
	text2 = {y = HEIGHT+100}
}

function Splash:enter(from, ...)
    Timer.script(function(wait)
		wait(.4)

		Timer.tween(.7, values.back, {y = HEIGHT/2}, "out-quad")

        wait(.1)

        Timer.tween(.7, values.heart, {y = HEIGHT/2}, "out-quad")

        wait(.9)

		Timer.tween(.7, values.heart, {x = values.heart.x + 100, r = math.pi*2}, "out-quad")
        Timer.tween(.7, values.back,  {x = values.back.x  + 100}, "out-quad")
		Timer.tween(.7, values.text,  {x = values.text.x  - 200}, "out-quad")
		Timer.tween(.8, values.text2, {y = values.text2.y - 150}, "out-quad")

        wait(2.5)

        TransitionManager.play(Fade(1, true, Color.BLACK))

        wait(1)

		GS.switch(Game)
	end)
end

function Splash:draw()
	lg.setColor(1,1,1,1)
	
    Utils.setFont("handy_andy", 28)
	lg.printf("Made with", values.text.x, centerY-40, 400, "center")

	Utils.setFont("handy_andy", 60)
	lg.printf("LÖVE", values.text.x, centerY-5, 400, "center")
	
	lg.setColor(0,0,0,1)
	lg.rectangle("fill", centerX+50, 0, centerX, HEIGHT)
	
	lg.setColor(1,1,1,1)
	lg.draw(backImg, values.back.x, values.back.y, 0, .3, .3, backImg:getWidth()/2, backImg:getHeight()/2)
	lg.draw(heartImg, values.heart.x, values.heart.y, values.heart.r, .3, .3, heartImg:getWidth()/2, heartImg:getHeight()/2)

    -- Left text
	Utils.setFont("handy_andy", 30)
	lg.printf("By FloatingBanana", 0, values.text2.y, centerX, "center")

    -- Right text
	Utils.setFont("polished", 30)
	lg.printf("Game JaaJ V", centerX, values.text2.y, centerX, "center")

	-- fade.draw()
end

function Splash:update(dt)
    
end

return Splash
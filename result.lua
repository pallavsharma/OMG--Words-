require("gamestate")

Gamestate.result = Gamestate.new()
local state = Gamestate.result
local score = 0
local resultlevel = 0

function state:enter(pre, s)
	score = s
	if score >= 80000 then
		soundmanager:play(sounds.cheer)
		resultlevel = 3
		AwardManager:AwardTrophy("World-class typist")
	elseif score >= 25000 and score < 80000 then
		soundmanager:play(sounds.meh)
		resultlevel = 2
		AwardManager:AwardTrophy("Amateur blogger")
	else
		soundmanager:play(sounds.boo)
		resultlevel = 1
		AwardManager:AwardTrophy("Grandma")
		if score == 0 then
			AwardManager:Register("Utter failure", "0 points... Seriously?", 0)
			AwardManager:AwardTrophy("Utter failure")
		end
	end
	
	--Increase the total games played
	counter.played = counter.played+1
	if counter.played == 100 then
		AwardManager:AwardTrophy("Word junkie")
	end
	
	--round the saved score
	counter.score = math.floor(counter.score)
end

function state:update(dt)
	soundmanager:update(dt)
end

function state:draw()
	love.graphics.setColor(255,255,255)
	-- The shadows for the main area
	love.graphics.draw(images.sideshadow, 37, 132)
	love.graphics.draw(images.sideshadow, 762, 132, 0, -1, 1)
	
	-- Draw the main white area
	love.graphics.rectangle("fill", 50, 140, 700, 400)
	
	-- The head banner
	love.graphics.draw(images.banner, 0, 10)
	
	-- Score
	love.graphics.draw(images.score, 259, 100)
	love.graphics.setColor(238, 238, 238)
	love.graphics.setFont(fonts.bold64)
	love.graphics.print(score.."!", 365, 51)
	
	-- Portraits
	love.graphics.setColor(255,255,255)
	love.graphics.draw(images.joey, 165, 218)
	love.graphics.draw(images.ben, 165, 296)
	
	--speech bubbles
	love.graphics.draw(images.bubbles.result, 221, 218)
	love.graphics.draw(images.bubbles.result, 221, 296)
	
	love.graphics.setColor(66,66,66)
	love.graphics.setFont(fonts.regular14)
	love.graphics.printf(joey[resultlevel], 253, 228, 360, "left")
	love.graphics.printf(ben[resultlevel], 253, 306, 360, "left")
	
	--Further instructions
	love.graphics.setFont(fonts.bold28)
	love.graphics.setColor(42,44,46)
	love.graphics.print("Press", 231, 406)
	love.graphics.print("Press", 231, 439)
	
	love.graphics.print("to try again", 420, 406)
	love.graphics.print("to quit", 440, 439)
	
	love.graphics.setColor(241,93,34)
	love.graphics.print("ENTER", 316, 406)
	love.graphics.print("ESCAPE", 316, 439)
	
	
	-- Footer
	love.graphics.setColor(42,44,46)
	love.graphics.rectangle("fill", 0, 530, 800, 70)
	love.graphics.setFont(fonts.bold12)
	love.graphics.setColor(184,184,184)
	love.graphics.printf("OMG! Words! is developed and designed by Tommy Brunn in cooperation with the Love community", 252, 546, 340, "center")
end

function state:keypressed(key, unicode)
	if key == "return" then
		Gamestate.switch(Gamestate.game)
	elseif key == "escape" then
		love.event.push('q')
	end
end

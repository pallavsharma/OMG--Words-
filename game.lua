Gamestate.game = Gamestate.new()
local state = Gamestate.game
local score = 0
local cooldown = 2
local lives = 10
local words = {}
local timer = 0
local explosions = {}
local actors = {}

function state:enter(prev, s)
	-- In case we would like to be able to set the score to something.
	-- Maybe for a pause state or something.
	score = s or 0
	cooldown = 3
	timer = 0
	lives = 10
	words = {}
	actors = {}
	soundmanager:playMusic(soundmanager:shuffle(music.chica_mi_tipo, music.calma_la_libertad))
end

function state:leave()
	soundmanager:stop()
end

function state:update(dt)
	--update the music
	soundmanager:update(dt)
	
	--How long have we been playing?
	timer = timer+dt
	--Countdown until the next word
	cooldown = cooldown-dt-1*(timer/2000)
	
	--Add more words
	if cooldown <= 0 then
		local w = database:getWord()
		-- Add a horizontal offset so that we don't draw long words outside of the window
		table.insert(words, Word(w, math.random(55, 745-fonts.mono28:getWidth(w))))
		--reset the cooldown
		cooldown = 3
		
		--Add actors
		local dir = 0
		if math.random(1,100)%2 == 0 then
			dir = 1
		else
			dir = -1
		end
		-- If the word is one of these; summon teh great Joey
		local lowered = string.lower(w)
		if lowered == "ubuntu" or 
			lowered == "linux" or
			lowered == "tux" or
			lowered == "omg" or
			lowered == "awesome" or
			lowered == "tea" or
			lowered == "awesomeness" or
			lowered == "stunning" or
			lowered == "fantastic" or
			lowered == "danrabbit" or
			lowered == "candy" or
			lowered == "brunn" or --This is my secret way of making him write about me more often ;)
			lowered == "favourite" or
			lowered == "amazing" or
			lowered == "zeitgeist" or
			lowered == "elementary" then
				table.insert(actors, Helper(images.joey, math.random(170, 440), dir, 125))
		elseif #w > 8 then -- If it's a really long word, get Ben in there to screw with the player
			table.insert(actors, Trickster(images.ben, math.random(170, 440), dir, 125))
		end
	end
	
	local removelist = {}
	for i,v in ipairs(words) do
		-- Move and update the words
		v:update(dt, 50)
		
		--Remove out of bounds words
		if v.y > 550 then
			table.insert(removelist, i)
			
			-- If a word hits the bottom of the screen, subtract
			-- "health"
			lives = lives-1
			if lives <= 0 then
				Gamestate.switch(Gamestate.result, score)
			end
		end
	end
	for i,v in ipairs(removelist) do
		table.remove(words, v-i+1)
	end
	
	--update the actors
	local removelist_a = {}
	for i,v in ipairs(actors) do
		v:update(dt, words, explosions, score, timer)
		
		--Remove out of bounds actors
		if v.x <= -49 or v.x >= 849 then
			table.insert(removelist_a, i)
		end
	end
	for i,v in ipairs(removelist_a) do
		table.remove(actors, v-i+1)
	end
	
	--Update the explosions
	local removelist = {}
	for i,v in ipairs(explosions) do
		v:update(dt)
		if not v:isActive() then
			table.insert(removelist, i)
		end
	end
	for i,v in ipairs(removelist) do
		table.remove(explosions, v-i+1)
	end
end

function state:draw()
	love.graphics.setColor(255,255,255)
	-- The shadows for the main area
	love.graphics.draw(images.sideshadow, 37, 132)
	love.graphics.draw(images.sideshadow, 762, 132, 0, -1, 1)
	
	-- Draw the main white area
	love.graphics.rectangle("fill", 50, 140, 700, 400)
	
	--Draw the words
	for _,v in ipairs(words) do
		v:draw()
	end
	
	--Draw explosions
	for _,v in ipairs(explosions) do
		v:draw()
	end
	
	--Draw actors
	for _, v in ipairs(actors) do
		v:draw()
	end
	
	-- The head banner
	love.graphics.setColor(255,255,255)
	love.graphics.draw(images.banner, 0, 10)
	
	-- Score
	love.graphics.draw(images.score, 259, 100)
	love.graphics.setColor(238, 238, 238)
	love.graphics.setFont(fonts.bold64)
	local s = string.format("%.0f", score)
	love.graphics.print(s.."!", 365, 121)
	
	-- Footer
	love.graphics.setColor(42,44,46)
	love.graphics.rectangle("fill", 0, 530, 800, 70)

	
	--Portrait
	love.graphics.setColor(255,255,255)
	love.graphics.draw(images.ben, 217, 541)
	
	-- Speech bubble
	love.graphics.draw(images.bubbles.life, 274, 541)
	--Ben's remark
	love.graphics.setFont(fonts.regular14)
	love.graphics.setColor(42,44,46)
	love.graphics.print(healthmessages[lives], 294, 569)
	
	-- Words left to miss
	love.graphics.setFont(fonts.bold24)
	love.graphics.print(lives, 505-fonts.bold24:getWidth(lives), 580)
	love.graphics.setFont(fonts.bold12)
	love.graphics.print("words left", 508, 580)
end

function state:keypressed(key, unicode)
	if key == "escape" then
		Gamestate.switch(Gamestate.result, score)
	end
	
	-- See if the player typed the correct letter
	local removelist = {}
	local resetwords = false
	for i,v in ipairs(words) do
		if string.lower(key) == v.letters[v.typed+1] then
			--Typed the next letter in the word
			v.typed = v.typed +1
			
			--If that was the last letter, let's remove it
			if v.typed == v.length then
				table.insert(removelist, i)
				
				--for each letter in the word, add an explosion
				for n,k in ipairs(v.letters) do
					table.insert(explosions, ParticleSystem(v.x+(n-1)*18, v.y, k))
				end
				--Play a sound
				soundmanager:play(sounds.swoosh)
				--Increase the player's score
				score = score + (50+timer)*v.length
				
				-- Because we've finished a word, all the other words
				-- that have been started on should be reset.
				resetwords = true
			end
		else
			--Wrong letter, so reset any word that has been started on
			v.typed = 0
		end
	end
	-- Reset the words
	if resetwords then
		for _,v in ipairs(words) do
			v.typed = 0
		end
		resetwords = false
	end
	
	--And now actually remove the word
	for i,v in ipairs(removelist) do
		table.remove(words, v-i+1)
	end
end

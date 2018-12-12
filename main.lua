local inspect = require 'lib.inspect'

player = {
	character = 'grizzly',
	axe = {
		rotate_adjust = 0.5,
		scale = '0.1',
		velocity_y = 400,
		cooldown = 100,
		cooldown_rate = 50,
	},
	axe_default = {
		speed = 200,
		source = 'assets/axe.png',
	},
	jump_height = -300,
 	-- speed
	speed = 200,
	y_velocity = 0,
	-- image
	img_scale = 0.6,
	-- throws
	can_throw = true,
	throw_wait = 0,
	throws = {},
	-- allow up/down
	possible_up = false,
	possible_down = false,
	-- energy
	energy = {
		amount = 0,
		max = 50,
		rate_gain = 10,
		rate_loss = 40,
	},
}
world = {
	gravity = -800,
}
ui = {
	color = {
		reset = {1, 1, 1},
		red = {0.94, 0.12, 0.12},
		blue = {0.12, 0.12, 0.94},
	},
	help = {
		start_x = 650,
		start_y = 350,
		show = false,
		spacing = 15,
		messages = {
			'escape: quit',
			'a/d: left/right',
			'<space>: jump',
			'k (hold): power up',
			'k (release): throw',
		},
	},
	character = {
		avatar_source = 'assets/' .. player.character .. '-avatar.png',
		img_source = 'assets/' .. player.character .. '.png',
	},
	logo = {
		x = 550,
		y = 450,
		ac = {
			img_source = 'assets/animal-crossing-logo.png'
		},
		r = {
			img_source = 'assets/ragnarok.png',
			scale = 0.7
		},
	},
	energy = {
		x = 10,
		y = 550,
		width = 100,
		height = 15,
		target_min = 70,
		target_max = 90,
	}
}
presents = {
    balloon_defaults = {
    	velocity_x = 40,
		img_source = 'assets/present.png',
		default_y = 100,
		delay = 400,
		scale = 0.15,
		max_presents = 5,
		cooldown = 0,
		cooldown_rate = 50,
		cooldown_max = 200,
		max_y = 150,
		min_y = 50,
    },
	balloons = {},
}
 
function love.load()
	init_world()
	init_ui()
	init_player()
	init_presents()
end

function init_ui()
	ui.logo.ac.img = love.graphics.newImage(ui.logo.ac.img_source)
	ui.logo.r.img = love.graphics.newImage(ui.logo.r.img_source)
end

function init_world()
	world.width = love.graphics.getWidth()
	world.height = love.graphics.getHeight()
 
	world.x = 0
	world.y = 3 * (world.height / 4) -- this isn't really the world y value. world.land.y ?

	world.img_source = love.graphics.newImage('assets/snow.png')
	world.img_source:setWrap('repeat', 'repeat')

	world.img_tile = love.graphics.newQuad(0, 0, world.width, world.height/2, world.img_source:getWidth(), world.img_source:getHeight())
end

function init_player()
	-- start in center
	player.x = love.graphics.getWidth() / 2
	player.y = world.y
  
  	-- player image
	player.img = love.graphics.newImage(ui.character.img_source)
	player.avatar = love.graphics.newImage(ui.character.avatar_source)
	player.height = player.img:getHeight()
	player.width = player.img:getWidth()
	player.ground = player.y

    -- axe
	player.axe_img = love.graphics.newImage(player.axe_default.source)
end

function init_presents()
	presents.balloon_defaults.img = love.graphics.newImage(presents.balloon_defaults.img_source)
end

function love.update(dt)
	update_player(dt)
	update_presents(dt)
	detect_collision(dt)

	if love.keyboard.isDown('escape') then
		-- love.event.quit()
		os.exit()
	end
end

function detect_collision(delta)
	--print(#presents.balloons)
	--print(#player.throws)

	--[[ 
	if #presents.balloons > 0 and #player.throws > 0 then
		for index_b, balloon in ipairs(presents.balloons) do
			print('balloon... x: ' + ballon.x + ' y: ' + ballon.y)
		end
		for index_t, throw in ipairs(player.throws) do
			print('throw... x: ' + throw.x + ' y: ' + throw.y)
		end
		--[[ collision
		for index_b, balloon in ipairs(presents.balloons) do
			for index_t, throw in ipairs(player.throws) do
				if balloon.x < throw.x < balloon.x + balloon.img:getWidth() then
					print('in x')
					if balloon.y > throw.y > balloon.y - balloon.img:getHeight() then
						print('in y')
					end
				end
			end
		end
		]]--
	--end

	for index, throw in ipairs(player.throws) do
		throw.y = throw.y - delta * throw.speed -- speed/energy > change to velocity
		throw.r = throw.r + throw.r * delta
		
		if throw.y < -100 then
			table.remove(player.throws, index)
		end
	end
end

function update_presents(delta)
	-- introduce luck?
	if presents.balloon_defaults.cooldown > 0 then
		presents.balloon_defaults.cooldown = presents.balloon_defaults.cooldown - presents.balloon_defaults.cooldown_rate * delta
	elseif presents.balloon_defaults.cooldown <= 0 and #presents.balloons < presents.balloon_defaults.max_presents then
		if  delta > love.math.random() then
			if love.math.random() < love.math.random() then
				wind_direction = 'up'
			else
				wind_direction = 'down'
			end

			balloon = {
				x = world.width,
				y = presents.balloon_defaults.default_y + delta * 50, -- random variation ?
				r = 0,
				img = presents.balloon_defaults.img,
				scale = presents.balloon_defaults.scale,
				speed = presents.balloon_defaults.speed,
				velocity_x = presents.balloon_defaults.velocity_x,
				wind_direction = wind_direction
			}
			table.insert(presents.balloons, balloon)
			presents.balloon_defaults.cooldown = presents.balloon_defaults.cooldown_max
		else
			presents.balloon_defaults.cooldown = presents.balloon_defaults.cooldown + presents.balloon_defaults.cooldown_rate * delta
		end
	end

	for index, balloon in ipairs(presents.balloons) do
		balloon.x = balloon.x - delta * balloon.velocity_x
		-- update wind direction
		-- print(wind_direction)
		if balloon.y < presents.balloon_defaults.max_y then
			balloon.wind_direction = 'up'
		elseif balloon.y > presents.balloon_defaults.min_y then
			balloon.wind_direction = 'down'
		end
		-- wind up/down
		if balloon.wind_direction == 'up' then
			balloon.y = balloon.y - delta * 10
		else
			balloon.y = balloon.y + delta * 10
		end
		
		if balloon.x < -200 then
			table.remove(presents.balloons, index)
		end
	end
end

function update_player(delta)
	-- help
	if love.keyboard.isDown('h') then
		ui.help.show = true
	else
		ui.help.show = false
	end

	-- walk
	if love.keyboard.isDown('d') then
		if player.x < (love.graphics.getWidth() - player.img:getWidth()) then
			player.x = player.x + (player.speed * delta)
			player.direction = -1
		end
	elseif love.keyboard.isDown('a') then
		if player.x > player.width then 
			player.x = player.x - (player.speed * delta)
			player.direction = 1
		end
	end

	if love.keyboard.isDown('w') and player.possible_up then
		if player.y < (love.graphics.getWidth() - player.img:getWidth()) then
			player.y = player.y - (player.speed * delta)
		end
	elseif love.keyboard.isDown('s') and player.possible_down then
		if player.y > player.width then 
			player.y = player.y + (player.speed * delta)
		end
	end

 	-- jump
	if love.keyboard.isDown('space') then
		if player.y_velocity == 0 then
			player.y_velocity = player.jump_height
		end
	end
 
	if player.y_velocity ~= 0 then
		player.y = player.y + player.y_velocity * delta
		player.y_velocity = player.y_velocity - world.gravity * delta
	end
 
	if player.y > player.ground then
		player.y_velocity = 0
    	player.y = player.ground
	end

	-- letting go action
	if player.throw_wait >= 0 then
		player.throw_wait = player.throw_wait - player.axe.cooldown_rate * delta
	end

	if love.keyboard.isDown('k') and player.throw_wait < 0 then
		if player.energy.amount < player.energy.max then
			player.energy.amount = player.energy.amount + player.energy.rate_gain * delta
		else
			player.energy.amount = player.energy.max
		end
	else
		if player.energy.amount > 0 then
			if player.can_throw then
				throw_energy = player.energy.amount + 10
				throw = {
					x = player.x,
					y = player.y,
					r = player.axe.rotate_adjust * player.energy.amount,
					img = player.axe_img,
					speed = player.axe_default.speed
				}
				table.insert(player.throws, throw)
				player.can_throw = true
				player.throw_wait = player.axe.cooldown
			end
		end
		player.energy.amount = 0 -- reset
	end

	for index, throw in ipairs(player.throws) do
		throw.y = throw.y - delta * player.axe.velocity_y
		throw.r = throw.r + throw.r * delta
		
		if throw.y < -100 then
			table.remove(player.throws, index)
		end
	end
end
 
function love.draw()
	draw_player()
	draw_presents()
	draw_world()
	draw_ui()
end

function draw_world()
	love.graphics.setColor(ui.color.reset)
    love.graphics.draw(world.img_source, world.img_tile, world.x, world.y, 0)
end

function draw_presents()
	for _, balloon in ipairs(presents.balloons) do
		love.graphics.draw(balloon.img, balloon.x, balloon.y, balloon.r, balloon.scale)
	end
end

function draw_player()
	love.graphics.setColor(ui.color.reset)
	love.graphics.draw(player.img, player.x, player.y, 0, player.direction, player.img_scale, player.width/2, player.height)

	for _, throw in ipairs(player.throws) do
		love.graphics.draw(throw.img, throw.x, throw.y, throw.r, player.axe.scale)
	end
end

function draw_ui()
	love.graphics.setColor(ui.color.reset)
	love.graphics.draw(ui.logo.ac.img, ui.logo.x, ui.logo.y, 0)
	love.graphics.draw(ui.logo.r.img, ui.logo.x, ui.logo.y + 120, 0, ui.logo.r.scale, ui.logo.r.scale)

	-- controls help
	if ui.help.show then
		help_x = ui.help.start_x
		help_y = ui.help.start_y

		for index, message in ipairs(ui.help.messages) do
			love.graphics.print(message, help_x, help_y)
			help_y = help_y + ui.help.spacing
		end
	else
		love.graphics.print("hold h for help", ui.help.start_x, ui.help.start_y + 75)
	end

	-- avatar
	love.graphics.draw(player.avatar, ui.energy.x, ui.energy.y - 80)

	-- energy bar
	if player.energy.amount > 0 then
		love.graphics.setColor(ui.color.blue)
		love.graphics.rectangle('fill', ui.energy.x, ui.energy.y, (player.energy.amount / player.energy.max) * ui.energy.width, ui.energy.height)
	else
		love.graphics.setColor(ui.color.red)
		love.graphics.rectangle('fill', ui.energy.x, ui.energy.y, ui.energy.width, ui.energy.height)
	end
end

function love.quit()
	return false
end


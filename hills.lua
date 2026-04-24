function _init()
	rand_seed = 4
	init_game()
end

function init_game()
	srand(rand_seed)
	cls()
	pen = new_pen()
	ground = {}
	camera_x = 0

	generate_ground()
	dt = 1 / 30
	-- add grav to ball
	-- acceleration due to grav
	grav = 100
	-- debug
	dx = 0
	dy = 0
	m_perp = vec()
	ground_force = vec()

	player = new_player(64,30)
end

function _update()
	dt = 1 / 30
	-- camera controls
	-- if btn(4) then
	-- 	camera_x -= 1
	-- end
	-- if btn(5) then
	-- 	camera_x += 1
	-- end

	-- slow motion
	if btn(4) then
		dt = 1 / 120
	end
	if btnp(2) then
		rand_seed += 1
		init_game()
	end
	update_player(player)
	-- camera follows player
	-- convert player coords to screen coords
	px = player.x - camera_x
	margin = 40
	if px > 128-margin then 
		camera_x += 1
	end
	if px < margin then 
		camera_x -= 1
	end
end

function update_player(p)
	-- x movement
	accel = 90
	speed = 100
	if btn(1) then
		p.dx += accel * dt
	end
	if btn(0) then
		p.dx -= accel * dt
	end
	-- friction
	p.dx *= 0.87
	-- max speed
	p.dx = mid(-speed,p.dx,speed)
	p.x += p.dx * dt
	-- y movement
	player_grav = 30
	p.dy+=player_grav*dt
	-- ground collision
	touching_ground(p)
	p.y+=p.dy*dt
	-- move hitbox with player
	p.mid = vec(p.x+4.5,p.y+4.5)
	p.collider.x = p.mid.x
	p.collider.y = p.mid.y+2

	-- what is the slope at point of collision?
	slope_dx = 2 * p.collider.r
	slope_dy = -1 * (ground[flr(p.collider.x - p.collider.r)].y - ground[flr(p.collider.x + p.collider.r)].y)
	slope =slope_dy / slope_dx
	slope_vec = vec(slope_dx, slope_dy)
	slope_norm = normalize_vec(slope_vec)
	-- what is the angle of the slope?
	slope_angle = atan2(slope_dx,slope_dy)
end

function update_ball(b)
	-- sum forces on ball
	ax = 0
	ay = 0
	-- touching ground?
	if b.pos.y + (b.vel.y * dt) >= ground[flr(b.pos.x)] then
		-- the center of the ball is touching the ground
		--dt = 0
		momentum = vec(b.m * b.vel.x / dt, b.m * b.vel.y / dt)
		-- momentum_y = b.m * b.vel.y
		-- force_y = -2 * momentum_y / dt
		-- add(b.forces, vec(0, force_y))
		-- what is the slope at point of collision?
		dx = 2 * b.r
		dy = -1 * (ground[flr(b.pos.x - b.r)] - ground[flr(b.pos.x + b.r)])
		m = dy / dx
		m_vec = vec(dx, dy)
		m_norm = normalize_vec(m_vec)
		-- vector perpendicular to ground
		m_perp = vec(m_norm.y, -m_norm.x)
		momentum_magnitude = 50 * get_vec_length(momentum)
		ground_force = vec(momentum_magnitude * m_perp.x, momentum_magnitude * m_perp.y)
		add(b.forces, ground_force)
	end
	for f in all(b.forces) do
		ax += f.x / b.m
		ay += f.y / b.m
	end
	-- update ball position
	b.vel.x += ax * dt
	b.vel.y += ay * dt
	b.pos.x += b.vel.x * dt
	b.pos.y += b.vel.y * dt
	-- clear forces for next frame
	b.forces = {}
end

function _draw()
	cls()
	camera(camera_x, 0)
	draw_ground(camera_x)
	draw_player(player)
	-- draw the slope
	camera()
end

function draw_ground(start_x)
	for x = max(0, start_x), start_x + 128 do
		if ground[x] == nil then
			break
		end
		-- dirt length
		line(x, ground[x].y, x, 128, 4)
		-- top part of ground
		line(x, ground[x].y, x, ground[x].y + ground[x].h, 9)
		-- fade out
		fillp(░)
		rectfill(x, ground[x].y + 20, x, ground[x].y + 39, 0)
		fillp(▒)
		rectfill(x, ground[x].y + 40, x, ground[x].y + 100, 0)
		fillp()
	end
end

function draw_ball(b)
	circ(b.pos.x, b.pos.y, b.r, 8)
end

function draw_player(p)
	-- spr(p.k,p.x,p.y)
	rot_spr(p.k,p.x,p.y,slope_angle)
	debug = false
	if debug then
		-- draw debug lines
		circ(p.collider.x,p.collider.y,p.collider.r,8)
		line(p.collider.x,p.collider.y, p.collider.x+slope_norm.x*6,p.collider.y+slope_norm.y*6,12)
		print(slope_angle,10,10,12)
	end
end
-- constructors
function new_player(_x,_y)
	p = {
		x=_x,
		y=_y,
		dx=0,
		dy=0,
		angle=0,
		k=1 -- sprite

	}
	p.collider = new_ground_collider()
	return p
end

function new_pen()
	p = {
		x = 0,
		dx = 1,
		y = 64,
		r = 3,
		slope = 0.1,
		width = 5,
	}
	return p
end

function new_ground_collider()
	b = {
		x=0,
		y=0,
		r = 3,
	}
	return b
end

function new_ground(_y, _h)
	g = {
		y = _y,
		h = _h,
	}
	return g
end

-- util
function rot_spr(k, x, y, a)
	-- draw the given sprite rotated by a
	-- note: only works for sprites on first row of sheet
	spritesheet_x = k*8
	spritesheet_y = 0
	-- center of sprite
	c = vec(x+4.5,y+4.5)
	for i=0,8 do
		for j=0,8 do
			col = sget(spritesheet_x+i,spritesheet_y+j)
			if col != 0 then
				p = vec(x+i,y+j)
				p_rot = rot(p,a,c)
				pset(p_rot.x,p_rot.y,col)
			end
			-- get world x, y
			-- rotate around point
			-- get color from sprite sheet
		end
	end
end

function rot(p,a,c)
	-- return the given point rotated around c by a
	p_rot = p
	p_rot.x = (p.x-c.x)*cos(a)-(p.y-c.y)*sin(a) + c.x
	p_rot.y = (p.y-c.y)*cos(a)+(p.x-c.x)*sin(a) + c.y
	return p_rot
end

function touching_ground(p)
	-- given a player, tell if it will intersect the ground in the next frame
	-- if so, reduce the change in position so the collision won't happen
	ground_height = ground[flr(p.collider.x)].y
	distance_past_ground = p.collider.y + p.dy*dt - ground_height
	if distance_past_ground > 0 then
		p.dy-=distance_past_ground/dt
		return true
	end
	return false
end

function vec(_x, _y)
	-- default to 0
	xval = _x or 0
	yval = _y or 0
	v = { x = xval, y = yval }
	return v
end

function get_vec_length(v)
	vec_length = sqrt(v.x * v.x + v.y * v.y)
	return vec_length
end

function normalize_vec(v)
	vec_length = get_vec_length(v)
	return vec(v.x / vec_length, v.y / vec_length)
end

function generate_ground()
	for i = 0, 1024 do
		dirt_len = pen.width
		ground[pen.x] = new_ground(pen.y, dirt_len)
		pen.x += pen.dx
		pen.y += pen.slope * pen.dx
		pen.width += rnd({ -0.4, 0.4 })
		-- width between 0 and 7
		pen.width = mid(3, pen.width, 7)
		pen.slope += -0.2 + rnd(0.4)
		slope_change=0.3
		pen.slope = mid(-slope_change, pen.slope, slope_change)
		if i < 100 then
			-- start out flat
			pen.slope=0
		end
		-- if btn(2) then
		-- 	pen.slope -= 0.1
		-- end
		-- if btn(3) then
		-- 	pen.slope += 0.1
		-- end
	end
end

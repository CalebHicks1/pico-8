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
	-- debug lines
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

-- constructors
function new_pen()
	p = {
		x = 0,
		dx = 1,
		y = 64,
		slope = 0.1,
		width = 5,
	}
	return p
end

function new_ball()
	b = {
		pos = vec(64, 10),
		vel = vec(),
		m = 2,
		r = 5,
		forces = {},
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
	for i = 0, 128 do
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
		-- if btn(2) then
		-- 	pen.slope -= 0.1
		-- end
		-- if btn(3) then
		-- 	pen.slope += 0.1
		-- end
	end
end

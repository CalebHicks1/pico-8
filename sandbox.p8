pico-8 cartridge // http://www.pico-8.com
version 43
__lua__
-- sandbox
gravx = 0
gravy = 40
dt = 1/40
function new_pixel(_x, _y)
	p = {
		x=_x,
		y=_y,
		xvel=-20+rnd(40), -- random x vel
		yvel=-30+rnd(30), -- toss up w/ random speed
		c=2,
		draw=function(self)
			pset(self.x,self.y,self.c)
		end,
		update=function(self)
			-- ypos
			self.yvel = self.yvel + gravy * dt
			self.y=self.y+(self.yvel*dt+0.5*gravy*dt*dt)
			-- xpos
			self.xvel = self.xvel + gravx * dt
			-- friction
			self.xvel = self.xvel * 0.95
			self.x=self.x+(self.xvel*dt+0.5*gravx*dt*dt)			
		end
	}
	return p
end

function _init()
	-- enable mouse input
	poke(0x5f2d, 1)
	-- empty table of pixels
	falling_pixels = {}
	-- 2d grid of tables
	grid = {}
	-- add rows to grid
	for x=1, 128 do
		grid[x] = {}
	end -- end for
	grid[5][1] = new_pixel(1,1)
end

function _update60()
	-- get mouse location
	mouse_x = stat(32)
	mouse_y = stat(33)
	-- is mouse clicked?
	mouse_down = false
	if (stat(34) == 1) mouse_down = true
	-- if mouse down, add pixel
	if (mouse_down) then
		add(falling_pixels,new_pixel(mouse_x,mouse_y))
	end
	
	-- update all pixels
	for p in all(falling_pixels) do
		p:update()
		
		-- delete pixels that fall off screen
		if (flr(p.y)) > 100 then
			-- add the pixel to the grid
			
			grid[flr(p.x)][flr(p.y)] = p
			del(falling_pixels,p)
		end
	end
	
end

function _draw()
	cls(1)
	for p in all(falling_pixels) do
		p:draw()
	end -- end for
	-- draw pixels in grid
	for x = 1, 128 do
		for y = 1, 128 do
			if (grid[x][y] != nil) then
				pset(x-1,y-1,9) --screen index starts at 0
			end --end if 	
		end --end for
	end --end for
	-- draw mouse
	spr(1,mouse_x,mouse_y)
end -- end _draw()
__gfx__
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000003000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0070070003b300000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0007700003bb30000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0007700003bbb3000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0070070003b300000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000003b30000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000

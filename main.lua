require("simpleLamp")

	--here's our lamp.
	--it's placed at x=200, y=250, 45% brightness for the lamp, and uses the windowsize for the overlay draw
	lamp=createLamp(200, 150, 45, love.graphics.getWidth(), love.graphics.getHeight()) 

function love.load()
	
	--just a table holding our test image
	--and the x/y for moving.
	img={	x=160,
			y=120,
			image = love.graphics.newImage("graphics/greenarrow.png"),
			luminosity=0
		}
	
	--we use the map table found at the bottom of this file to create
	--the map we're going to use.
	map:load_tiles()
	map:fill_map()
	--these will be our object images.
	object_images={}
	object_walking={}
	table.insert(object_images, love.graphics.newImage("graphics/tree.png"))
	table.insert(object_images, love.graphics.newImage("graphics/dtree.png"))
	table.insert(object_images, love.graphics.newImage("graphics/tomb.png"))
	--walkable images--
	table.insert(object_walking, love.graphics.newImage("graphics/walk1.png"))
	table.insert(object_walking, love.graphics.newImage("graphics/walk2.png"))
	table.insert(object_walking, love.graphics.newImage("graphics/walk3.png"))
	
	map:load_objects()
end

function love.update(dt)
	
	--we'll move our img.
	if(love.keyboard.isDown("up")) then img.y=img.y-1 end 
	if(love.keyboard.isDown("down")) then img.y=img.y+1 end
	if(love.keyboard.isDown("left")) then img.x=img.x-1 end
	if(love.keyboard.isDown("right")) then img.x=img.x+1 end
	
	--we'll move our lamp
	if(love.keyboard.isDown("w")) then lamp.y=lamp.y-1 end 
	if(love.keyboard.isDown("s")) then lamp.y=lamp.y+1 end
	if(love.keyboard.isDown("a")) then lamp.x=lamp.x-1 end
	if(love.keyboard.isDown("d")) then lamp.x=lamp.x+1 end
	
	--change brightness
	if(love.keyboard.isDown("1")) then lamp:brighter() end
	if(love.keyboard.isDown("2")) then lamp:dimmer() end

	
	--then calculate it's luminosity
	img.luminosity=lamp:lumonisity(img.x, img.y)
	--this is done as a percentage.
	
	--update the map.
	map:update()
end

function love.draw()	
	--scaling because the image I'm using is small--
	love.graphics.scale(3, 3)
	
	
	--draw the map--
	map:draw()
	----------------------------------------------------------------------	
	--since luminosity is a percantage, we need to adjust that so it's a percentage of 1.
	local lit=((img.luminosity/100))
	--this is just an example using set color. You can use anything
	--a shader, a mesh, whatever. Just take the percentage and do what
	--you need to it.
	love.graphics.setColor(lit, lit, lit, 1)
	love.graphics.draw(img.image, img.x, img.y)
	----------------------------------------------------------------------
	
	--this is to just drawing a circle at a level of intensity
	--to match the brightness.
	local lamplit=((lamp:getBrightness()/100))	
	love.graphics.setColor(1, 1, 1, lamplit)
	love.graphics.circle("fill", lamp.x, lamp.y, 10, 10)	
	love.graphics.setColor(1, 1, 1, 1)	
	
	
	
	love.graphics.print("The arrow is " .. img.luminosity .. "% lit", 0, 10)
	love.graphics.print("The lamp is " .. lamp:getBrightness() .. "% bright", 0, 20)
	love.graphics.print("Arrow keys to move green arrow", 0, 30)
	love.graphics.print("Press 1 to brighten lamp, 2 to dim", 0, 40)
	love.graphics.print("WASD to move the LAMP", 0, 50)
	
end


--------------------------------------------------------------------------------------------------------
--[[
THIS IS JUST FOR DRAWING SOME RANDOM TILES AND PLACING SOME RANDOM OBJECTS
--]]
--------------------------------------------------------------------------------------------------------
map={}
function map:load_tiles()
	self.tiles=love.graphics.newImage("graphics/ground.png")
	self.tileset={}
	--create the quads--
	for spx=-1, self.tiles:getWidth(), 8 do
				table.insert(self.tileset, love.graphics.newQuad(spx, 0, 8, 8, self.tiles:getWidth(), self.tiles:getHeight()))
	end
end

function map:load_objects()
	self.objects={}
	for i=1, math.random(100) do
		table.insert(self.objects, {x=math.random(400), y=math.random(300), image=math.random(3), lit=1})
	end
	for i=1, math.random(10) do
		table.insert(self.objects, {x=math.random(400), y=math.random(300), image=math.random(3), lit=1, walkable=true})
	end
end

function map:fill_map()
	self.map={}
	--lay down grass.
	for x=1, 60 do
		self.map[x]={}
		for y=1, 60 do
			self.map[x][y]={
							tile=1, 
							lit=1
							}
		end
	end
end

function map:update()
	--this makes the stuff move about, so you can see that the lighting is dynamic.
	for i,v in ipairs(self.objects) do
			if(v.walkable) then 
					self.objects[i].x=self.objects[i].x+math.random(-1, 1)
					self.objects[i].y=self.objects[i].y+math.random(-1, 1)
			end
	end	
end

function map:draw()
	for x=1, 60 do
		for y=1, 60 do
			local tile=self.map[x][y] --shortcut to save on typing.
			love.graphics.draw(self.tiles, self.tileset[tile.tile], (x*8)-16, (y*8)-16)
			love.graphics.setColor(1, 1, 1, 1)			
		end
	end

	--this draws an overlay a shadow cast overlay, using the vectory tile raycasting.
	lamp:draw()


	for i,v in ipairs(self.objects) do
			--luminosity is a # 1-100, for %. We turn this into a % of 1, to use for setColor
			local lit=(lamp:lumonisity(v.x, v.y)/100)
			love.graphics.setColor(lit, lit, lit, 1)
			if(v.walkable) then
				love.graphics.draw(object_walking[v.image], v.x, v.y)
			else
				love.graphics.draw(object_images[v.image], v.x, v.y)			
			end
	end
end

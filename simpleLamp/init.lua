--[[
Copyright (c) 2023-2024 Paul Jessup

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

Except as contained in this notice, the name(s) of the above copyright holders
shall not be used in advertising or otherwise to promote the sale, use or
other dealings in this Software without prior written authorization.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.
]]--

local dir=...
vector=require(dir .. ".vector-light")

function createLamp(x, y, lumens)

	return
	{
		x=x,
		y=y,
		lumens=(100-lumens),
		lumonisity=function(self, x, y)
			if(self.lumens==1) then return 100 end
			local dist=((vector.dist(x, y, self.x, self.y))-(180-self.lumens))	
			lumens=math.ceil(((dist/((self.lumens/100)*765))*100)*-1)
			if(lumens<1) then lumens=0 end
			if(lumens>99) then lumens=100 end
			return lumens
		end,
		setBrightness=function(self, amount)
			self.lumens=self.lumens+amount
			if(self.lumens<=1) then self.lumens=1 end	
			if(self.lumens>100) then self.lumens=100 end
		end,
		brighter=function(self)
			self.lumens=self.lumens-1	
			if(self.lumens<=1) then self.lumens=1 end	
		end,
		dimmer=function(self)
			self.lumens=self.lumens+1
			if(self.lumens>100) then self.lumens=100 end
		end,
		getBrightness=function(self)
			return 100-self.lumens
		end
	}
	
	end

return {
		lamps={},
		lookups={},
		init=function(self, worldLit, shadowColor, width, height, scale)
			if shadowColor==nil then shadowColor={0, 0, 0} end 
			if worldLit==nil then worldLit=1.0 end
			if scale==nil then scale=1 end
			self.scale=scale
			self.lit=worldLit
			self.shadowColor=shadowColor
			self.screen={width=width/scale, height=height/scale}
			self.shadowCanvas=love.graphics.newCanvas(width/scale, height/scale)
			--clear out any pre-existing lamps.
			for i=#self.lamps, -1 do
				self.lamps[i]=nil
			end
			self.lamps={}
		end,
		createLamp=function(self, x, y, lumens)
			local id=#self.lamps+1
			self.lamps[id]=createLamp(x, y, lumens)
			return id
		end,
		moveLamp=function(self, lamp, x, y, relative) --relative is whether or not it moves relative to the last pos			
			if lamp~=nil and self.lamps[lamp]~=nil then
				if relative then
					x=self.lamps[lamp].x+x
					y=self.lamps[lamp].y+y
				end
					self.lamps[lamp].x=x
					self.lamps[lamp].y=y
			else
				error("Lamp #" .. lamp .. " does not exist")
			end			
		end,
		getLocation=function(self, lamp)
			if lamp~=nil and self.lamps[lamp]~=nil then
				return self.lamps[lamp].x, self.lamps[lamp].y
			else
				error("Lamp #" .. lamp .. " does not exist")
			end
		end,
		setBrightness=function(self, lamp, amount)
			--if a lamp isn't specified, apply to all.
			if lamp~=nil and self.lamps[lamp]~=nil then
				self.lamps[lamp]:setBrightness(amount)
			else
				for i, v in ipairs(self.lamps) do
					self.lamps[i]:setBrightness(amount)
				end
			end
		end,
		getBrightness=function(self, lamp)
			if lamp~=nil and self.lamps[lamp]~=nil then
				return self.lamps[lamp]:getBrightness()
			else
				error("Lamp #" .. lamp .. " does not exist")
			end
		end,
		brighter=function(self, lamp)
			if lamp~=nil and self.lamps[lamp]~=nil then
				self.lamps[lamp]:brighter()
			else
				for i, v in ipairs(self.lamps) do
					self.lamps[i]:brighter()
				end
			end
		end,
		dimmer=function(self, lamp)
			if lamp~=nil and self.lamps[lamp]~=nil then
				self.lamps[lamp]:dimmer()
			else
				for i, v in ipairs(self.lamps) do
					self.lamps[i]:dimmer()
				end
			end
		end,
		setGlobalLighting=function(self, worldLit)
			self.lit=worldLit
		end,
		setShadowColor=function(self, shadowColor)
			self.shadowColor=shadowColor
		end,
		update=function(self, dt)
			--[[
			--ability for flickering lights will be added, and needed to be updated here.
			--]]
			love.graphics.setCanvas(self.shadowCanvas)
			love.graphics.clear()
			love.graphics.push()
			love.graphics.scale(1/3, 1/3)
			for x=0, self.screen.width/4 do
				for y=0, self.screen.height/4 do
					love.graphics.setColor(0, 0, 0, 1)
					local lit=self:lumonisity(x*4, y*4)
					love.graphics.setColor(self.shadowColor[1], self.shadowColor[2], self.shadowColor[3], 1-(lit))
					love.graphics.rectangle("fill",  (x*4), (y*4), 4, 4)
				end
			end
			love.graphics.pop()
			love.graphics.setCanvas()
		end,
		draw=function(self, lamp)
			love.graphics.draw(self.shadowCanvas)
		end,
		--get how well lit something at x/y should be.
		--compare luminosity of all lamps, highest is returned.
		lumonisity=function(self, x, y)
			local lumen=0
			for i,v in ipairs(self.lamps) do
				local l=0
				if v:getBrightness()>0 then l=v:lumonisity(x, y) end
				if l>lumen then lumen=l end			
			end
			lumen=lumen+(self.lit*100)
			if lumen>100 then lumen=100 end
			if lumen<0 then lumen=0 end
			return lumen/100
		end,
}





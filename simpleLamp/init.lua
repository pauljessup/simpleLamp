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

function createLamp(x, y, lumens, sx, sy)

return
{
	x=x,
	y=y,
	lumens=(100-lumens),
    screen={x=sx, y=sy},
	lumonisity=function(self, x, y)
		if(self.lumens==1) then return 100 end
		local dist=((vector.dist(x, y, self.x, self.y))-(180-self.lumens))	
		lumens=math.ceil(((dist/((self.lumens/100)*765))*100)*-1)
		if(lumens<1) then lumens=0 end
		if(lumens>99) then lumens=100 end
		return lumens
	end,
    --add the ability to set a default lighting level, for daylight/etc.
    draw=function(self)
		for x=0, self.screen.x/4 do
            for y=0, self.screen.y/4 do
				love.graphics.setColor(0, 0, 0, 1)
                local lit=self:lumonisity(x*4, y*4)
                love.graphics.setColor(0, 0, 0, 1-(lit/100))
                love.graphics.rectangle("fill",  (x*4), (y*4), 4, 4)
            end
        end
		love.graphics.setColor(1, 1, 1, 1)
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
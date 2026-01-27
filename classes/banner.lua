local banner = {}

function banner:load()
    self.text = ""
    self.plr = activePlayers[1]

    self.img = love.graphics.newImage("assets/banner.png")

    self.state = "inactive"

    self.time = 0
    self.duration = 0.5 -- Increase duration for smoother animation


    self.pos = {
        x = - (self.img:getWidth() * scale),
        y = wH/2 - (self.img:getHeight() * scale)/2
        
    }
end

function banner:update(dt)
    
    if self.state == "appearing" then
        self.time = self.time + dt
        local t = math.min(self.time / self.duration, 1) -- Normalize time over duration
        
        -- Calculate position based on easing
        local startX = -(self.img:getWidth() * scale)
        local endX = wW/2 - (self.img:getWidth() * scale)/2 -- Center it horizontally
        self.pos.x = startX + (endX - startX) * easeOutBack(t)
        
        if t >= 1 then
            self.state = "visible"
            self.pos.x = endX -- Lock to final position
        end
    end

end

function banner:setActive()
    self.state = "appearing"    
end


function banner:draw()
    
    if self.state ~= "inactive" then
        
        love.graphics.push()
        love.graphics.scale(scale, scale)
        love.graphics.translate(self.pos.x, self.pos.y)

        love.graphics.draw(self.img)

        love.graphics.pop()

    end

end


return banner
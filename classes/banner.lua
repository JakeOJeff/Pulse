local banner = {}

function banner:load()
    self.text = ""
    self.plr = activePlayers[1]

    self.img = love.graphics.newImage("assets/banner.png")

    self.state = "inactive"

    self.time = 0
    self.duration = 0.5 -- Increase duration for smoother animation


    local s = scale / 2
    local logicalH = wH / s

    self.pos = {
        x = -self.img:getWidth(), -- start off-screen (left)
        y = logicalH / 2 - self.img:getHeight() / 2
    }

end

function banner:update(dt)

    -- APPEARING
    if self.state == "appearing" then
        self.time = self.time + dt
        local t = math.min(self.time / self.duration, 1)

        local logicalScreenW = wW / (scale / 2)

        local startX = -self.img:getWidth()
        local endX   = logicalScreenW / 2 - self.img:getWidth() / 2

        self.pos.x = startX + (endX - startX) * easeOutBack(t)

        if t >= 1 then
            self.state = "visible"
            self.time = 0
            self.pos.x = endX
        end
    end

    -- HOLD
    if self.state == "visible" then
        self.time = self.time + dt

        if self.time > 0.2 then
            self.state = "disappearing"
            self.time = 0
        end
    end

    -- DISAPPEARING
    if self.state == "disappearing" then
        self.time = self.time + dt
        local t = math.min(self.time / self.duration, 1)

        local logicalScreenW = wW / (scale / 2)

        local startX = logicalScreenW / 2 - self.img:getWidth() / 2
        local endX   = logicalScreenW + self.img:getWidth()

        self.pos.x = startX + (endX - startX) * easeInBack(t)

        if t >= 1 then
            self.state = "inactive"
        end
    end
end



function banner:setActive()
    self.state = "appearing"    
end


function banner:draw()
    
    if self.state ~= "inactive" then
        
        love.graphics.push()
        love.graphics.scale(scale/2, scale/2)
        love.graphics.translate(self.pos.x, self.pos.y)

        love.graphics.draw(self.img)

        love.graphics.pop()

        love.graphics.setFont(font)

        love.graphics.print(recentPowerup, self.pos.x, self.pos.y)

    end

end


return banner
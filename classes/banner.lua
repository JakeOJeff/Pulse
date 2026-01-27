local banner = {}

function banner:load()
    self.text = ""
    self.plr = activePlayers[1]

    self.img = love.graphics.newImage("assets/banner.png")

    self.state = "inactive"

    self.time = 0
    self.duration = 0.5 -- Increase duration for smoother animation

local logicalH = wH / scale



    self.pos = {
        x = -self.img:getWidth(), -- start off-screen (left)
        -- y = logicalH / 2 - self.img:getHeight() / 2

        y = ((grid.size) + 20*scale + grid.height) / scale

    }

end

function banner:update(dt)

    -- APPEARING
    if self.state == "appearing" then
        self.time = self.time + dt
        local t = math.min(self.time / self.duration, 1)

        local logicalScreenW = wW / (scale)

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

        if self.time > 0.5 then
            self.state = "disappearing"
            self.time = 0
        end
    end

    -- DISAPPEARING
    if self.state == "disappearing" then
        self.time = self.time + dt
        local t = math.min(self.time / self.duration, 1)

        local logicalScreenW = wW / (scale)

        local startX = logicalScreenW / 2 - self.img:getWidth() / 2
        local endX   = logicalScreenW + self.img:getWidth()

        self.pos.x = startX + (endX - startX) * easeInBack(t)

        if t >= 1 then
            self.state = "inactive"
            self.pos.x = -self.img:getWidth()
        end
    end
end



function banner:setActive()
    self.state = "appearing"
    self.time = 0
    self.pos.x = -self.img:getWidth()
end



function banner:draw()
    if self.state == "inactive" then return end

    love.graphics.push()
    love.graphics.scale(scale, scale)
    love.graphics.translate(self.pos.x, self.pos.y)

    local bw = self.img:getWidth()

    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.draw(self.img)

    love.graphics.pop()

    love.graphics.push()

    -- Convert coords back to screen space
    local textX = (self.pos.x) * scale
    local textY = (self.pos.y) * scale

    -- Powerup text
    love.graphics.setFont(Hfont)
    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.printf(
        recentPowerup,
        textX,
        textY + 100 * scale,
        bw * scale,
        "center"
    )

    -- Player name
    love.graphics.setFont(font)
    love.graphics.setColor(recentPowerupPlayer.color)
    love.graphics.printf(
        recentPowerupPlayer.name,
        textX,
        textY + (100 + Hfont:getHeight() + 40) * scale,
        bw * scale,
        "center"
    )

    love.graphics.pop() -- unscaled text

    love.graphics.setColor(1, 1, 1, 1)
end



return banner
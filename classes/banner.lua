local banner = {}

function banner:load()
    self.text = ""
    self.plr = activePlayers[1]

    self.img = love.graphics.newImage("assets/banner.png")

    self.state = "inactive"


    self.pos = {
        x = - (self.img:getWidth() * scale),
        y = 0
        
    }
end

function banner:update(dt)
    
    if self.state == "appearing" then
        if self.pos.x < 0 then
            self.pos.x = self.pos.x + 100 * dt
        end
    end

end

function banner:setActive()
    self.state = "appearing"    
end


function banner:draw()
    
    if not self.state == "inactive" then
        
        love.graphics.push()
        love.graphics.scale(scale, scale)
        love.graphics.translate(self.pos.x, self.pos.y)

        love.graphics.draw(self.img)

        love.graphics.pop()

    end

end


return banner
local banner = {}

function banner:load()
    self.text = ""
    self.plr = activePlayers[1]

    self.img = love.graphics.newImage("assets/banner.png")

    self.active = false


    self.pos = {
        x = 0,
        
    }
end

function banner:update(dt)
    


end

function banner:setActive()
    self.active = not self.active    
end


function banner:draw()
    
    if self.active then
        
    end

end
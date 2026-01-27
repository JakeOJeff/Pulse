local button = {}
button.__index = button
buttons = {}

function button:new(x, y, text, func, img)
    
    local self = setmetatable({}, button)

    self.x = x
    self.y = y
    self.text = text
    self.func = func

    self.width = font:getWidth(self.text) + 20 * scale
    self.height = font:getHeight() + 20 * scale

    if img then
        self.img = img
        self.width = self.img:getWidth() * scale
        self.height = self.img:getHeight() * scale
    end
    self.hovering = false

    table.insert(buttons, self) 
    return self

end

function button:update(dt)
    local mx, my = love.mouse.getPosition()

    if mx > self.x and  mx < self.x + self.width and my > self.y and my < self.y + self.height then
        self.hovering = true
    end
end

function button:draw()
    if self.img then
        love.graphics.push()
        love.graphics.scale(scale, scale)
        love.graphics.translate(self.x, self.y)

        love.graphics.draw(self.imgs)
        love.graphics.pop()
    end
end

return button
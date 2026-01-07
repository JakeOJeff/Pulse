wW = love.graphics.getWidth()
wH = love.graphics.getHeight()

grid = require("grid")

require("player")

function love.load()
    grid:load()

    font = love.graphics.newFont("assets/fonts/toxigenesis.otf", 24)
end

function love.update(dt)
    grid:update(dt)
end

function love.mousepressed(x, y, button)
    grid:mousepressed(x, y, button)


end

function love.draw()
    love.graphics.setFont(font)
    grid:draw()
end
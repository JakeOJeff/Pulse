wW = love.graphics.getWidth()
wH = love.graphics.getHeight()

grid = require("grid")

require("player")

function love.load()
    grid:load()
end

function love.update(dt)
    grid:update(dt)
end

function love.mousepressed(x, y, button)
    grid:mousepressed(x, y, button)


end

function love.draw()
    grid:draw()
end
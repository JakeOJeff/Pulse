wW = love.graphics.getWidth()
wH = love.graphics.getHeight()

grid = require("grid")

require("player")

function love.load()
    grid:load()
end


function love.draw()
    grid:draw()
end
wW = love.graphics.getWidth()
wH = love.graphics.getHeight()

grid = require("grid")

require("player")
require("powerup")

function love.load()
    grid:load()
    loadPlayers()
    font = love.graphics.newFont("assets/fonts/toxigenesis.otf", 20)
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
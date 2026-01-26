wW = love.graphics.getWidth()
wH = love.graphics.getHeight()

defW = 1080
defH = 1920

scale = wW/defW

settings = require("settings")
grid = require("grid")

require("player")
require("powerup")

function love.load()
    grid:load()
    loadPlayers()
    font = love.graphics.newFont("assets/fonts/toxigenesis.otf", 20)
    winner = nil
    gameState = nil
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

function love.resize(w, h)
    wW = w
    wH = h

    scale = defW/wW

    grid:load()
end
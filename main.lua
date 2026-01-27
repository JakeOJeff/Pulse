wW = love.graphics.getWidth()
wH = love.graphics.getHeight()

defW = 1080
defH = 1920

scale = wW/defW

settings = require("settings")
grid = require("grid")
banner = require("classes.banner")
button = require("classes.button")
require("player")
require("powerup")

defW = 1080
defH = 1920

scale = wW/defW

function love.load()
    grid:load()
    banner:load()
    loadPlayers()
    font = love.graphics.newFont("assets/fonts/toxigenesis.otf", 20)
    winner = nil
    gameState = nil
end

function love.update(dt)
    grid:update(dt)
    banner:update(dt)
    if love.mouse.isDown(1) then
        banner:setActive()
    end
end

function love.mousepressed(x, y, button)
    grid:mousepressed(x, y, button)
end

function love.draw()
    love.graphics.setFont(font)
    grid:draw()
    banner:draw()
end

function love.resize(w, h)

    
end
 
function lerp(a,b,t)
    return a + (b-a)*t
end

function easeOutBack(t)
    local c1 = 1.70158
    local c3 = c1 + 1
    return 1 + c3*(t-1)^3 + c1*(t-1)^2
end

function easeInBack(t)
    local c1 = 1.70158
    local c3 = c1 + 1
    return c3*(t)^3 - c1*(t)^2
end

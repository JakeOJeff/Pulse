wW = love.graphics.getWidth()
wH = love.graphics.getHeight()

defW = 1080
defH = 1920

scale = wW/defW

settings = require("settings")
grid = require("grid")
button = require("classes.button")
require("player")
require("powerup")

defW = 1080
defH = 1920

scale = wW/defW

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

    
end
 
--[[

Past Two months have unboundly been the most wierdest but craziest month by far

I have seen lotS of things and learned a lot more and i want to share all of it right now

Lets date back to 2022. 

I was fairly unpopular in life, not having that many friends, but atleast i thrived. Everyday I remember, I would come to class thinking
if today would be the day that would be good for me, but unforunately everytime, the events just resulted in issues. I just wanted 
wanted to be love at that time, but you know how life is.

It was 10th standard, the grade where we had our boards, things were already set up for failure. I was scoring low marks in every subject
including english which i had considered my speciality, but that too resulted in utter failure unfortunately. 
I had a teacher called Rajitha Maam, who was our principal and she taught us english. She actually did teach good english surprisingly and i scored well on my boards.

I scored 88 percentage on my boards ( YAY ). And it was during this tenth, there was a karate competition. My friends vinayak and achyyuth was participating in it.
On the way there, i went by bus to the school. I wanted to support them for they had atleast been a little bit nice to me. While exiting the bus, A bar in the bus struck 
and pierced through my thigh and kneecap. It didnt hurt unforunately but I felt dizzy. I limped my way to the school and tried to find a nurse. While I was standing there
bleeding, i saw her.  My one, the girl that captured me.


]]

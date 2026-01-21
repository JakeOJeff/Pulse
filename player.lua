currentPlayer = {}
players = {
    {
        name = "Crimson",
        color = {0.66, 0.39,0.46}, -- deep red
        score = 0,
        eliminated = false
    },
    {
        name = "Emerald",
        color = {0.40, 0.57, 0.60}, -- rich green
        score = 0,
        eliminated = false
    },
    {
        name = "Sapphire",
        color = {0.34, 0.46, 0.67}, -- vivid blue
        score = 0,
        eliminated = false
    },

    -- New players
    -- {
    --     name = "Amber",
    --     color = {0.95, 0.7, 0.25}, -- warm orange/yellow
    --     score = 0,
    --     eliminated = false
    -- },
    -- {
    --     name = "Violet",
    --     color = {0.65, 0.35, 0.85}, -- purple
    --     score = 0,
    --     eliminated = false
    -- },
    -- {
    --     name = "Cyan",
    --     color = {0.25, 0.85, 0.85}, -- bright cyan
    --     score = 0,
    --     eliminated = false
    -- },
    -- {
    --     name = "Onyx",
    --     color = {0.2, 0.2, 0.2}, -- dark gray / near black
    --     score = 0,
    --     eliminated = false
    -- }
}
activePlayers = players
playerIndex = 1
totalPlayers = #activePlayers

currentPlayer = activePlayers[playerIndex]

function loadPlayers()
    powerupRoundsLeft = love.math.random(1, 6)
end
function updatePlayers()

end
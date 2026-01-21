currentPlayer = {}
players = {
    {
        name = "Crimson",
        color = {0.76, 0.49,0.56}, -- deep red
        score = 0,
        eliminated = false
    },
    {
        name = "Emerald",
        color = {0.50, 0.67, 0.70}, -- rich green
        score = 0,
        eliminated = false
    },
    {
        name = "Sapphire",
        color = {0.44, 0.56, 0.77}, -- vivid blue
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
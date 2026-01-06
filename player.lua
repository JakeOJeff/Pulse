currentPlayer = {}
players = {
    {
        name = "Red",
        color = {1, 0, 0},
        score = 0,
        eliminated = false
    },
    -- {
    --     name = "Green",
    --     color = {0, 1, 0},
    --     score = 0,
    --     eliminated = false
    -- },
    -- {
    --     name = "Blue",
    --     color = {0, 0, 1},
    --     score = 0,
    --     eliminated = false
    -- }
}
activePlayers = players
playerIndex = 1
currentPlayer = activePlayers[playerIndex]
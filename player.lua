currentPlayer = {}
players = {
    {
        name = "Crimson",
        color = {0.85, 0.2, 0.25}, -- deep red
        score = 0,
        eliminated = false
    },
    {
        name = "Emerald",
        color = {0.2, 0.75, 0.4}, -- rich green
        score = 0,
        eliminated = false
    },
    {
        name = "Sapphire",
        color = {0.25, 0.45, 0.85}, -- vivid blue
        score = 0,
        eliminated = false
    }
}
activePlayers = players
playerIndex = 1
currentPlayer = activePlayers[playerIndex]
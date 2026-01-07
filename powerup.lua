--[[

    Structure
    player = {
        name = "Sapphire",
        color = {0.25, 0.45, 0.85}, -- vivid blue
        score = 0,
        eliminated = false
    }

    cell = {
                x = self.size + (i - 1) * self.size,
                y = self.size + (j - 1) * self.size,
                name = "",
                color = { 1, 1, 1 },
                pulses = 0,
                offset = math.random(0, 1),
                circles = {},
                coordinates = {},

                exploding = false,
            }
]]

powerupRoundsLeft = 0
events = {
    {
        name = "Triple Increment", -- Increases all pulses of the player to 3
        func = function(player)
            for i = 1, grid.wC do
                for j = 1, grid.hC do
                    local cell = grid.cells[i][j]
                    if cell.name == player.name then
                        cell.pulses = 3
                    end
                end
            end
        end
    }
}


events = {
    {
        name = "Triple Increment", -- Increases all pulses of the player to 3
        func = function (player)
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
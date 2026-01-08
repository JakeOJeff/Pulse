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
recentPowerup = ""
events = {
    {
        name = "Triple Increment", -- Increases all pulses of the player to 3
        func = function(player)
            for i = 1, grid.wC do
                for j = 1, grid.hC do
                    local cell = grid.cells[i][j]
                    if cell.name == player.name and not cell.exploding then
                        cell.color = player.color
                        cell.name = player.name
                        cell.pulses = math.min(5, cell.pulses + 3)

                        if cell.pulses > 4 then
                            queueExplosion(cell, i, j)
                        end
                    end
                end
            end
        end
    },

    {
        name = "Double Increment", -- Increases all pulses of the player to 3
        func = function(player)
            for i = 1, grid.wC do
                for j = 1, grid.hC do
                    local cell = grid.cells[i][j]
                    if cell.name == player.name and not cell.exploding then
                        cell.color = player.color
                        cell.name = player.name
                        cell.pulses = math.min(5, cell.pulses + 2)

                        if cell.pulses > 4 then
                            queueExplosion(cell, i, j)
                        end
                    end
                end
            end
        end
    },

    {
        name = "Explode All", -- Increases all pulses of the player to 3
        func = function(player)
            for i = 1, grid.wC do
                for j = 1, grid.hC do
                    local cell = grid.cells[i][j]
                    if cell.name == player.name and not cell.exploding then
                        cell.color = player.color
                        cell.name = player.name
                        cell.pulses = 5

                        if cell.pulses > 4 then
                            queueExplosion(cell, i, j)
                        end
                    end
                end
            end
        end
    },

    {
        name = "Create Five", -- Increases all pulses of the player to 3
        func = function(player)
            local count = 5

            local canditates = {}

            for i = 1, grid.wC do
                for j = 1, grid.hC do
                    local cell = grid.cells[i][j]
                    if cell.pulses == 0 and not cell.exploding then
                        table.insert(canditates, cell)
                    end
                end
            end

            for i = #canditates, 1, -1 do
                local j = love.math.random(i)
                canditates[i], canditates[j] = canditates[j], canditates[i]
            end

            for i = 1, math.min(count, #canditates) do
                local cell = canditates[i]
                cell.color = player.color
                cell.name = player.name
                cell.pulses = 1
            end
        end
    },


    -- AI MADE ( DELETE THEM LATER )
    -- {
    --     name = "Chain Boost",
    --     func = function(player)
    --         for i = 1, grid.wC do
    --             for j = 1, grid.hC do
    --                 local cell = grid.cells[i][j]
    --                 if cell.name == player.name and not cell.exploding then
    --                     cell.pulses = math.min(5, cell.pulses + 1)
    --                     if cell.pulses > 4 then
    --                         queueExplosion(cell, i, j)
    --                     end
    --                 end
    --             end
    --         end
    --     end
    -- },
    -- {
    --     name = "Detonate Edges",
    --     func = function(player)
    --         for i = 1, grid.wC do
    --             for j = 1, grid.hC do
    --                 local isEdge = i == 1 or j == 1 or i == grid.wC or j == grid.hC
    --                 local cell = grid.cells[i][j]
    --                 if isEdge and cell.name == player.name and not cell.exploding then
    --                     cell.pulses = 5
    --                     queueExplosion(cell, i, j)
    --                 end
    --             end
    --         end
    --     end
    -- },


}

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
                cell.pulses = 1
            end
        end
    },


    -- AI MADE ( DELETE THEM LATER )
    {
        name = "Chain Boost",
        func = function(player)
            for i = 1, grid.wC do
                for j = 1, grid.hC do
                    local cell = grid.cells[i][j]
                    if cell.name == player.name and not cell.exploding then
                        cell.pulses = math.min(5, cell.pulses + 1)
                        if cell.pulses > 4 then
                            queueExplosion(cell, i, j)
                        end
                    end
                end
            end
        end
    },
    {
        name = "Detonate Edges",
        func = function(player)
            for i = 1, grid.wC do
                for j = 1, grid.hC do
                    local isEdge = i == 1 or j == 1 or i == grid.wC or j == grid.hC
                    local cell = grid.cells[i][j]
                    if isEdge and cell.name == player.name and not cell.exploding then
                        cell.pulses = 5
                        queueExplosion(cell, i, j)
                    end
                end
            end
        end
    },
    {
        name = "Stabilize",
        func = function(player)
            for i = 1, grid.wC do
                for j = 1, grid.hC do
                    local cell = grid.cells[i][j]
                    if cell.name == player.name and not cell.exploding then
                        cell.pulses = math.min(cell.pulses, 3)
                    end
                end
            end
        end
    },
    {
        name = "Convert Neighbors",
        func = function(player)
            for i = 1, grid.wC do
                for j = 1, grid.hC do
                    local cell = grid.cells[i][j]
                    if cell.name == player.name then
                        local dirs = { { 1, 0 }, { -1, 0 }, { 0, 1 }, { 0, -1 } }
                        for _, d in ipairs(dirs) do
                            local ni, nj = i + d[1], j + d[2]
                            if grid.cells[ni] and grid.cells[ni][nj] then
                                local ncell = grid.cells[ni][nj]
                                if ncell.name ~= "" and ncell.name ~= player.name and ncell.pulses <= 1 then
                                    ncell.name = player.name
                                    ncell.color = player.color
                                end
                            end
                        end
                    end
                end
            end
        end
    },
    {
        name = "Seed Corners",
        func = function(player)
            local corners = {
                { 1,       1 }, { 1, grid.hC },
                { grid.wC, 1 }, { grid.wC, grid.hC }
            }

            for _, c in ipairs(corners) do
                local cell = grid.cells[c[1]][c[2]]
                if cell.pulses == 0 then
                    cell.name = player.name
                    cell.color = player.color
                    cell.pulses = 2
                end
            end
        end
    },
    {
        name = "Random Blast",
        func = function(player)
            local list = {}
            for i = 1, grid.wC do
                for j = 1, grid.hC do
                    table.insert(list, { i, j })
                end
            end

            for n = 1, 3 do
                local pick = love.math.random(#list)
                local i, j = list[pick][1], list[pick][2]
                local cell = grid.cells[i][j]
                cell.pulses = 5
                queueExplosion(cell, i, j)
            end
        end
    },
    {
        name = "Pulse Swap",
        func = function(player)
            local a = grid.cells[love.math.random(grid.wC)][love.math.random(grid.hC)]
            local b = grid.cells[love.math.random(grid.wC)][love.math.random(grid.hC)]
            a.pulses, b.pulses = b.pulses, a.pulses
        end
    },

}

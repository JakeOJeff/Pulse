local grid = {}

function grid:load()
    self.cells = {}
    self.wC = 10
    self.hC = 18 --20

    self.size = wW / (self.wC + 2)

    self.width = self.size * self.wC
    self.height = self.size * self.hC

    self.explosionQueue = {}
    self.explosionDelay = 0.08
    self.explosionTimer = 0


    for i = 1, self.wC do
        self.cells[i] = {}

        for j = 1, self.hC do
            self.cells[i][j] = {
                x = self.size + (i - 1) * self.size,
                y = self.size + (j - 1) * self.size,
                name = "",
                color = { 1, 1, 1 },
                pulses = 0,

                exploding = false,
                explodeTimer = 0,
            }
        end
    end
end

function grid:update(dt)
    self.explosionTimer = self.explosionTimer + dt

    if self.explosionTimer >= self.explosionDelay then
        self.explosionTimer = 0

        local e = table.remove(grid.explosionQueue, 1)
        if e then
            explodeCell(self.cells[e.i][e.j], e.i, e.j)
        end
    end
end

function queueExplosion(cell, i, j)
    if not cell.exploding then
        cell.exploding = true
        table.insert(grid.explosionQueue, { i = i, j = j })
    end
end

function explodeCell(cell, i, j)
    local cells = grid.cells

    -- RESET exploding cell
    cell.pulses = 1
    cell.exploding = false

    local dirs = {
        { 0,  -1 },
        { -1, 0 },
        { 0,  1 },
        { 1,  0 }
    }

    for _, d in ipairs(dirs) do
        local ni, nj = i + d[1], j + d[2]

        if cells[ni] and cells[ni][nj] then
            local n = cells[ni][nj]
            n.pulses = n.pulses + 1
            n.color = cell.color
            n.name = cell.name

            if n.pulses > 4 then
                queueExplosion(n, ni, nj)
            end
        end
    end
end

function grid:mousepressed(x, y, button)
    if button == 1 then
        for i = 1, self.wC do
            for j = 1, self.hC do
                local cell = self.cells[i][j]
                local iX, iY = cell.x, cell.y
                if x > iX and x < iX + self.size and y > iY and y < iY + self.size then
                    -- Skip if cell is already exploding
                    if cell.exploding then
                        return
                    end
                    
                    local incrementValue = false
                    if cell.pulses == 0 then
                        cell.name = currentPlayer.name
                        cell.color = currentPlayer.color
                        cell.pulses = 1
                        incrementValue = true
                    elseif cell.name == currentPlayer.name then
                        cell.pulses = cell.pulses + 1
                        if cell.pulses > 4 then
                            queueExplosion(cell, i, j)
                        end
                        incrementValue = true
                    end
                    if incrementValue then
                        if playerIndex > #activePlayers - 1 then
                            playerIndex = 1
                        else
                            playerIndex = playerIndex + 1
                        end
                        currentPlayer = activePlayers[playerIndex]
                    end
                end
            end
        end
    end
end
function grid:draw()
    for i = 1, self.wC do
        for j = 1, self.hC do
            local cell = self.cells[i][j]
            local radius = self.size / 2 / 2
            local cx, cy = cell.x + self.size / 2, cell.y + self.size / 2
            local dx, dy = math.sin(love.timer.getTime() * cell.pulses), math.cos(love.timer.getTime() * cell.pulses)

            love.graphics.setColor(cell.color)
            love.graphics.rectangle("line", self.cells[i][j].x, self.cells[i][j].y, self.size, self.size)

            local positions = {}
            local coordinates = {}
            if cell.pulses == 1 then
                table.insert(positions, { cx + dx, cy + dx, radius + dy })
            elseif cell.pulses == 2 then
                table.insert(positions, { cx - self.size / 4 + dx, cy + dx, radius / 1.5 + dy })
                table.insert(positions, { cx + self.size / 4 + dx, cy + dx, radius / 1.5 + dy })
            elseif cell.pulses == 3 then
                table.insert(positions, { cx + dx, cy - self.size / 4 + dx, radius / 2 + dy })
                table.insert(positions, { cx - self.size / 4 + dx, cy + self.size / 4 + dx, radius / 2 + dy })
                table.insert(positions, { cx + self.size / 4 + dx, cy + self.size / 4 + dx, radius / 2 + dy })
            elseif cell.pulses == 4 then
                table.insert(positions, { cx - self.size / 4 + dx, cy + dx, radius / 2.5 + dy })
                table.insert(positions, { cx + dx, cy - self.size / 4 + dx, radius / 2.5 + dy })
                table.insert(positions, { cx + self.size / 4 + dx, cy + dx, radius / 2.5 + dy })
                table.insert(positions, { cx + dx, cy + self.size / 4 + dx, radius / 2.5 + dy })
            end
            for i = 1, #positions do
                love.graphics.circle("fill", positions[i][1], positions[i][2], positions[i][3])
                table.insert(coordinates, positions[i][1])
                table.insert(coordinates, positions[i][2])
            end

            if #coordinates >= 4 then
                if cell.pulses > 2 then
                    love.graphics.polygon("fill", coordinates)
                else
                    love.graphics.line(coordinates)
                end
            end -- love.graphics.print(cell.pulses, cx, cy)
        end
    end

    love.graphics.setColor(currentPlayer.color)
    love.graphics.print("Current Player", self.size, self.size + self.height + 20)
    love.graphics.setColor(1, 1, 1)
end

return grid

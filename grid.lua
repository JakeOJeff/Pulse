local grid = {}

function grid:load()
    self.cells = {}
    self.wC = 10
    self.hC = 18 --20

    self.size = wW / (self.wC + 2)

    self.width = self.size * self.wC
    self.height = self.size * self.hC
    for i = 1, self.wC do
        self.cells[i] = {}

        for j = 1, self.hC do
            self.cells[i][j] = {
                x = self.size + (i - 1) * self.size,
                y = self.size + (j - 1) * self.size,
                name = "",
                color = { 1, 1, 1 },
                pulses = 0
            }
        end
    end
end

function grid:update(dt)

end

function grid:mousepressed(x, y, button)
    if button == 1 then
        for i = 1, self.wC do
            for j = 1, self.hC do
                local cell = self.cells[i][j]
                local iX, iY = cell.x, cell.y
                if x > iX and x < iX + self.size and y > iY and y < iY + self.size then
                    local incrementValue = false
                    if cell.pulses < 1 then
                        cell.name = currentPlayer.name
                        cell.color = currentPlayer.color
                        cell.pulses = cell.pulses + 1
                        incrementValue = true
                    elseif cell.pulses < 4 and cell.name == currentPlayer.name then
                        cell.pulses = cell.pulses + 1
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
                table.insert(positions, { cx + dx, cy + dy, radius })
            elseif cell.pulses == 2 then
                table.insert(positions, { cx - self.size / 4  + dx, cy, radius / 1.5 + dy })
                table.insert(positions, { cx + self.size / 4  + dx, cy, radius / 1.5 + dy })
            elseif cell.pulses == 3 then
                table.insert(positions, { cx, cy - self.size / 4 + dx, radius / 2  + dy})
                table.insert(positions, { cx - self.size / 4 + dx, cy + self.size / 4, radius / 2  + dy})
                table.insert(positions, { cx + self.size / 4 + dx, cy + self.size / 4, radius / 2  + dy})
            elseif cell.pulses == 4 then
                table.insert(positions, { cx - self.size / 4 + dx, cy, radius / 2.5 + dy })
                table.insert(positions, { cx, cy - self.size / 4 + dx, radius / 2.5 + dy })
                table.insert(positions, { cx + self.size / 4, cy + dx, radius / 2.5  + dy})
                table.insert(positions, { cx, cy + self.size / 4 + dx, radius / 2.5  + dy})
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

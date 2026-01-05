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
                    if cell.pulses < 1 then
                        cell.name = currentPlayer.name
                        cell.pulses = cell.pulses + 1
                    elseif cell.pulses < 4 and cell.name == currentPlayer.name then
                        cell.pulses = cell.pulses + 1
                        if playerIndex < #activePlayers then
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

            love.graphics.rectangle("line", self.cells[i][j].x, self.cells[i][j].y, self.size, self.size)
            if cell.pulses == 1 then
                love.graphics.circle("fill", cx, cy, radius)
            end
            love.graphics.print(cell.pulses, cx, cy)
        end
    end

    love.graphics.setColor(currentPlayer.color)
    love.graphics.print("Current Player", self.size, self.size + self.height + 20)
    love.graphics.setColor(1, 1, 1)
end

return grid

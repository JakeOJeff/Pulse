local grid = {}

function grid:load()
    self.cells = {}
    self.wC = 5
    self.hC = 20

    self.size = wW / (self.wC + 2)

    self.width = self.size * self.wC
    self.height = self.size * self.hC
    for i = 1, self.wC do
                self.cells[i] = {}

        for j = 1, self.hC do
            self.cells[i][j] = {
                x = self.size + (i - 1) * self.size,
                y = self.size + (j - 1) * self.size,
            }
        end
    end
end

function grid:update(dt)

end

function grid:draw()
    for i = 1, self.wC do
        for j = 1, self.hC do
            love.graphics.rectangle("line", self.cells[i][j].x, self.cells[i][j].y, self.size, self.size)
        end
    end
end

return grid

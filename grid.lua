local grid = {}

function grid:load()
    self.cells = {}
    self.wC = 5
    self.hC = 20

    self.size = 20

    self.width = self.size * self.wC
    self.height = self.size * self.hC
end

function grid:update(dt)

end

function grid:draw()

end

return grid

local grid = {}

function grid:load()
    self.cells = {}
    self.wC = 10
    self.hC = 18 --20

    self.size = wW / (self.wC + 2)

    self.width = self.size * self.wC
    self.height = self.size * self.hC

    self.explosionQueue = {}
    self.explosionDelay = .08
    self.explosionTimer = 0
    self.movingPulses = {}


    for i = 1, self.wC do
        self.cells[i] = {}

        for j = 1, self.hC do
            self.cells[i][j] = {
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

            self.cells[i][j].name = "Red"
            self.cells[i][j].color = { 1, 0, 0 }
            self.cells[i][j].pulses = math.random(3, 4)
        end
    end
end

function grid:update(dt)
    if #grid.explosionQueue > 0 then
        self.explosionTimer = self.explosionTimer + dt
        print(self.explosionTimer)

        if self.explosionTimer >= self.explosionDelay then
            print("Exploding")
            self.explosionTimer = 0

            local e = table.remove(grid.explosionQueue, 1)
            if e then
                explodeCell(self.cells[e.i][e.j], e.i, e.j)
            end
        end
    end


    -- Iterate and refactor coordinates
    for i = 1, self.wC do
        for j = 1, self.hC do
            local cell = self.cells[i][j]
            local dv = 0
            if cell.exploding then
                dv = 3
            end
            local radius = self.size / 4
            local cx, cy = cell.x + self.size / 2, cell.y + self.size / 2
            local dx, dy = math.sin(love.timer.getTime() * cell.pulses + cell.offset),
                math.cos(love.timer.getTime() * cell.pulses)
            cell.circles = {}
            cell.coordinates = {}

            if cell.pulses == 1 then
                table.insert(cell.circles, { cx + dx, cy + dx, radius + dy })
            elseif cell.pulses == 2 then
                table.insert(cell.circles, { cx - self.size / 4 + dx, cy + dx, radius / 1.5 + dy })
                table.insert(cell.circles, { cx + self.size / 4 + dx, cy + dx, radius / 1.5 + dy })
            elseif cell.pulses == 3 then
                table.insert(cell.circles, { cx + dx, cy - self.size / 4 + dx, radius / 2 + dy })
                table.insert(cell.circles,
                    { cx - self.size / 4 + dx, cy + self.size / 4 + dx, radius / 2 + dy })
                table.insert(cell.circles,
                    { cx + self.size / 4 + dx, cy + self.size / 4 + dx, radius / 2 + dy })
            elseif cell.pulses == 4 then
                table.insert(cell.circles, { cx - self.size / 4 + dx, cy + dx - dv, radius / 2.5 + dy })
                table.insert(cell.circles, { cx + dx - dv, cy - self.size / 4 + dx, radius / 2.5 + dy })
                table.insert(cell.circles, { cx + self.size / 4 + dx, cy + dx + dv, radius / 2.5 + dy })
                table.insert(cell.circles, { cx + dx + dv, cy + self.size / 4 + dx, radius / 2.5 + dy })
            end
            for i = 1, #cell.circles do
                table.insert(cell.coordinates, cell.circles[i][1])
                table.insert(cell.coordinates, cell.circles[i][2])
            end
        end
    end
    for i = #self.movingPulses, 1, -1 do
        local p = self.movingPulses[i]
        p.progress = p.progress + dt * p.speed

        if p.progress >= 1 then
            -- pulse arrives
            p.targetCell.pulses = p.targetCell.pulses + 1
            p.targetCell.color = p.color

            if p.targetCell.pulses > 4 then
                queueExplosion(p.targetCell,
                    math.floor((p.tx - self.size) / self.size) + 1,
                    math.floor((p.ty - self.size) / self.size) + 1
                )
            end

            table.remove(self.movingPulses, i)
        else
            -- smooth interpolation
            p.x = p.sx + (p.tx - p.sx) * p.progress
            p.y = p.sy + (p.ty - p.sy) * p.progress
        end
    end
end

function queueExplosion(cell, i, j)
    if not cell.exploding then
        print("Queueud")
        cell.exploding = true
        table.insert(grid.explosionQueue, { i = i, j = j })
    end
end

function explodeCell(cell, i, j)
    local cx = cell.x + grid.size / 2
    local cy = cell.y + grid.size / 2

    cell.pulses = 0
    cell.exploding = false

    local dirs = {
        { 0,  -1 },
        { -1, 0 },
        { 0,  1 },
        { 1,  0 }
    }

    for _, d in ipairs(dirs) do
        local ni, nj = i + d[1], j + d[2]
        if grid.cells[ni] and grid.cells[ni][nj] then
            local target = grid.cells[ni][nj]
            local tx = target.x + grid.size / 2
            local ty = target.y + grid.size / 2

            table.insert(grid.movingPulses, {
                x = cx,
                y = cy,
                sx = cx,
                sy = cy,
                tx = tx,
                ty = ty,
                progress = 0,
                speed = 3,
                color = cell.color,
                targetCell = target
            })
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


            love.graphics.setColor(1, 1, 1, 0.5)
            love.graphics.rectangle("line", self.cells[i][j].x, self.cells[i][j].y, self.size, self.size)
            for _, p in ipairs(self.movingPulses) do
                love.graphics.setColor(p.color)
                love.graphics.circle("fill", p.x, p.y, self.size / 6)
            end

            love.graphics.setColor(cell.color)

            for i = 1, #cell.circles do
                love.graphics.circle("fill", cell.circles[i][1], cell.circles[i][2], cell.circles[i][3])
            end

            local count = #cell.coordinates

            if cell.pulses >= 3 and count >= 6 then
                love.graphics.polygon("fill", cell.coordinates)
            elseif cell.pulses == 2 and count >= 4 then
                love.graphics.line(cell.coordinates)
            end
        end
    end

    love.graphics.setColor(currentPlayer.color)
    love.graphics.print("Current Player", self.size, self.size + self.height + 20)
    love.graphics.setColor(1, 1, 1)
end

return grid

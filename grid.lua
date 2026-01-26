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
    self.explosionTime = 0
    self.movingPulses = {}

    self.roundCount = 0
    self.turnResolved = true

    self.shakeTime = 0
    self.shakeStrength = 0

    self.imgs = {
        bg = love.graphics.newImage("assets/bg.png"),
        cell = love.graphics.newImage("assets/cell.png")
    }


    for i = 1, self.wC do
        self.cells[i] = {}

        for j = 1, self.hC do
            self.cells[i][j] = {
                x = self.size + (i - 1) * self.size,
                y = self.size + (j - 1) * self.size,
                name = "",
                color = { 1, 1, 1 },
                pulses = 0,
                offset = love.math.random(0, 1),
                circles = {},
                coordinates = {},

                exploding = false,

            }

            -- self.cells[i][j].name = "Red"
            -- self.cells[i][j].color = { 1, 0, 0 }
            -- self.cells[i][j].pulses = 4
        end
    end
end

function grid:startShake(str, time)
    self.shakeStrength = str * settings.shakeStrength/10
    self.shakeTime = time
end

function grid:update(dt)
    if #grid.explosionQueue > 0 then
        self.explosionTimer = self.explosionTimer + dt
        self.explosionTime = self.explosionTime + dt
        print(self.explosionTimer)

        if self.explosionTimer >= self.explosionDelay then
            print("Exploding")
            self.explosionTimer = 0

            local e = table.remove(grid.explosionQueue, 1)
            if e then
                explodeCell(self.cells[e.i][e.j], e.i, e.j)
            end
        end
    else
        self.explosionTime = 0
        for i = 1, self.wC do
            for j = 1, self.hC do
                self.cells[i][j].exploding = false
            end
        end
    end

    if self.shakeTime > 0 then
        self.shakeTime = self.shakeTime - dt
    else
                self.shakeStrength = 0

    end
    for i, v in ipairs(activePlayers) do
        v.score = 0
    end

    -- Iterate and refactor coordinates
    for i = 1, self.wC do
        for j = 1, self.hC do
            local cell = self.cells[i][j]

            for i, v in ipairs(activePlayers) do
                if v.name == cell.name and #self.explosionQueue == 0 and #self.movingPulses == 0 then
                    v.score = v.score + cell.pulses
                end
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
                table.insert(cell.circles, { cx - self.size / 4 + dx, cy + dx, radius / 2.5 + dy })
                table.insert(cell.circles, { cx + dx, cy - self.size / 4 + dx, radius / 2.5 + dy })
                table.insert(cell.circles, { cx + self.size / 4 + dx, cy + dx, radius / 2.5 + dy })
                table.insert(cell.circles, { cx + dx, cy + self.size / 4 + dx, radius / 2.5 + dy })
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
            p.targetCell.name = p.owner

            if p.targetCell.pulses > 4 then
                queueExplosion(
                    p.targetCell,
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

    if self.turnResolved and
        #self.explosionQueue == 0 and
        #self.movingPulses == 0 then
        self.turnResolved = false
        self:evaluateWinState()
    end
end

function grid:evaluateWinState()
    if self.roundCount < totalPlayers then
        return
    end

    local alivePlayers = {}

    for _, p in ipairs(activePlayers) do
        alivePlayers[p.name] = 0
    end

    -- count pulses
    for i = 1, self.wC do
        for j = 1, self.hC do
            local cell = self.cells[i][j]
            if cell.name ~= "" and alivePlayers[cell.name] ~= nil then
                alivePlayers[cell.name] = alivePlayers[cell.name] + cell.pulses
            end
        end
    end

    local remaining = {}

    for _, p in ipairs(activePlayers) do
        if alivePlayers[p.name] > 0 then
            p.eliminated = false
            table.insert(remaining, p)
        else
            p.eliminated = true
        end
    end

    activePlayers = remaining
    -- Fix playerIndex if out of range
    if playerIndex > #activePlayers then
        playerIndex = 1
    end

    currentPlayer = activePlayers[playerIndex]

    if #remaining == 1 then
        winner = remaining[1]
        gameState = "WIN"
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
                speed = 2 * (grid.explosionTime + 1),
                color = cell.color,
                owner = cell.name,
                targetCell = target
            })
        end
    end
        grid:startShake(grid.explosionTime, 0.15)

end

function grid:mousepressed(x, y, button)
    if button == 1 then
        if #self.explosionQueue > 0 or #self.movingPulses > 0 or winner or gameState then
            return
        end
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
                    elseif cell.name == currentPlayer.name or cell.color == currentPlayer.color then
                        cell.pulses = cell.pulses + 1
                        if cell.pulses > 4 then
                            queueExplosion(cell, i, j)
                        end
                        incrementValue = true
                    end
                    if incrementValue then
                        -- end current player's turn
                        if powerupRoundsLeft > 0 then
                            powerupRoundsLeft = powerupRoundsLeft - 1
                        end
                        self.roundCount = self.roundCount + 1

                        if powerupRoundsLeft == 0 then
                            local randomVal = love.math.random(1, #events)
                            events[randomVal].func(currentPlayer)
                            recentPowerup = events[randomVal].name
                            powerupRoundsLeft = love.math.random(2, 6)
                        end

                        -- next player
                        playerIndex = playerIndex % #activePlayers + 1
                        currentPlayer = activePlayers[playerIndex]
                        self.turnResolved = true
                    end
                end
            end
        end
    end
end

function grid:draw()

    love.graphics.push()
    love.graphics.scale(scale, scale)
    love.graphics.draw(self.imgs.bg)

    love.graphics.pop()
    love.graphics.push()

    if self.shakeTime > 0 then
        local dx = love.math.random(-self.shakeStrength, self.shakeStrength)
        local dy = love.math.random(-self.shakeStrength, self.shakeStrength)
        love.graphics.translate(dx, dy)
    end
    for i = 1, self.wC do
        for j = 1, self.hC do
            local cell = self.cells[i][j]


            if not gameState then
                -- love.graphics.setColor(currentPlayer.color[1], currentPlayer.color[2], currentPlayer.color[3], 1)
                love.graphics.setColor(1,1,1)
                love.graphics.rectangle("line", self.cells[i][j].x, self.cells[i][j].y, self.size, self.size)
            elseif gameState == "WIN" and winner then
                local fluidity = math.abs(math.sin(love.timer.getTime() + j))
                love.graphics.setColor(1,1,1, fluidity)
            end
            -- love.graphics.rectangle("line", self.cells[i][j].x, self.cells[i][j].y, self.size, self.size)
            self.cellImgW = self.imgs.cell:getWidth()
            self.cellImgH = self.imgs.cell:getHeight()

            
            local scaleX = self.size / self.cellImgW
            local scaleY = self.size / self.cellImgH

            love.graphics.draw(
                self.imgs.cell,
                cell.x,
                cell.y,
                0,
                scaleX,
                scaleY
            )


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

    love.graphics.pop()

    love.graphics.setColor(currentPlayer.color)
    love.graphics.print("|Current Player " .. powerupRoundsLeft .. "\n| Powerup " .. recentPowerup, self.size,
        self.size + self.height + 20)
    for i, v in ipairs(activePlayers) do
        love.graphics.setColor(v.color)
        love.graphics.print(v.name .. " | " .. v.score .. " | ", self.size, self.size + self.height + 50 + 20 * i)
    end
    love.graphics.setColor(1, 1, 1)
end

return grid

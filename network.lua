-- network.lua - LAN Multiplayer Network Manager
-- Handles server hosting, client connections, and game state synchronization

local socket = require("socket")
local json = require("json") -- You'll need a JSON library like dkjson or lunajson

local Network = {}
Network.__index = Network

-- Constants
local BROADCAST_PORT = 47777  -- Port for server discovery
local GAME_PORT = 47778       -- Port for actual game communication
local BROADCAST_INTERVAL = 1.0 -- How often to broadcast server presence (seconds)
local DISCOVERY_TIMEOUT = 5.0  -- How long to wait for server discovery

function Network.new()
    local self = setmetatable({}, Network)
    
    -- Network state
    self.mode = nil  -- "server" or "client"
    self.isConnected = false
    
    -- Server properties
    self.tcpServer = nil
    self.udpBroadcast = nil
    self.clients = {}  -- List of connected clients
    self.nextClientId = 1
    
    -- Client properties
    self.tcpClient = nil
    self.serverAddress = nil
    self.playerId = nil
    
    -- Game state (shared between server and clients)
    self.gameState = {
        players = {},
        currentTurn = 1,
        turnData = {}
    }
    
    -- Timers
    self.broadcastTimer = 0
    
    return self
end

-- ====================
-- SERVER FUNCTIONS
-- ====================

function Network:startServer(serverName)
    self.mode = "server"
    self.serverName = serverName or "LOVE2D Game Server"
    
    -- Create TCP server for game communication
    self.tcpServer = socket.tcp()
    self.tcpServer:bind("*", GAME_PORT)
    self.tcpServer:listen(4)  -- Allow up to 4 clients
    self.tcpServer:settimeout(0)  -- Non-blocking
    
    -- Create UDP socket for broadcasting server presence
    self.udpBroadcast = socket.udp()
    self.udpBroadcast:setsockname("*", BROADCAST_PORT)
    self.udpBroadcast:setoption("broadcast", true)
    self.udpBroadcast:settimeout(0)
    
    print("Server started on port " .. GAME_PORT)
    print("Broadcasting on port " .. BROADCAST_PORT)
    
    return true
end

function Network:serverUpdate(dt)
    -- Broadcast server presence periodically
    self.broadcastTimer = self.broadcastTimer + dt
    if self.broadcastTimer >= BROADCAST_INTERVAL then
        self:broadcastServerPresence()
        self.broadcastTimer = 0
    end
    
    -- Accept new client connections
    local client = self.tcpServer:accept()
    if client then
        client:settimeout(0)
        local clientId = self.nextClientId
        self.nextClientId = self.nextClientId + 1
        
        self.clients[clientId] = {
            socket = client,
            id = clientId,
            address = client:getpeername()
        }
        
        -- Send client their ID
        self:sendToClient(clientId, {
            type = "connection",
            clientId = clientId,
            gameState = self.gameState
        })
        
        print("Client " .. clientId .. " connected from " .. self.clients[clientId].address)
        
        -- Notify all clients of new player
        self:broadcastToClients({
            type = "playerJoined",
            playerId = clientId
        })
    end
    
    -- Receive messages from clients
    for clientId, client in pairs(self.clients) do
        local message, err = self:receiveFromClient(clientId)
        if message then
            self:handleClientMessage(clientId, message)
        elseif err == "closed" then
            self:removeClient(clientId)
        end
    end
end

function Network:broadcastServerPresence()
    local message = json.encode({
        type = "serverDiscovery",
        serverName = self.serverName,
        port = GAME_PORT,
        players = #self.clients
    })
    
    self.udpBroadcast:sendto(message, "255.255.255.255", BROADCAST_PORT)
end

function Network:handleClientMessage(clientId, message)
    if message.type == "turnAction" then
        -- Update game state with turn action
        table.insert(self.gameState.turnData, message.data)
        
        -- Broadcast the action to all other clients
        self:broadcastToClients(message, clientId)
        
    elseif message.type == "stateUpdate" then
        -- Client requesting full state sync
        self:sendToClient(clientId, {
            type = "fullState",
            gameState = self.gameState
        })
    end
end

function Network:sendToClient(clientId, data)
    local client = self.clients[clientId]
    if client then
        local message = json.encode(data) .. "\n"
        client.socket:send(message)
    end
end

function Network:broadcastToClients(data, excludeClientId)
    for clientId, client in pairs(self.clients) do
        if clientId ~= excludeClientId then
            self:sendToClient(clientId, data)
        end
    end
end

function Network:receiveFromClient(clientId)
    local client = self.clients[clientId]
    if not client then return nil end
    
    local data, err, partial = client.socket:receive("*l")
    
    if data then
        return json.decode(data), nil
    else
        return nil, err
    end
end

function Network:removeClient(clientId)
    print("Client " .. clientId .. " disconnected")
    if self.clients[clientId] then
        self.clients[clientId].socket:close()
        self.clients[clientId] = nil
        
        -- Notify other clients
        self:broadcastToClients({
            type = "playerLeft",
            playerId = clientId
        })
    end
end

-- ====================
-- CLIENT FUNCTIONS
-- ====================

function Network:discoverServers(callback)
    self.mode = "discovering"
    
    -- Create UDP socket for receiving broadcasts
    local udpReceive = socket.udp()
    udpReceive:setsockname("*", BROADCAST_PORT)
    udpReceive:settimeout(0)
    
    local servers = {}
    local startTime = socket.gettime()
    
    return function(dt)
        local data, ip = udpReceive:receivefrom()
        
        if data then
            local message = json.decode(data)
            if message.type == "serverDiscovery" then
                local serverId = ip .. ":" .. message.port
                if not servers[serverId] then
                    servers[serverId] = {
                        name = message.serverName,
                        ip = ip,
                        port = message.port,
                        players = message.players
                    }
                    print("Found server: " .. message.serverName .. " at " .. ip)
                end
            end
        end
        
        -- Check if discovery timeout reached
        if socket.gettime() - startTime > DISCOVERY_TIMEOUT then
            udpReceive:close()
            callback(servers)
            return true  -- Discovery complete
        end
        
        return false  -- Still discovering
    end
end

function Network:connectToServer(serverIp, serverPort)
    self.mode = "client"
    
    self.tcpClient = socket.tcp()
    self.tcpClient:settimeout(5)  -- 5 second timeout for connection
    
    local success, err = self.tcpClient:connect(serverIp, serverPort or GAME_PORT)
    
    if success then
        self.tcpClient:settimeout(0)  -- Non-blocking after connection
        self.serverAddress = serverIp
        self.isConnected = true
        print("Connected to server at " .. serverIp)
        return true
    else
        print("Failed to connect: " .. tostring(err))
        return false, err
    end
end

function Network:clientUpdate(dt)
    if not self.isConnected then return end
    
    -- Receive messages from server
    local message, err = self:receiveFromServer()
    
    if message then
        self:handleServerMessage(message)
    elseif err == "closed" then
        print("Disconnected from server")
        self.isConnected = false
        self.tcpClient:close()
    end
end

function Network:handleServerMessage(message)
    if message.type == "connection" then
        -- Initial connection - receive player ID and game state
        self.playerId = message.clientId
        self.gameState = message.gameState
        print("Assigned player ID: " .. self.playerId)
        
    elseif message.type == "fullState" then
        -- Full state synchronization
        self.gameState = message.gameState
        
    elseif message.type == "turnAction" then
        -- Another player made a move
        table.insert(self.gameState.turnData, message.data)
        
    elseif message.type == "playerJoined" then
        print("Player " .. message.playerId .. " joined")
        
    elseif message.type == "playerLeft" then
        print("Player " .. message.playerId .. " left")
    end
end

function Network:sendToServer(data)
    if self.isConnected and self.tcpClient then
        local message = json.encode(data) .. "\n"
        self.tcpClient:send(message)
    end
end

function Network:receiveFromServer()
    if not self.tcpClient then return nil end
    
    local data, err, partial = self.tcpClient:receive("*l")
    
    if data then
        return json.decode(data), nil
    else
        return nil, err
    end
end

-- ====================
-- GAME STATE FUNCTIONS
-- ====================

function Network:sendTurnAction(actionData)
    if self.mode == "client" then
        self:sendToServer({
            type = "turnAction",
            data = actionData,
            playerId = self.playerId
        })
    elseif self.mode == "server" then
        -- Server processes its own actions locally
        table.insert(self.gameState.turnData, actionData)
        self:broadcastToClients({
            type = "turnAction",
            data = actionData,
            playerId = 0  -- Server is player 0
        })
    end
end

function Network:requestStateSync()
    if self.mode == "client" then
        self:sendToServer({type = "stateUpdate"})
    end
end

function Network:updateGameState(newState)
    if self.mode == "server" then
        self.gameState = newState
        -- Broadcast to all clients
        self:broadcastToClients({
            type = "fullState",
            gameState = self.gameState
        })
    end
end

-- ====================
-- CLEANUP
-- ====================

function Network:disconnect()
    if self.mode == "server" then
        -- Close all client connections
        for clientId, client in pairs(self.clients) do
            client.socket:close()
        end
        if self.tcpServer then self.tcpServer:close() end
        if self.udpBroadcast then self.udpBroadcast:close() end
        
    elseif self.mode == "client" then
        if self.tcpClient then
            self.tcpClient:close()
        end
    end
    
    self.isConnected = false
    print("Disconnected")
end

return Network

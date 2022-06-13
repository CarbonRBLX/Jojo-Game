local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Centrist = {
    _remotes = {invoked = {}, fired = {}},
    _shared = {
        Stores = {
            PlayerData = "BetaStore",
        }
    }
}

function Centrist.LoadRemotes()
    for _, Remote in pairs(ReplicatedStorage.Remotes:GetChildren()) do
        if Remote:IsA("RemoteEvent") then
            Centrist._remotes.fired[Remote.Name] = Remote
        end

        if Remote:IsA("RemoteFunction") then
            Centrist._remotes.invoked[Remote.Name] = Remote
        end
    end
end

function Centrist.ConnectRemoteServer(RemoteName, Callback)
    local Remote = Centrist._remotes.invoked[RemoteName]

    if not Remote then
        Remote = Centrist.CreateRemote(RemoteName)
    end

    if Callback then
        Remote.OnServerInvoke = Callback
    end
end

function Centrist.ConnectRemoteClient(RemoteName, Callback)
    local Remote = Centrist._remotes.fired[RemoteName]

    if Remote and Callback then
        return Remote.OnClientEvent:Connect(Callback)
    end
end

function Centrist.FireRemoteServer(RemoteName, ...)
    local Remote = Centrist._remotes.fired[RemoteName]

    if Remote then
        Remote:FireClient(...)
    end
end

function Centrist.FireRemoteClient(RemoteName, ...)
    local Remote = Centrist._remotes.invoked[RemoteName]

    if Remote then
        Remote:InvokeServer(...)
    end
end

function Centrist.ConnectRemote(RemoteName, Callback)
    Centrist.LoadRemotes()

    if RunService:IsServer() then
        return Centrist.ConnectRemoteServer(RemoteName, Callback)
    end

    return Centrist.ConnectRemoteClient(RemoteName, Callback)
end

function Centrist.FireRemote(RemoteName, ...)
    Centrist.LoadRemotes()

    if RunService:IsServer() then
        return Centrist.FireRemoteServer(RemoteName, ...)
    end

    return Centrist.FireRemoteClient(RemoteName, ...)
end

function Centrist.FireAll(RemoteName, ...)
    Centrist.LoadRemotes()

    local Remote = Centrist._remotes.fired[RemoteName]

    if not (RunService:IsServer() and Remote) then
        return
    end

    Remote:FireAllClients(...)
end

function Centrist.CreateRemote(RemoteName)
    local Remote = Instance.new("RemoteFunction")
    Remote.Name = RemoteName
    Remote.Parent = ReplicatedStorage.Remotes

    local ClientRemote = Instance.new("RemoteEvent")
    ClientRemote.Name = RemoteName
    ClientRemote.Parent = ReplicatedStorage.Remotes

    Centrist._remotes.fired[RemoteName] = ClientRemote
    Centrist._remotes.invoked[RemoteName] = Remote

    return Remote, ClientRemote
end

return Centrist
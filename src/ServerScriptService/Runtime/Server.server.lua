local ServerScriptService = game:GetService("ServerScriptService")

local SystemFolder = ServerScriptService.Source.Runtime.Systems

local function LoadSystems()
    local Systems = {}
    local SystemOrder = {}
    local SystemCount = 0

    for _, System in pairs(SystemFolder:GetChildren()) do
        local Required = require(System)
        table.insert(SystemOrder, {Required.Priority or 0, System.Name, Required})
        SystemCount += 1
    end

    table.sort(SystemOrder, function(a, b)
        return a[1] > b[1] --// sort by priority (highest first)
    end)

    for _, System in pairs(SystemOrder) do
        Systems[System[2]] = System[3]
    end

    return Systems, SystemCount
end

local function InitializeSystems(Systems, Count)
    local Done = 0

    for _, System in pairs(Systems) do
        task.spawn(function()
            if System.Init then System:Init() end
            Done += 1
        end)
    end

    repeat
        task.wait()
    until Done >= Count
end

local function StartSystems(Systems)
    for _, System in pairs(Systems) do
        if System.Start then
            task.spawn(System.Start, System)
        end
    end
end

local Systems, SystemCount = LoadSystems()
InitializeSystems(Systems, SystemCount)
StartSystems(Systems)
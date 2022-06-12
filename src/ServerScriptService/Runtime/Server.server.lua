local ServerScriptService = game:GetService("ServerScriptService")

local Walmart = require(ServerScriptService.Source.Modules.Walmart)

Walmart.Start()

for _, System in pairs(ServerScriptService.Source.Runtime.Systems:GetChildren()) do
    task.spawn(function()
        local f = require(System)
        if f then
            f()
        end
    end)
end
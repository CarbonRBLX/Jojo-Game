local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local Nectar = require(ReplicatedStorage.Source.Modules.Nectar)

Nectar.Start()

for _, System in pairs(Players.LocalPlayer.PlayerScripts.Source.Systems:GetChildren()) do
    task.spawn(function()
        local f = require(System)
        if f then
            f()
        end
    end)
end
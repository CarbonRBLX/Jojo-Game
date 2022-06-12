local Players = game:GetService("Players")

for _, System in pairs(Players.LocalPlayer.PlayerScripts.Source.Systems:GetChildren()) do
    task.spawn(function()
        local f = require(System)
        if f then
            f()
        end
    end)
end
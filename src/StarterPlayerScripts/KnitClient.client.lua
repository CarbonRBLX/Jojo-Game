local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Knit = require(ReplicatedStorage.Packages.Knit)

Knit.AddControllers(ReplicatedStorage.Source.Controllers)

Knit.Start():andThen(function()
    print(string.format("[%s] Knit has started.", Players.LocalPlayer.UserId))
end):catch(warn)
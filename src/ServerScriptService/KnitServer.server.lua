local ServerStorage = game:GetService("ServerStorage")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Knit = require(ReplicatedStorage.Packages.Knit)

Knit.AddServices(ServerStorage.Source.Services)

Knit.Start():andThen(function()
    print("[Server] Knit has started.")
end):catch(warn)
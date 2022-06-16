local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Knit = require(ReplicatedStorage.Packages.Knit)

local GameService = Knit.CreateService({
    Name = "GameService",
    Client = {},
})

function GameService:KnitInit()
    
end

return GameService
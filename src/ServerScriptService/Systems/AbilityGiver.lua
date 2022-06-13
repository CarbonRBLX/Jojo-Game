local Players = game:GetService("Players")
local ServerScriptService = game:GetService("ServerScriptService")

local Helper = require(ServerScriptService.Source.Modules.Helper)

local function CharacterSpawned(character)
    repeat
        task.wait()
    until character:IsDescendantOf(workspace)

    Helper.CreateStandForCharacter("R6", character)
end

local function CustomerEntered(customer)
    local character = customer.Character or customer.CharacterAdded:Wait()

    CharacterSpawned(character)

    customer.CharacterAdded:Connect(CharacterSpawned)
end

for _, player in pairs(Players:GetPlayers()) do
    CustomerEntered(player)
end

Players.PlayerAdded:Connect(CustomerEntered)

return nil
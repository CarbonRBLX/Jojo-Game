local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Helper = {}

function Helper.WeldStandToCharacter(character, stand)
    local weld = Instance.new("Weld")
    weld.Parent = stand
    weld.Part0 = stand.PrimaryPart
    weld.Part1 = character.PrimaryPart
end

function Helper.CreateStandForCharacter(standName, character)
    local standPrefab = ReplicatedStorage.Assets.Stands:FindFirstChild(standName)

    if not standPrefab then
        error("No stand prefab found for " .. standName)
    end

    character.PrimaryPart = character.HumanoidRootPart

    local stand = standPrefab:Clone()
    stand.Name = "Stand"
    stand.Parent = character
    Helper.WeldStandToCharacter(stand, character)
end

return Helper
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Helper = {
    ABILITY_TRANSPARENCY_BLACKLISTS = {
        Global = {"Stand HumanoidRootPart"}
    }
}

function Helper.WeldAbilityToCharacter(character, ability)
    local weld = Instance.new("Weld")
    weld.Parent = ability
    weld.Part0 = ability.PrimaryPart
    weld.Part1 = character.PrimaryPart
end

function Helper.SetAbilityTransparency(ability, transparency)
    for _, part in pairs(ability:GetDescendants()) do
        if not part:IsA("BasePart") then
            continue
        end

        local isWhitelisted = table.find(Helper.ABILITY_TRANSPARENCY_BLACKLISTS.Global, part.Name) == nil

        if isWhitelisted then
            part.Transparency = transparency
        end
    end
end

function Helper.CreateAbilityForPlayer(standName, character)
    local abilityPrefab = ReplicatedStorage.Assets.Abilities:FindFirstChild(standName)

    if not abilityPrefab then
        error("No ability prefab found for " .. standName)
    end

    character.PrimaryPart = character.HumanoidRootPart

    local ability = abilityPrefab:Clone()
    ability:SetAttribute("Ability", standName)
    ability.Name = "Ability"

    Helper.SetAbilityTransparency(ability, 1)

    ability.Parent = character
    Helper.WeldAbilityToCharacter(ability, character)
end

return Helper
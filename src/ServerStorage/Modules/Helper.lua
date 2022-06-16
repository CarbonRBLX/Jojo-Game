local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Helper = {
    ABILITY_TRANSPARENCY_BLACKLISTS = {
        Global = {"Stand HumanoidRootPart"}
    },

    Setups = {},
}

function Helper.Weld(part0, part1, c0, c1)
    assert(typeof(part0) == "Instance" and part0:IsA("BasePart"))
    assert(typeof(part1) == "Instance" and part1:IsA("BasePart"))

    local weld = Instance.new("Motor6D")

    weld.Part0 = part0
    weld.Part1 = part1

    weld.C0 = c0 or CFrame.new()
    weld.C1 = c1 or CFrame.new()

    weld.Parent = part0

    return weld
end

function Helper.WeldAbilityToCharacter(character, ability)
    local weld = Instance.new("Weld")

    weld.Part0 = ability.PrimaryPart
    weld.Part1 = character.PrimaryPart
    weld.Parent = ability

    return weld
end

function Helper.SetAbilityTransparency(ability, transparency, ignoreBlacklist)
    for _, part in pairs(ability:GetDescendants()) do
        if not (part:IsA("BasePart") or part:IsA("ParticleEmitter") or part:IsA("Decal") or part:IsA("Texture")) then
            continue
        end

        local isGlobalWhitelisted = table.find(Helper.ABILITY_TRANSPARENCY_BLACKLISTS.Global, part.Name) == nil
        local isWhitelisted = table.find(Helper.ABILITY_TRANSPARENCY_BLACKLISTS[ability] or {}, part.Name) == nil

        if (isGlobalWhitelisted or isWhitelisted) or ignoreBlacklist then
            part.Transparency = transparency
        end
    end
end

function Helper.CreateAbilityForPlayer(standName, character)
    local abilityPrefab = ReplicatedStorage.Assets.Abilities:FindFirstChild(standName)

    if not abilityPrefab then
        error("No ability prefab found for " .. standName)
    end

    if Helper.Setups[standName] then
        return Helper.Setups[standName](abilityPrefab)
    end

    character.PrimaryPart = character.HumanoidRootPart

    local ability = abilityPrefab:Clone()

    ability:SetAttribute("Ability", standName)
    ability.Name = "Ability"

    Helper.SetAbilityTransparency(ability, 1, true)
    Helper.WeldAbilityToCharacter(ability, character)

    ability.Parent = character
end

return Helper
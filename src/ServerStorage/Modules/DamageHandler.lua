local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local ServerStorage = game:GetService("ServerStorage")
local HttpService = game:GetService("HttpService")

local PING_LENIENCE = 0.2 --// 200 ms

local DamageSolver = require(ServerStorage.Source.Modules.DamageSolver)
local MoveDatabase = require(ReplicatedStorage.Source.Modules.Abilities.Moves.MoveDatabase)

local DamageHandler = {_whitelisted = {}}

function DamageHandler.Whitelist(character, move, hitfunction)
    if not DamageHandler._whitelisted[character] then
        DamageHandler._whitelisted[character] = {}
    end

    local uuid = HttpService:GenerateGUID()

    DamageHandler._whitelisted[character][uuid] = {
        Move = move,
        Time = tick(),

        Hits = {},

        Callback = hitfunction
    }

    return uuid
end

function DamageHandler.WhitelistForDuration(character, move, length)
    local uuid = DamageHandler.Whitelist(character, move)

    task.delay(length, DamageHandler.Blacklist, character, uuid)
end

function DamageHandler.Blacklist(character, uuid)
    DamageHandler._whitelisted[character][uuid] = nil
end

function DamageHandler.GenerateHit()
    return {
        Hits = 1,
        Time = tick(),
    }
end

function DamageHandler.ValidHit(currentHits, ability, hit, requestedDamage, moveInfo)
    local infiniteHits = moveInfo.MaxHitsPerHumanoid <= 0
    local actualDamage = moveInfo.Damage[ability] or moveInfo.Damage.Default
    local lastHit = hit.Time

    if tick() - lastHit < moveInfo.HitInterval then
        return false, 0
    end

    if actualDamage ~= requestedDamage then
        return false, 1
    end

    if (not infiniteHits) and currentHits.Hits >= moveInfo.MaxHitsPerHumanoid then
        return false, 2
    end

    return true
end

function DamageHandler.Check(character, uuid, humanoid, baseDamage)
    if not (typeof(humanoid) == "Instance" and humanoid:IsA("Humanoid") and humanoid:IsDescendantOf(workspace.Entities)) then
        return
    end

    local ability = character:GetAttribute("Ability")
    local info = DamageHandler._whitelisted[character][uuid]

    if not (info and ability) then
        return false
    end

    local moveInfo = MoveDatabase[info.Move]

    local damage = moveInfo.Damage[ability] or moveInfo.Damage.Default

    local player = Players:GetPlayerFromCharacter(character)
    local target = Players:GetPlayerFromCharacter(humanoid.Parent)

    local playerHumanoid = character:FindFirstChild("Humanoid")
    local targetChar = humanoid.Parent

    if not (playerHumanoid and targetChar and targetChar:IsA("Model")) then
        return false
    end

    local hitInfo = info.Hits[humanoid] or DamageHandler.GenerateHit()

    local valid, reason = DamageHandler.ValidHit(info.Hits, ability, hitInfo, baseDamage, moveInfo)

    if not valid then
        if reason == 1 then
            player:Kick()
        end

        return false
    end

    local callerVelocity = math.min(character.PrimaryPart.AssemblyLinearVelocity.Magnitude, playerHumanoid.WalkSpeed)
    local recipientVelocity = math.min(targetChar.PrimaryPart.AssemblyLinearVelocity.Magnitude, humanoid.WalkSpeed)

    local totalVelocity = callerVelocity + recipientVelocity

    local extraLenience = totalVelocity * (1 + PING_LENIENCE) * 0.5
    local constantLenience = if moveInfo.ExtraRange then moveInfo.ExtraRange.Magnitude else 0

    local width = 1
    local maxDistance = extraLenience + constantLenience + width
    local distance = (humanoid.PrimaryPart.Position - character.PrimaryPart.Position).Magnitude

    if distance > maxDistance then
        return false
    end

    hitInfo.Time = tick()
    hitInfo.Hits += 1

    info.Hits[humanoid] = hitInfo

    local playerDamage, enemyDamage = DamageSolver.Solve(character, targetChar, damage)

    target:TakeDamage(playerDamage)
    playerHumanoid:TakeDamage(enemyDamage)

    if info.Callback then
        info.Callback(character, humanoid, playerDamage, enemyDamage)
    end
end

return DamageHandler
local ServerStorage = game:GetService("ServerStorage")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Knit = require(ReplicatedStorage.Packages.Knit)

local Helper = require(ServerStorage.Source.Modules.Helper)
local Walmart = require(ServerStorage.Source.Modules.Walmart)
local Promise = require(ReplicatedStorage.Source.Modules.Promise)

local ONE_DAY = 24 * 60 * 60
local NEW_PROFILE_DAILY_LOGIN = true

local PlayerService = Knit.CreateService({
    Name = "PlayerService",
    Client = {},

    _stores = {}
})

local function CustomerSpawned(character)
    local customer = Players:GetPlayerFromCharacter(character)

    local store = PlayerService:GetStore("PlayerData")
    local profile = store:GetCustomerProfile(customer)

    repeat
        task.wait()
    until character.Parent == workspace

    character.Parent = workspace.Entities
    character:SetAttribute("Ability", profile.Ability)

    Helper.CreateAbilityForPlayer(profile.Ability, character)
end

local function CustomerEnteredAsync(customer)
    local store = PlayerService:GetStore("PlayerData")
    local profile = store:GetCustomerProfile(customer)

    local now = os.time()
    local offset = if NEW_PROFILE_DAILY_LOGIN then ONE_DAY else 0

    local lastDailyLogin = profile.LastDailyLogin or profile.LastLogin or (now - offset)

    if now - lastDailyLogin >= ONE_DAY then
        profile.LastDailyLogin = now

        profile.Money += 100
    end

    profile.LastLogin = now

    store:UpdateCustomerProfile(customer, profile)
end

local function CustomerEntered(customer)
    Promise.async(function(resolve)
        resolve(CustomerEnteredAsync(customer))
    end):catch(warn)

    local character = customer.Character or customer.CharacterAdded:Wait()

    CustomerSpawned(character)
    customer.CharacterAdded:Connect(CustomerSpawned)
end

function PlayerService:GetStore(name)
    return self._stores[name]
end

function PlayerService:KnitStart()
    local WalmartService = Knit.GetService("WalmartService")

    local store = Walmart.OpenStore(WalmartService._storeList.PlayerData)

    store:HireWorker("preSave", function(profile)
        print("Someone's leaving with " .. profile.Money .. " money.")
    end)

    self._stores.PlayerData = store

    Walmart.EnsureCustomers(CustomerEntered)
    Walmart.CustomerEntered:Connect(CustomerEntered)
end

return PlayerService
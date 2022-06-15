local ServerStorage = game:GetService("ServerStorage")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Knit = require(ReplicatedStorage.Packages.Knit)

local Walmart = require(ServerStorage.Source.Modules.Walmart)
local Promise = require(ReplicatedStorage.Source.Modules.Promise)

local PlayerService = Knit.CreateService({
    Name = "PlayerService",
    Client = {},

    _stores = {}
})

local function CustomerEnteredAsync(customer)
    local store = PlayerService:GetStore("PlayerData")
    local profile = store:GetCustomerProfile(customer)

    print(string.format("Customer %s entered with %s money.", customer.DisplayName, profile.Money))
end

local function CustomerEntered(customer)
    Promise.async(function(resolve)
        resolve(CustomerEnteredAsync(customer))
    end):catch(warn)
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
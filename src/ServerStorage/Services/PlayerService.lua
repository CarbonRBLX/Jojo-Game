local ServerStorage = game:GetService("ServerStorage")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Knit = require(ReplicatedStorage.Packages.Knit)

local Walmart = require(ServerStorage.Source.Modules.Walmart)
local Promise = require(ReplicatedStorage.Source.Modules.Promise)

local PlayerService = Knit.CreateService({
    Name = "PlayerService",
    Client = {},
})

local function CustomerEnteredAsync(store, customer)
    local profile = store:GetCustomerProfile(customer)

    print(string.format("Customer %s entered with %s money.", customer.Name, profile.Money))
end

local function CustomerEntered(store, customer)
    Promise.async(function(resolve)
        resolve(CustomerEnteredAsync(store, customer))
    end):catch(warn)
end

function PlayerService:KnitStart()
    local WalmartService = Knit.GetService("WalmartService")

    local store = Walmart.OpenStore(WalmartService._storeList.PlayerData)

    store:HireWorker("preSave", function(profile)
        print("Someone's leaving with " .. profile.Money .. " money.")
    end)

    Walmart.EnsureCustomers(CustomerEntered)
    Walmart.CustomerEntered:Connect(CustomerEntered)
end

return PlayerService
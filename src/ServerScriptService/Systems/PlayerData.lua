local ServerScriptService = game:GetService("ServerScriptService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Promise = require(ReplicatedStorage.Source.Modules.Promise)
local Centrist = require(ReplicatedStorage.Source.Modules.Centrist)
local Walmart = require(ServerScriptService.Source.Modules.Walmart)

local BetaStore = Walmart.OpenStore(Centrist._shared.StoreName)

BetaStore:HireWorker("preSave", function(profile)
    print("Someone's leaving with " .. profile.Money .. " money.")
end)

local function CustomerEndedAsync(customer)
    local profile = BetaStore:GetCustomerProfile(customer)

    print(string.format("Customer %s entered with %s money.", customer.Name, profile.Money))
end

local function CustomerEntered(customer)
    Promise.async(function(resolve)
        resolve(CustomerEndedAsync(customer))
    end):catch(warn)
end

return function()
    Walmart.EnsureCustomers(CustomerEntered)
    Walmart.CustomerEntered:Connect(CustomerEntered)
end
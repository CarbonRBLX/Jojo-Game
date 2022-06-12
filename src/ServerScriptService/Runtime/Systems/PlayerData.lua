local Players = game:GetService("Players")
local ServerScriptService = game:GetService("ServerScriptService")

local Walmart = require(ServerScriptService.Source.Modules.Walmart)

local CustomerData = {}

function CustomerData.CustomerEntered(customer)
    local profile = CustomerData.BetaStore:GetCustomerProfile(customer)

    print(string.format("Customer %s entered with %s money.", customer.Name, profile.Money))
end

function CustomerData:Start()
    local BetaStore = Walmart.OpenStore("BetaStore")

    BetaStore:HireWorker("preSave", function(profile, customer)
        if not customer then
            print(profile)
            return
        end

        print(customer.Name .. " pre-save")
    end)

    BetaStore:HireWorker("postSave", function(profile, customer)
        if not customer then
            print(profile)
            return
        end

        print(customer.Name .. " post-save")
    end)

    CustomerData.BetaStore = BetaStore
    Walmart.EnsureCustomers(CustomerData.CustomerEntered) --// ensure customers are loaded
    Walmart.CustomerEntered:Connect(CustomerData.CustomerEntered)
end

return CustomerData
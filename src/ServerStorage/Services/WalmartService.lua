local ServerStorage = game:GetService("ServerStorage")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Knit = require(ReplicatedStorage.Packages.Knit)

local Walmart = require(ServerStorage.Source.Modules.Walmart)

local WalmartService = Knit.CreateService({
    Name = "WalmartService",
    Client = {
        UpdateProfile = Knit.CreateSignal()
    },

    _storeList = {},
})

function WalmartService.Client:GetStoreList()
    return self.Server._storeList
end

function WalmartService.Client:GetProfile(customer, storeName)
    local store = Walmart.GetStore(storeName)

    if not store then
        return --// dont punish the client for not passing a valid store name
    end

    return store:GetCustomerProfile(customer)
end

function WalmartService:KnitInit()
    Walmart.Start()

    for category, storeName in pairs(Walmart._catalog) do
        self._storeList[category] = storeName
    end
end

return WalmartService
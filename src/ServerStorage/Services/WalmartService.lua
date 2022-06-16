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
    return self.Server:GetProfile(customer, storeName)
end

function WalmartService:GetProfile(customer, storeName)
    local store = Walmart.GetStore(storeName)

    if not store then
        return
    end

    return store:GetCustomerProfile(customer)
end

function WalmartService:KnitInit()
    Walmart.Start()

    for identifier, store in pairs(Walmart._templateStores) do
        self._storeList[identifier] = store.StoreIdentifier
    end
end

return WalmartService
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Knit = require(ReplicatedStorage.Packages.Knit)
local Concur = require(ReplicatedStorage.Packages.Concur)

local NectarController = Knit.CreateController({
    Name = "NectarController",

    _storeList = {},
    _profiles = {},
})

function NectarController:GetInitialProfiles(storeList)
    local WalmartService = Knit.GetService("WalmartService")

    local allStores = {}

    for _, storeName in pairs(storeList) do
        local profile = Concur.spawn(function()
            WalmartService:GetProfile(storeName):andThen(function(profile)
                self._profiles[storeName] = profile
            end):await()
        end)

        table.insert(allStores, profile)
    end

    return Concur.all(allStores)
end

function NectarController:GetProfile(storeName)
    return self._profiles[storeName or self._storeList.PlayerData]
end

function NectarController:KnitInit()
    local WalmartService = Knit.GetService("WalmartService")

    WalmartService:GetStoreList():andThen(function(storeList)
        self._storeList = storeList

        self:GetInitialProfiles(storeList):Await()
    end)

    WalmartService.UpdateProfile:Connect(function(storeName, profile)
        self._profiles[storeName] = profile
    end)
end

return NectarController
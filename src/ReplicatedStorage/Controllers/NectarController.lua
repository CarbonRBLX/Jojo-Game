local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Knit = require(ReplicatedStorage.Packages.Knit)

local NectarController = Knit.CreateController({
    Name = "NectarController",

    _profiles = {},
})

function NectarController:GetInitialProfiles(storeList)
    local WalmartService = Knit.GetService("WalmartService")

    for _, storeName in pairs(storeList) do
        WalmartService:GetProfile(storeName):andThen(function(profile)
            self._profiles[storeName] = profile
        end)
    end
end

function NectarController:KnitInit()
    local WalmartService = Knit.GetService("WalmartService")

    WalmartService:GetStoreList():andThen(function(storeList)
        self:GetInitialProfiles(storeList)
    end)

    WalmartService.UpdateProfile:Connect(function(storeName, profile)
        self._profiles[storeName] = profile
    end)
end

return NectarController
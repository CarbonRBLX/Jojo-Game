--// Client version of Walmart

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Centrist = require(ReplicatedStorage.Source.Modules.Centrist)

local Nectar = {
    _profiles = {},
    _default = Centrist._shared.Stores.PlayerData,
}

function Nectar.Start()
    for _, storeName in pairs(Centrist._shared.Stores) do
        Nectar._profiles[storeName] = Centrist.FireRemote("getProfile", storeName)
    end

    Centrist.ConnectRemote("getProfile", function(updatedStore, profile)
        Nectar._profiles[updatedStore] = profile
    end)
end

function Nectar.GetProfile(storeName)
    return Nectar._profiles[storeName or Nectar._default]
end

return Nectar
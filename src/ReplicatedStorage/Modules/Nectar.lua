--// Client version of Walmart

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Centrist = require(ReplicatedStorage.Source.Modules.Centrist)

local Nectar = {
    _profile = nil
}

function Nectar.Start(storeName)
    Nectar._profile = Centrist.FireRemote("getProfile", storeName)

    Centrist.ConnectRemote("updateProfile", function(profile)
        Nectar._profile = profile
    end)
end

function Nectar.GetProfile()
    return Nectar._profile
end

return Nectar
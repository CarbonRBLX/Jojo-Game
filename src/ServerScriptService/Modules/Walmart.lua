local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local Store = require(ServerScriptService.Source.Modules.Store)
local Signal = require(ReplicatedStorage.Source.Modules.Signal)
local Centrist = require(ReplicatedStorage.Source.Modules.Centrist)

local Walmart = {
	ShuttingDown = false,

	CustomerEntered = Signal.new(),
	CustomerLeft = Signal.new(),

	_version = 0, --// when version is updated, player profiles are overridden
	_stores = {},

	--// (default template)
	_storeStock = {
		BetaStore = {
			Money = 0,
		}
	}
}

function Walmart.Start()
	game:BindToClose(Walmart.Stop)

	Players.PlayerAdded:Connect(function(...)
		Walmart.CustomerEntered:Fire(...)
	end)

	Players.PlayerRemoving:Connect(function(...)
		Walmart.CustomerLeft:Fire(...)
	end)

	Centrist.ConnectRemote("getProfile", function(customer, storeName)
		local store = Walmart._stores[storeName]

		if store then
			return store:GetCustomerProfile(customer)
		end

		--// dont punish for passing in an invalid store. it's whatever.
	end)
end

function Walmart.Stop()
	Walmart.ShuttingDown = true
	Players.CharacterAutoLoads = false

	for address, store in pairs(Walmart._stores) do
		store:Close()
		Walmart._stores[address] = nil
	end
end

function Walmart.GetSlogan(Address)
	return string.format("%s>%s", Address, Walmart._version)
end

function Walmart.OpenStore(Address)
	if not Walmart._stores[Address] then
		Walmart._stores[Address] = Store.new(Address, Walmart)
	end

	return Walmart._stores[Address]
end

function Walmart.CloseStore(Address)
	if Walmart._stores[Address] then
		Walmart._stores[Address]:Close()
		Walmart._stores[Address] = nil
	end
end

function Walmart.EnsureCustomers(Handler)
	for _, Customer in pairs(Players:GetPlayers()) do
		task.spawn(Handler, Customer)
	end
end

return Walmart
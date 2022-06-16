local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")

local Store = require(ServerStorage.Source.Modules.Store)
local Signal = require(ReplicatedStorage.Source.Modules.Signal)

local Walmart = {
	ShuttingDown = false,

	CustomerEntered = Signal.new(),
	CustomerLeft = Signal.new(),

	_version = 0, --// when version is updated, player profiles are overridden
	_stores = {},

	--// (default template)
	_templateStores = {
		PlayerData = {
			LocalVersion = 2.5,
			StoreIdentifier = "BetaStore",

			CustomerProfile = {
				Money = 0,
				Ability = "None"
			}
		}
	},
}

function Walmart.Start()
	game:BindToClose(Walmart.Stop)

	Players.PlayerAdded:Connect(function(...)
		Walmart.CustomerEntered:Fire(...)
	end)

	Players.PlayerRemoving:Connect(function(...)
		Walmart.CustomerLeft:Fire(...)
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
	local template = Walmart._getTemplateFromAddress(Address)

	if not template then
		return
	end

	return string.format("%s.%s>%s", Address, template.LocalVersion, Walmart._version)
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

function Walmart.EnsureCustomers(Handler, ...)
	for _, Customer in pairs(Players:GetPlayers()) do
		task.spawn(Handler, ..., Customer)
	end
end

function Walmart.GetStore(Address)
	return Walmart._stores[Address]
end

function Walmart._getTemplateFromAddress(address)
	for _, template in pairs(Walmart._templateStores) do
		if template.StoreIdentifier == address then
			return template
		end
	end
end

return Walmart
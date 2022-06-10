local Players = game:GetService("Players")
local ServerScriptService = game:GetService("ServerScriptService")

local Store = require(ServerScriptService.Source.Modules.Store)

local Walmart = {
	ShuttingDown = false,

	_version = 0, --// when version is updated, player profiles are overridden
	_stores = {},
	_template = {
		Money = 0,
	}
}

function Walmart.Start()
	game:BindToClose(Walmart.Stop)
end

function Walmart.Stop()
	Walmart.ShuttingDown = true
	Players.CharacterAutoLoads = false

	for _, store in pairs(Walmart._stores) do
		store:Close()
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

return Walmart
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local DataStoreService = game:GetService("DataStoreService")

local Knit = require(ReplicatedStorage.Packages.Knit)

local Maid = require(ReplicatedStorage.Source.Modules.Maid)
local Promise = require(ReplicatedStorage.Source.Modules.Promise)
local TableUtil = require(ReplicatedStorage.Source.Modules.TableUtil)

local Store = {}
Store.__class = "Store"
Store.__index = Store

function Store.new(Address, Walmart)
	local self = {
		Address = Address,
		Walmart = Walmart,

		_maid = Maid.new(),
		_jobs = {
			preSave = {},
			postSave = {},
		},

		_cache = {},
		_playerStore = {},
	}

	setmetatable(self, Store)

	self:Open()

	return self
end

function Store:Open()
	self.DataStore = DataStoreService:GetDataStore(self.Walmart.GetSlogan(self.Address))

	for _, customer in pairs(Players:GetPlayers()) do
		self._playerStore[customer.UserId] = customer
	end

	self._maid:GiveTask(Players.PlayerAdded:Connect(function(customer)
		self._playerStore[customer.UserId] = customer
	end))

	self._maid:GiveTask(Players.PlayerRemoving:Connect(function(customer)
		self:SaveCustomerProfile(customer)
		self:CustomerLeft(customer)

		self._playerStore[customer.UserId] = nil
	end))
end

function Store:Close()
	if #Players:GetPlayers() > 1 then
		self:SaveAllCustomerProfiles()
	end

	self._maid:DoCleaning()
end

function Store:Work(job, profile)
	local completed = 0
	local workers = 0

	for _, callback in pairs(self._jobs[job]) do
		task.spawn(function()
			callback(profile, self._playerStore[profile.UserId])
			completed += 1
		end)

		workers += 1
	end

	repeat
		task.wait()
	until completed >= workers
end

function Store:HireWorker(job, callback)
	if not self._jobs[job] then
		error("No event for Store @ " .. self.Address .. ": " .. job)
	end

	table.insert(self._jobs[job], callback)
end

function Store:HandleCustomerRequest(customer)
	if typeof(customer) == "Instance" then
		customer = customer.UserId
	end

	if type(customer) == "table" and getmetatable(customer).__class == "Customer" then
		customer = customer.UserId
	end

	return customer
end

function Store:GetCustomerProfile(customer)
	customer = self:HandleCustomerRequest(customer)

	if self._cache[customer] then
		return self._cache[customer]
	end

	local profile = self.DataStore:GetAsync(self:SolveCustomer(customer))

	if not profile then
		local storeStock = self.Walmart._storeStock[self.Address]

		if not storeStock then
			error("No store stock for Store @ " .. self.Address)
		end

		profile = TableUtil.Copy(storeStock)
	end

	self._cache[customer] = setmetatable(profile, {
		__class = "Customer",
		__index = {UserId = customer}
	})

	return profile
end

function Store:CustomerLeft(customer)
	customer = self:HandleCustomerRequest(customer)

	self._cache[customer] = nil
end

function Store:UpdateCustomerProfile(customer, updatedElements)
	customer = self:HandleCustomerRequest(customer)

	self._cache[customer] = TableUtil.Reconcile(self:GetCustomerProfile(customer), updatedElements)

	local player = self._playerStore[customer]
	if player then
		local WalmartService = Knit.GetService("WalmartService")
		WalmartService.Client.UpdateProfile:Fire(player, self.Address, self._cache[customer])
	end
end

function Store:SaveCustomerProfile(customer, tries)
	tries = tries or 1

	if tries >= 3 then
		warn("Failed to save player data after 3 tries.")

		--// TODO: Log important data to a discord channel / web server so we can recover player data.

		return
	end

	customer = self:HandleCustomerRequest(customer)

	if not self._cache[customer] then
		return --// already up-to-date
	end

	local cache = self._cache[customer]

	Promise.new(function(resolve)
		self:Work("preSave", cache)
		self.DataStore:SetAsync(self:SolveCustomer(customer), cache)
		self:Work("postSave", cache)

		resolve(true)
	end):catch(function(err)
		warn("Error saving customer profile for Store @ " .. self.Address .. ": " .. err)
		warn("Trying again...")

		self:SaveCustomerProfile(customer, tries + 1)
	end)
end

function Store:SolveCustomer(customer)
	customer = self:HandleCustomerRequest(customer)

	return string.format("Customer: %s", customer)
end

function Store:SaveAllCustomerProfiles()
	for customer, _ in pairs(self._cache) do
		self:SaveCustomerProfile(customer)
	end
end

return Store
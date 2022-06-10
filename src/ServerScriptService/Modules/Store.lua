local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local DataStoreService = game:GetService("DataStoreService")

local Maid = require(ReplicatedStorage.Source.Modules.Maid)
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

		_cache = {}
	}

	setmetatable(self, Store)

	self:Open()

	return self
end

function Store:Open()
	self.DataStore = DataStoreService:GetDataStore(self.Walmart.GetSlogan(self.Address))

	self._maid:GiveTask(Players.PlayerRemoving:Connect(function(customer)
		self:SaveCustomerProfile(customer)
		self:CustomerLeft(customer)
	end))
end

function Store:Close()
	self:SaveAllCustomerProfiles()
	self.DataStore:Destroy()
	self._maid:DoCleaning()
end

function Store:Work(job, profile)
	local completed = 0
	local workers = 0

	for _, callback in pairs(self._jobs[job]) do
		task.spawn(function()
			callback(profile)
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

	local profile = self.DataStore:GetAsync(customer)

	if not profile then
		profile = setmetatable(TableUtil.Copy(self.Walmart._template), {
			__class = "Customer",
			__index = {UserId = customer}
		})
	end

	self._cache[customer] = profile

	return profile
end

function Store:CustomerLeft(customer)
	customer = self:HandleCustomerRequest(customer)

	self._cache[customer] = nil
end

function Store:UpdateCustomerProfile(customer, updatedElements)
	customer = self:HandleCustomerRequest(customer)

	self._cache[customer] = TableUtil.Reconcile(self:GetCustomerProfile(customer), updatedElements)
end

function Store:SaveCustomerProfile(customer)
	customer = self:HandleCustomerRequest(customer)

	if not self._cache[customer] then
		return --// already up-to-date
	end

	self:Work("preSave", customer)
	self.DataStore:SetAsync(customer.UserId, self._cache[customer])
	self:Work("postSave", customer)
end

function Store:SaveAllCustomerProfiles()
	for customer, _ in pairs(self._cache) do
		self:SaveCustomerProfile(customer)
	end
end

return Store
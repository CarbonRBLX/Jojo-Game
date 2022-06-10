
local TableUtil = {}

function TableUtil.Copy(Table)
	local Copy = {}

	for Key, Value in pairs(Table) do
		Copy[Key] = Value
	end

	return Copy
end

function TableUtil.Reconcile(Table1, Table2)
	local Reconcile = TableUtil.Copy(Table1)

	for Key, Value in pairs(Table2) do
		Reconcile[Key] = Value
	end

	return Reconcile
end

return TableUtil
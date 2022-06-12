local ServerScriptService = game:GetService("ServerScriptService")

local Walmart = require(ServerScriptService.Source.Modules.Walmart)

local WalmartLoader = {}
WalmartLoader.Priority = 100 --// load before everything else

function WalmartLoader.Init()
    Walmart.Start()
end

return WalmartLoader
local pairs = pairs
local ipairs = ipairs
local lor = require("lor.index")



local multi_router = lor:Router()
local ostime = os.time()


multi_router:get("/abc", function(req, res, next)
    res:json({
    	success = true,
    	routerName = multi_router.name,
    	time = ostime
    })
end)

return multi_router


local pairs = pairs
local ipairs = ipairs
local lor = require("lor.index")
local errorRouter = lor:Router()


errorRouter:get("/", function(req, res, next)
    res:render("error", {
    	errMsg = req.query.errMsg -- injected by the invoke request
    })
end)


return errorRouter
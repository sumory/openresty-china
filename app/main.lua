local sfind = string.find
local lor = require("lor.index")
local config = require("app.config.config")
local reponse_time_middleware = require("app.middleware.response_time")
local powered_by_middleware = require("app.middleware.powered_by")
local session_middleware = require("lor.lib.middleware.session")
local check_login_middleware = require("app.middleware.check_login")
local uploader_middleware = require("app.middleware.uploader")
local router = require("app.router")
local whitelist = config.whitelist
local view_config = config.view_config
local upload_config = config.upload_config

local app = lor()

app:conf("view engine", view_config.engine)
app:conf("view ext", view_config.ext)
app:conf("views", view_config.views)

app:use(reponse_time_middleware({
    digits = 0,
    header = 'X-Response-Time',
    suffix = true
}))

app:use(session_middleware({
    secret = config.session_secret -- 必须修改此值
}))

-- filter: add response header
app:use(powered_by_middleware('Lor Framework'))

-- intercepter: login or not
app:use(check_login_middleware(whitelist))
-- uploader
app:use(uploader_middleware({
	dir = upload_config.dir
}))

router(app) -- business routers and routes

-- 404 error
app:use(function(req, res, next)
    if req:is_found() ~= true then
    	if sfind(req.headers["Accept"], "application/json") then
    		res:status(404):json({
    			success = false,
    			msg = "404! sorry, not found."
    		})
    	else
        	res:status(404):send("404! sorry, not found.")
        end
    end
end)

-- error handle middleware
app:erroruse(function(err, req, res, next)
	ngx.log(ngx.ERR, err)

	if sfind(req.headers["Accept"], "application/json") then
		res:status(500):json({
			success = false,
			msg = "500! unknown error."
		})
	else
    	res:status(500):send("unknown error")
    end
end)

app:run()
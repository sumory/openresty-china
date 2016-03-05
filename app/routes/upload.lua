local pairs = pairs
local ipairs = ipairs
local utils = require("app.libs.utils")
local lor = require("lor.index")
local user_model = require("app.model.user")
local topic_model = require("app.model.topic")
local upload_router = lor:Router()


upload_router:post("/avatar", function(req, res, next)
    local file = req.file or {}
    local userid = req.session.get("user").userid;
    
    if file.success and file.filename then 
        user_model:update_avatar(userid, file.filename)

        ngx.log(ngx.ERR, "用户:", userid, " 上传头像:", file.filename, " 成功")
        res:json({
        	success = true, 
	        originFilename = file.origin_filename,
	        filename = file.filename
	    })
    else
    	ngx.log(ngx.ERR, "用户:", userid, " 上传头像失败:", file.msg)
		res:json({
        	success = false, 
	        msg = file.msg
	    })
    end
end)


upload_router:post("/file", function(req, res, next)
    local file = req.file or {}
    local userid = req.session.get("user").userid;

    if file.success and file.filename then 
    	ngx.log(ngx.ERR, "用户:", userid, " 上传文件:", file.filename, " 成功")
        res:json({
        	success = true, 
	        originFilename = file.origin_filename,
	        filename = file.filename
	    })
    else
    	ngx.log(ngx.ERR, "用户:", userid, " 上传文件失败:", file.msg)
		res:json({
        	success = false, 
	        msg = file.msg
	    })
    end
end)


return upload_router

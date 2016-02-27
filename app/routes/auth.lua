local pairs = pairs
local ipairs = ipairs
local smatch = string.match
local ssub = string.sub
local slen = string.len
local cjson = require("cjson")
local utils = require("app.libs.utils")
local pwd_secret = require("app.config.config").pwd_secret
local lor = require("lor.index")
local user_model = require("app.model.user")
local auth_router = lor:Router()


auth_router:get("/login", function(req, res, next)
    res:render("login")
end)


auth_router:get("/sign_up", function(req, res, next)
    res:render("sign_up")
end)

auth_router:post("/sign_up", function(req, res, next)
    local username = req.body.username 
    local password = req.body.password

    local pattern = "^[a-zA-Z][0-9a-zA-Z_]+$"
    local match, err = smatch(username, pattern)

    if not username or not password or username == "" or password == "" then
        return res:json({
            success = false,
            msg = "用户名和密码不得为空."
        })
    end

    local username_len = slen(username)
    local password_len = slen(password)

    if username_len<4 or username_len>50 then
        return res:json({
            success = false,
            msg = "用户名长度应为4~50位."
        })
    end
    if password_len<6 or password_len>50 then
        return res:json({
            success = false,
            msg = "密码长度应为6~50位."
        })
    end

    if not match then
       return res:json({
            success = false,
            msg = "用户名只能输入字母、下划线、数字，必须以字母开头."
        })
    end

    local result, err = user_model:query_by_username(username)
    local isExist = false
    if result and not err then
        isExist = true
    end

    if isExist == true then
        return res:json({
            success = false,
            msg = "用户名已被占用，请修改."
        })
    else
        password = utils.encode(password .. "#" .. pwd_secret)
        local avatar = ssub(username, 1, 1) .. ".png" --取首字母作为默认头像名
        local result, err = user_model:new(username, password, avatar)
        if result and not err then
            return res:json({
                success = true,
                msg = "注册成功."
            })  
        else
            return res:json({
                success = false,
                msg = "注册失败."
            }) 
        end
    end
end)

auth_router:post("/login", function(req, res, next)
    local username = req.body.username 
    local password = req.body.password

    if not username or not password or username == "" or password == "" then
        return res:json({
            success = false,
            msg = "用户名和密码不得为空."
        })
    end

    local isExist = false
    local userid = 0

    password = utils.encode(password .. "#" .. pwd_secret)
    local result, err = user_model:query(username, password)

    local user = {}
    if result and not err then
        if result and #result == 1 then
            isExist = true
            user = result[1] 
            userid = user.id
        end
    else
        isExist = false
    end

    if isExist == true then
        req.session.set("user", {
            username = username,
            userid = userid,
            create_time = user.create_time or ""
        })
        return res:json({
            success = true,
            msg = "登录成功."
        })
    else
        return res:json({
            success = false,
            msg = "用户名或密码错误，请检查!"
        })
    end
end)


auth_router:get("/logout", function(req, res, next)
    res.locals.login = false
    res.locals.username = ""
    res.locals.userid = 0
    res.locals.create_time = ""
    req.session.destroy()
    res:redirect("/index")
end)


return auth_router


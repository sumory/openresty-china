local pairs = pairs
local ipairs = ipairs
local utils = require("app.libs.utils")
local lor = require("lor.index")
local topic_model = require("app.model.topic")
local collect_model = require("app.model.collect")
local like_model = require("app.model.like")
local topic_router = lor:Router()

local function isself(req, uid)
    local result = false

    if req and req.session and req.session.get("user") then
        local userid = req.session.get('user').userid
        if uid and userid and uid==userid then
            result= true
        end
    end

    return result
end

topic_router:get("/:topic_id/delete", function(req, res, next)
    local topic_id = req.params.topic_id
    local userid = req.session.get("user").userid

    if not userid then
        return res:json({
            success = false,
            msg = "删除文章之前请先登录."
        })
    end

    if not topic_id then
        return res:json({
            success = false,
            msg = "参数错误."
        })
    end

    local result = topic_model:delete(userid, topic_id)

    if result then
        res:json({
            success = true,
            msg = "删除文章成功"
        })
    else
        res:json({
            success = false,
            msg = "删除文章失败"
        })
    end

end)

topic_router:get("/:topic_id/view", function(req, res, next)
    local topic_id = req.params.topic_id

    res:render("topic/view", {
        topic = {
            id = topic_id
        }
    })
end)

topic_router:get("/:topic_id/query", function(req, res, next)
    local topic_id = req.params.topic_id

    if not topic_id then
        return res:json({
            success = false,
            msg = "要查询的文章id参数不能为空."
        })
    end

    local current_userid = req.session.get("user").userid
    local is_collect = false
    local is_like = false

    if current_userid and current_userid ~= 0 then
        is_collect = collect_model:is_collect(current_userid, topic_id)
        is_like = like_model:is_like(current_userid, topic_id)
    end

    -- topic_id must be number
    local result, err = topic_model:get(topic_id)
    
    if not result or err or type(result) ~= "table" or #result ~= 1 then
        return res:json({
            succes= false,
            msg = "无法查找到该文章."
        })
    else
        local topic = result[1]
        local is_self = isself(req, topic.user_id)
        res:json({
            success = true,
            data = {
                topic = topic,
                is_self = is_self,
                meta = {
                    is_collect = is_collect,
                    is_like = is_like
                }
            }   
        })
    end
end)


topic_router:get("/new", function(req, res, next)
    local diff_days, diff = utils.days_after_registry(req)
    if diff_days<3 then
        return res:render("error", {
            errMsg = "注册时间不到3天，不允许发布文章"
        })
    end
    res:render("topic/new")
end)


topic_router:post("/new", function(req, res, next)
    local diff_days, diff = utils.days_after_registry(req)
    if diff_days<3 then
        return res:json({
            success = false,
            msg = "注册时间不到3天，不允许发布文章"
        })
    end
    
    local category_id = req.body.category_id
    local title = req.body.title
    local content = req.body.content
    local user = req.session.get("user")
    local user_id = user.userid
    local user_name = user.username or ""

    if not user_id then
        return res:json({
            success = false,
            msg = "cann't create topic before login."
        })
    end

    if not title or not content or titile == "" or content == "" then
        res:json({
            success = false,
            msg = "title and content should not be empty"
        })
        return
    end

    local result, err = topic_model:new(title, content, user_id, user_name, category_id)
    if not result or err then
        res:json({
            success = false,
            msg = "save topic error"
        })
    else
        res:json({
            success = true,
            msg = "save success",
            data = {
                id = result.insert_id
            }
        })
    end
end)

topic_router:get("/:topic_id/edit", function(req, res, next)
    local topic_id = req.params.topic_id

    if not topic_id then
        res:render("error", {
            errMsg = "参数错误."
        })
    end

    local current_userid = req.session.get("user").userid
    if not current_userid or current_userid == 0 then
        res:render("error", {
            errMsg = "编辑文章前请先登录."
        })
    end

    -- topic_id must be number
    local result, err = topic_model:get_my_topic(current_userid, topic_id)
    if not result or err or type(result) ~= "table" or #result ~= 1 then
        res:render("error", {
            errMsg = "您要编辑的文章不存在或者您没有权限编辑."
        })
    else
        res:render("topic/edit",{
            topic = result[1]
        })
    end
end)

topic_router:post("/edit", function(req, res, next)
    local category_id = req.body.category_id
    local title = req.body.title
    local content = req.body.content
    local topic_id = req.body.topic_id

    local user = req.session.get("user")
    local user_id = user.userid

    if not topic_id then
        res:json({
            success = false,
            errMsg = "参数错误，要编辑的文章不存在."
        })
    end

    if not user_id then
        return res:json({
            success = false,
            msg = "编辑文章前请先登录."
        })
    end

    if not title or not content or titile == "" or content == "" then
        res:json({
            success = false,
            msg = "标题和内容不得为空"
        })
        return
    end

    local result, err = topic_model:update(topic_id, title, content, user_id, category_id)
    if not result or err then
        res:json({
            success = false,
            msg = "更新文章错误"
        })
    else
        res:json({
            success = true,
            msg = "更新文章成功",
            data = {
                id = topic_id
            }
        })
    end
end)

topic_router:post("/collect", function(req, res, next)
    local userid = req.session.get('user').userid
    if not userid then
        return res:json({
            success = false,
            msg = "login before update."
        })
    end

    local topic_id = req.body.topic_id
    local result = collect_model:collect(userid, topic_id)
    collect_model:reset_topic_collect_num(topic_id)

    if result then
        res:json({
            success = true,
            msg = "collect successfully."
        })
    else
        res:json({
            success = false,
            msg = "collect error."
        })
    end
end)

topic_router:post("/cancel_collect", function(req, res, next)
    local userid = req.session.get('user').userid
    if not userid then
        return res:json({
            success = false,
            msg = "login before update."
        })
    end

    local topic_id = req.body.topic_id
    local result = collect_model:cancel_collect(userid, topic_id)
    collect_model:reset_topic_collect_num(topic_id)

    if result then
        res:json({
            success = true,
            msg = "cancel collect successfully."
        })
    else
        res:json({
            success = false,
            msg = "cancel collect error."
        })
    end
end)

topic_router:post("/like", function(req, res, next)
    local userid = req.session.get('user').userid
    if not userid then
        return res:json({
            success = false,
            msg = "login before update."
        })
    end

    local topic_id = req.body.topic_id
    local result = like_model:like(userid, topic_id)
    like_model:reset_topic_like_num(topic_id)

    if result then
        res:json({
            success = true,
            msg = "like successfully."
        })
    else
        res:json({
            success = false,
            msg = "like error."
        })
    end
end)

topic_router:post("/cancel_like", function(req, res, next)
    local userid = req.session.get('user').userid
    if not userid then
        return res:json({
            success = false,
            msg = "login before update."
        })
    end

    local topic_id = req.body.topic_id
    local result = like_model:cancel_like(userid, topic_id)
    like_model:reset_topic_like_num(topic_id)

    if result then
        res:json({
            success = true,
            msg = "cancel like successfully."
        })
    else
        res:json({
            success = false,
            msg = "cancel like error."
        })
    end
end)


return topic_router

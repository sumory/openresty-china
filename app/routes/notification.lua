local pairs = pairs
local ipairs = ipairs
local utils = require("app.libs.utils")
local lor = require("lor.index")
local page_config = require("app.config.config").page_config
local notification_model = require("app.model.notification")
local notification_router = lor:Router()
local notification_page_size = page_config.notification_page_size

notification_router:get("/", function(req, res, next)
    res:render("user/notification")
end)


notification_router:get("/all", function(req, res, next)
    local page_no = req.query.page_no
    local n_type = req.query.n_type -- "all"/"unread"
    local page_size = notification_page_size
    local user_id = req.session.get("user").userid


    if not user_id then
        return res:json({
            success = false,
            msg = "查询通知之前请先登录."
        })
    end

    if not n_type or n_type=="" then
        n_type = "all"
    end

    local total_count = notification_model:get_total_count(user_id, n_type)
    local total_page = utils.total_page(total_count, page_size)
    local notifications = notification_model:get_all(user_id, n_type, page_no, page_size)

    res:json({
        success = true,
        data = {
            totalCount = total_count,
            totalPage = total_page,
            currentPage = page_no,
            notifications = notifications,
        }
    })
end)

notification_router:post("/mark", function(req, res, next)
    local user_id = req.session.get("user").userid

    if not user_id then
        return res:json({
            success = false,
            msg = "操作之前请先登录."
        })
    end

    local result = notification_model:update_status(user_id)
    if result then
        res:json({
            success = true,
            msg = "标记所有通知为已读成功"
        })
    else
        res:json({
            success = false,
            msg = "标记所有通知为已读失败"
        })
    end
end)

notification_router:post("/delete_all", function(req, res, next)
    local user_id = req.session.get("user").userid

    if not user_id then
        return res:json({
            success = false,
            msg = "操作之前请先登录."
        })
    end

    local result = notification_model:delete_all(user_id)
    if result then
        res:json({
            success = true,
            msg = "删除所有通知成功"
        })
    else
        res:json({
            success = false,
            msg = "删除所有通知失败"
        })
    end
end)

notification_router:post("/:notification_id/delete", function(req, res, next)
    local user_id = req.session.get("user").userid

    if not user_id then
        return res:json({
            success = false,
            msg = "操作之前请先登录."
        })
    end

    local id = req.params.notification_id
    if not id or id=="" then
        return res:json({
            success = false,
            msg = "参数错误."
        })
    end

    local result = notification_model:delete(id, user_id)
    if result then
        res:json({
            success = true,
            msg = "删除通知成功"
        })
    else
        res:json({
            success = false,
            msg = "删除通知失败"
        })
    end
end)

notification_router:get("/unread_count", function(req, res, next)
    local user_id = req.session.get("user").userid

    if not user_id then
        return res:json({
            success = false,
            msg = "操作之前请先登录."
        })
    end

    local total_count = notification_model:get_total_count(user_id, "unread")
    res:json({
        success = true,
        data = {
            count = total_count
        }
    })
end)

return notification_router
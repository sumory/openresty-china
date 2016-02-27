local type = type
local utils = require("app.libs.utils")
local user_model = require("app.model.user")
local topic_model = require("app.model.topic")
local comment_model = require("app.model.comment")
local common_router = {}

local function topics_category_handler(current_category, req, res, next)
	local comment_count = comment_model:get_total_count()
    local topic_count = topic_model:get_all_count()
    local user_count = user_model:get_total_count()

    local diff_days, diff = utils.days_after_registry(req)

    res:render("index", {
    	diff_days = diff_days,
    	diff = diff,
        user_count = user_count,
        topic_count = topic_count,
        comment_count = comment_count,
        current_category = current_category
    })
end

common_router.settings = function(req, res, next)
	local user_id = req.session.get("user").userid
	if not user_id or user_id == 0 then
		return res:render("error", {
			errMsg = "cannot find user, please login."
		})
	end

	local result, err = user_model:query_by_id(user_id)
	if not result or err then
		return res:render("error", {
			errMsg = "error to find user."
		})
	end

    res:render("user/settings", {
        user = result
    })
end

common_router.index = function(req, res, next)
	local current_category = 0
    topics_category_handler(current_category, req, res, next)
end

common_router.share = function(req, res, next)
	local current_category = 1
    topics_category_handler(current_category, req, res, next)
end

common_router.ask = function(req, res, next)
	local current_category = 2
     topics_category_handler(current_category, req, res, next)
end

common_router.about = function(req, res, next)
    res:render("about")
end


return common_router
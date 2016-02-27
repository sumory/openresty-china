local pairs = pairs
local ipairs = ipairs
local lor = require("lor.index")
local user_model = require("app.model.user")
local topic_model = require("app.model.topic")
local comment_model = require("app.model.comment")
local category_router = lor:Router()


category_router:get("/:category_id", function(req, res, next)
	local current_category = req.params.category_id

	if current_category == "1" then
		return res:redirect("/share")
	elseif current_category == "2" then
		return res:redirect("/ask")
	end

    local comment_count = comment_model:get_total_count()
    local topic_count = topic_model:get_all_count()
    local user_count = user_model:get_total_count()
    res:render("index", {
		user_count = user_count,
		topic_count = topic_count,
		comment_count = comment_count,
		current_category = current_category
    })
end)



return category_router

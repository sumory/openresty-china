local pairs = pairs
local ipairs = ipairs
local smatch = string.match
local slen = string.len
local utils = require("app.libs.utils")
local pwd_secret = require("app.config.config").pwd_secret
local lor = require("lor.index")
local user_model = require("app.model.user")
local topic_model = require("app.model.topic")
local collect_model = require("app.model.collect")
local comment_model = require("app.model.comment")
local follow_model = require("app.model.follow")
local notification_model = require("app.model.notification")
local user_router = lor:Router()

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

local function get_relation(id1, id2, flag)
    local relation = 0
    local is_follow = false
    local is_fan = false
    id1=tonumber(id1)
    id2=tonumber(id2)

    local relations = follow_model:get_relation(id1, id2)
    for i, v in ipairs(relations) do
        if v.from_id == id1 and v.to_id == id2 then
            is_follow = true
        elseif v.from_id == id2 and v.to_id == id1 then
            is_fan = true
        end
    end

    if is_follow and is_fan then
        relation = 3 -- 好友
    elseif is_follow and not is_fan then
        relation = 1 -- 我关注了这个人
    elseif not is_follow and is_fan then
        relation = 2 -- 这个人关注了我
    end

    return relation
end

-- user index page start
user_router:get("/:username/index", function(req, res, next)
    local current_userid = req.session.get("user").userid;

    local username = req.params.username
	if not username or username == "" then
		return res:render("error", {
            errMsg = "参数错误."
        })
	end

    -- 查看的用户
	local result, err = user_model:query_by_username(username)
	if not result or err then
		return res:render("error", {
            errMsg = "无法查找到用户."
        })
	end

	local user = result
    local user_id = user.id

    -- 粉丝、关注、文章数
	local follows_count = follow_model:get_follows_count(user_id)
	local fans_count = follow_model:get_fans_count(user_id)
	local topics_count = topic_model:get_total_count_of_user(user_id)

    local is_self = false 
    local relation = 0

    if current_userid and current_userid ~= 0 then
        is_self = (current_userid == user_id)    
        relation = get_relation(current_userid, user_id)
    end

    res:render("user/index", {
        is_self = is_self,
        relation = relation,
        user = user,
        follows_count = follows_count,
        fans_count = fans_count,
        topics_count = topics_count
    })
end)

user_router:get("/:username/topics", function(req, res, next)
    local username = req.params.username
	if not username or username == "" then
		return res:json({
            success = false,
            msg = "参数错误."
        })
	end

	local result, err = user_model:query_by_username(username)
	if not result or err then
		return res:json({
            success = false,
            msg = "无法查找到用户."
        })
	end

	local user = result

	local page_no = req.query.page_no
    local page_size = 20
    local total_count = topic_model:get_total_count_of_user(user.id)
    local total_page = utils.total_page(total_count, page_size)
    local topics = topic_model:get_all_of_user(user.id, page_no, page_size)

    local is_self = isself(req, user.id)

    res:json({
        success = true,
        data = {
            totalCount = total_count,
            totalPage = total_page,
            currentPage = page_no,
            topics = topics,
            is_self = is_self
        }
    })
end)

user_router:get("/:username/comments", function(req, res, next)
    local username = req.params.username


    if not username or username == "" then
        return res:json({
            success = false,
            msg = "参数错误."
        })
    end

    local result, err = user_model:query_by_username(username)
    if not result or err then
        return res:json({
            success = false,
            msg = "无法查找到用户."
        })
    end

    local user = result

    local page_no = req.query.page_no
    local page_size = 20
    local total_count = comment_model:get_total_count_of_user(user.id)
    local total_page = utils.total_page(total_count, page_size)
    local comments = comment_model:get_all_of_user(user.id, page_no, page_size)
    local is_self = isself(req, user.id)



    res:json({
        success = true,
        data = {
            totalCount = total_count,
            totalPage = total_page,
            currentPage = page_no,
            comments = comments,
            is_self = is_self
        }
    })
end)


user_router:get("/:username/collects", function(req, res, next)
    local username = req.params.username
	if not username or username == "" then
		return res:json({
            success = false,
            msg = "参数错误."
        })
	end

	local result, err = user_model:query_by_username(username)
	if not result or err then
		return res:json({
            success = false,
			msg = "无法查找到用户."
		})
	end

	local user = result

	local page_no = req.query.page_no
    local page_size = 20
    local total_count = collect_model:get_total_count_of_user(user.id)
    local total_page = utils.total_page(total_count, page_size)
    local topics = collect_model:get_all_of_user(user.id, page_no, page_size)

    res:json({
        success = true,
        data = {
            totalCount = total_count,
            totalPage = total_page,
            currentPage = page_no,
            topics = topics
        }
    })
end)

user_router:get("/:username/follows", function(req, res, next)
    local username = req.params.username
    if not username or username == "" then
        return res:json({
            success = false,
            msg = "参数错误."
        })
    end

    local result, err = user_model:query_by_username(username)
    if not result or err then
        return res:json({
            success = false,
            msg = "无法查找到用户."
        })
    end

    local user = result

    local page_no = req.query.page_no
    local page_size = 20
    local total_count = follow_model:get_follows_count(user.id)
    local total_page = utils.total_page(total_count, page_size)
    local users = follow_model:get_follows_of_user(user.id, page_no, page_size)
    
    res:json({
        success = true,
        data = {
            totalCount = total_count,
            totalPage = total_page,
            currentPage = page_no,
            users = users
        }
    })
end)

user_router:get("/:username/fans", function(req, res, next)
    local username = req.params.username
    if not username or username == "" then
        return res:json({
            success = false,
            msg = "参数错误."
        })
    end

    local result, err = user_model:query_by_username(username)
    if not result or err then
        return res:json({
            success = false,
            msg = "无法查找到用户."
        })
    end

    local user = result

    local page_no = req.query.page_no
    local page_size = 20
    local total_count = follow_model:get_fans_count(user.id)
    local total_page = utils.total_page(total_count, page_size)
    local users = follow_model:get_fans_of_user(user.id, page_no, page_size)
    
    res:json({
        success = true,
        data = {
            totalCount = total_count,
            totalPage = total_page,
            currentPage = page_no,
            users = users
        }
    })
end)

user_router:get("/:username/hot_topics", function(req, res, next)
    local username = req.params.username
    if not username or username == "" then
        return res:json({
            success = false,
            msg = "参数错误."
        })
    end

    local result, err = user_model:query_by_username(username)
    if not result or err then
        return res:json({
            success = false,
            msg = "无法查找到用户."
        })
    end

    local user = result

    local page_no = req.query.page_no
    local page_size = 15
    local total_count = topic_model:get_total_hot_count_of_user(user.id)
    local total_page = utils.total_page(total_count, page_size)
    local topics = topic_model:get_all_hot_of_user(user.id, page_no, page_size)

    res:json({
        success = true,
        data = {
            totalCount = total_count,
            totalPage = total_page,
            currentPage = page_no,
            topics = topics
        }
    })
end)

user_router:get("/:username/like_topics", function(req, res, next)
    local username = req.params.username
    if not username or username == "" then
        return res:json({
            success = false,
            msg = "参数错误."
        })
    end

    local result, err = user_model:query_by_username(username)
    if not result or err then
        return res:json({
            success = false,
            msg = "无法查找到用户."
        })
    end

    local user = result

    local page_no = req.query.page_no
    local page_size = 15
    local total_count = topic_model:get_total_like_count_of_user(user.id)
    local total_page = utils.total_page(total_count, page_size)
    local topics = topic_model:get_all_like_of_user(user.id, page_no, page_size)

    res:json({
        success = true,
        data = {
            totalCount = total_count,
            totalPage = total_page,
            currentPage = page_no,
            topics = topics
        }
    })
end)

-- user index page stop



-- user setting page start
user_router:post("/edit", function(req, res, next)
    local userid = req.session.get('user').userid
    if not userid then
        return res:json({
            success = false,
            msg = "编辑前请先登录."
        })
    end

    local email = req.body.email
    local email_public = req.body.email_public
    local city = req.body.city
    local company = req.body.company
    local github = req.body.github
    local website = req.body.website
    local sign = req.body.sign

    local success = user_model:update(tonumber(userid), email, email_public, city, company, github, website, sign)

    if success then
        res:json({
            success = true,
            msg = "编辑成功."
        })
    else
        res:json({
            success = false,
            msg = "编辑失败."
        })
    end
end)

user_router:post("/change_pwd", function(req, res, next)
    local userid = req.session.get('user').userid
    if not userid then
        return res:json({
            success = false,
            msg = "更改密码前请先登录."
        })
    end

    local old_pwd = req.body.old_pwd
    local new_pwd = req.body.new_pwd

    local password_len = slen(new_pwd)
    if password_len<6 or password_len>50 then
        return res:json({
            success = false,
            msg = "密码长度应为6~50位."
        })
    end

    local user, err = user_model:query_by_id(userid)
    if not user or err then
       return res:json({
            success = false,
            msg = "无法查找到该用户."
        })
    end  


    if  not user.password or utils.encode(old_pwd .. "#" .. pwd_secret)~=user.password then
        return res:json({
            success = false,
            msg = "输入的当前密码不正确."
        })
    end

    new_pwd = utils.encode(new_pwd .. "#" .. pwd_secret)
    local success = user_model:update_pwd(tonumber(userid), new_pwd)

    if success then
        res:json({
            success = true,
            msg = "更改密码成功."
        })
    else
        res:json({
            success = false,
            msg = "更改密码错误."
        })
    end
end)
-- user setting page stop



-- user relation start
user_router:post("/follow", function(req, res, next)
    local userid = req.session.get('user').userid
    if not userid then
        return res:json({
            success = false,
            msg = "操作前请先登录."
        })
    end

    local to_id = req.body.to_id

    local result = follow_model:follow(userid, to_id)
    local relation = get_relation(userid, to_id, true)
    
    -- 粉丝、关注
    local follows_count = follow_model:get_follows_count(to_id)
    local fans_count = follow_model:get_fans_count(to_id)

    if result then
        notification_model:follow_notify(userid, to_id)
        res:json({
            success = true,
            msg = "关注成功.",
            data = {
                relation = relation,
                follows_count = follows_count,
                fans_count = fans_count
            }
        })
    else
        res:json({
            success = false,
            msg = "关注失败."
        })
    end
end)

user_router:post("/cancel_follow", function(req, res, next)
    local userid = req.session.get('user').userid
    if not userid then
        return res:json({
            success = false,
            msg = "操作前请先登录."
        })
    end

    local to_id = req.body.to_id

    local result = follow_model:cancel_follow(userid, to_id)
    local relation = get_relation(userid, to_id)

    -- 粉丝、关注
    local follows_count = follow_model:get_follows_count(to_id)
    local fans_count = follow_model:get_fans_count(to_id)

    if result then
        res:json({
            success = true,
            msg = "取消关注成功.",
            data = {
                relation = relation,
                follows_count = follows_count,
                fans_count = fans_count
            }
        })
    else
        res:json({
            success = false,
            msg = "取消关注失败."
        })
    end
end)


-- user relation stop

return user_router

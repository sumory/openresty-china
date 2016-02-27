local DB = require("app.libs.db")
local db = DB:new()

local notification_model = {}


function notification_model:get_all(user_id, n_type, page_no, page_size)
	user_id = tonumber(user_id)
	page_no = tonumber(page_no)
	page_size = tonumber(page_size)
	if page_no < 1 then 
		page_no = 1
	end

	if n_type == "all" then
		return db:query("select n.*, u.username as from_username, u.avatar as avatar,u.username as username, t.title as topic_title, c.id as comment_id, c.content as comment_content  ".. 
			" from notification n " .. 
			" left join user u on n.from_id=u.id " ..
			" left join topic t on n.topic_id=t.id " ..
			" left join comment c on n.comment_id=c.id " ..
			" where n.user_id = ?" .. 
			" order by id desc limit ?,?", {user_id, (page_no - 1) * page_size, page_size})
	elseif n_type == "unread" then
		return db:query("select n.*, u.username as from_username, u.avatar as avatar,u.username as username, t.title as topic_title, c.id as comment_id, c.content as comment_content  ".. 
			" from notification n " .. 
			" left join user u on n.from_id=u.id " ..
			" left join topic t on n.topic_id=t.id " ..
			" left join comment c on n.comment_id=c.id " ..
			" where n.user_id = ? and n.status=0 " .. 
			" order by id desc limit ?,?", {user_id, (page_no - 1) * page_size, page_size})
	end

	
end

function notification_model:get_total_count(user_id, n_type)
	local res, err 

	if n_type == "all" then
		res, err = db:query("select count(n.id) as n_count " ..
			" from notification n " .. 
			" left join user u on n.from_id=u.id " ..
			" left join topic t on n.topic_id=t.id " ..
			" left join comment c on n.comment_id=c.id " ..
			" where n.user_id =?", {tonumber(user_id)})
	elseif n_type == "unread" then
		res, err = db:query("select count(n.id) as n_count " ..
			" from notification n " .. 
			" left join user u on n.from_id=u.id " ..
			" left join topic t on n.topic_id=t.id " ..
			" left join comment c on n.comment_id=c.id " ..
			" where n.user_id =? and n.status=0", {tonumber(user_id)})
	end

	if err or not res or #res~=1 or not res[1].n_count then
   		return 0
   	else
   		return res[1].n_count
   	end
end


-- 评论了某个人的文章
function notification_model:comment_notify(from_id, content, topic_id, comment_id)
	local res, err = db:query("select user_id from topic where id=?", {tonumber(topic_id)})
	if res and not err and #res == 1 then
		local user_id = res[1].user_id
		db:query("insert into notification(user_id, from_id, type, content, topic_id, comment_id) values(?,?,?,?,?,?)",
            {tonumber(user_id), tonumber(from_id), 0, content, tonumber(topic_id), tonumber(comment_id)})
	end
end

-- 评论文章的时候提及了某个人
function notification_model:comment_mention(user_id, from_id, content, topic_id, comment_id)
	return db:query("insert into notification(user_id, from_id, type, content, topic_id, comment_id) values(?,?,?,?,?,?)",
            {tonumber(user_id), tonumber(from_id), 1, content, tonumber(topic_id), tonumber(comment_id)})
end

-- 关注了某人
function notification_model:follow_notify(from_id, user_id)
	db:query("insert into notification(user_id, from_id, type, content) values(?,?,?,?)",
            {tonumber(user_id), tonumber(from_id), 2, ""})
end



-- 全部标记为已读
function notification_model:update_status(user_id)
	local res, err = db:query("update notification set status = ? where user_id=?", {1, tonumber(user_id)})
	if res and not err then
		return true
	else
		return false
	end
end

-- 删除所有通知
function notification_model:delete_all(user_id)
	local res, err = db:query("delete from notification where user_id=?", {tonumber(user_id)})
	if res and not err then
		return true
	else
		return false
	end
end

-- 删除某条通知
function notification_model:delete(id, user_id)
	local res, err = db:query("delete from notification where id=? and user_id=?", {tonumber(id), tonumber(user_id)})
	if res and not err then
		return true
	else
		return false
	end
end

return notification_model
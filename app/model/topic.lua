local utils = require("app.libs.utils")
local DB = require("app.libs.db")
local db = DB:new()

local topic_model = {}

function topic_model:delete(user_id, topic_id)
    local res, err = db:query("delete from topic where id=? and user_id=?",
            {tonumber(topic_id), tonumber(user_id)})
    if res and not err then
    	return true
    else
    	return false
    end
end

function topic_model:new(title, content, user_id, user_name, category_id)
	local now = utils.now()
    return db:query("insert into topic(title, content, user_id, user_name, category_id, create_time) values(?,?,?,?,?,?)",
            {title, content, tonumber(user_id), user_name, tonumber(category_id), now})
end

function topic_model:update(topic_id, title, content, user_id, category_id)
	local now = utils.now()
    return db:query("update topic set title=?, content=?, category_id=?, update_time=? where id=? and user_id=?",
            {title, content,  tonumber(category_id), now, tonumber(topic_id), tonumber(user_id)})
end

function topic_model:get_my_topic(user_id, id)
    return db:query("select t.*, u.avatar as avatar, c.name as category_name from topic t "..
    	" left join user u on t.user_id=u.id " .. 
    	" left join category c on t.category_id=c.id " ..
    	" where t.id=? and user_id=?", {tonumber(id),tonumber(user_id)})
end


function topic_model:get(id)
	db:query("update topic set view_num=view_num+1 where id=?", {tonumber(id)})
    return db:query("select t.*, u.avatar as avatar, c.name as category_name from topic t "..
    	" left join user u on t.user_id=u.id " .. 
    	" left join category c on t.category_id=c.id " ..
    	" where t.id=?", {tonumber(id)})
end


function topic_model:get_all(topic_type, category, page_no, page_size)
	page_no = tonumber(page_no)
	page_size = tonumber(page_size)
	category = tonumber(category)
	if page_no < 1 then 
		page_no = 1
	end

	local res, err 

	if category ~= 0 then
		if topic_type == "default" then
			res, err = db:query("select t.*, c.name as category_name, u.avatar as avatar from topic t " .. 
				" left join user u on t.user_id=u.id " ..
				" left join category c on t.category_id=c.id " ..
				" where t.category_id=? " ..
				" order by t.id desc limit ?,?",
				{category, (page_no - 1) * page_size, page_size})
		elseif topic_type == "recent-reply" then
			res, err = db:query("select t.*, c.name as category_name, u.avatar as avatar from topic t " .. 
				" left join user u on t.user_id=u.id " ..
				" left join category c on t.category_id=c.id " ..
				" where t.category_id=? " ..
				" order by t.last_reply_time desc limit ?,?",
				{category, (page_no - 1) * page_size, page_size})
		elseif topic_type == "good" then
			res, err = db:query("select t.*, c.name as category_name, u.avatar as avatar from topic t " .. 
				" left join user u on t.user_id=u.id " ..
				" left join category c on t.category_id=c.id " ..
				" where t.is_good=1 and t.category_id=? " ..
				" order by t.id desc limit ?,?",
				{category, (page_no - 1) * page_size, page_size})
		elseif topic_type == "noreply" then
			res, err = db:query("select t.*, c.name as category_name, u.avatar as avatar from topic t" .. 
				" left join user u on t.user_id=u.id " ..
				" left join category c on t.category_id=c.id " ..
				" where t.reply_num=0 and t.category_id=? " ..
				" order by t.id desc limit ?,?",
				{category, (page_no - 1) * page_size, page_size})
		end
	else
		if topic_type == "default" then
			res, err = db:query("select t.*, c.name as category_name, u.avatar as avatar from topic t " .. 
				" left join user u on t.user_id=u.id " ..
				" left join category c on t.category_id=c.id " ..
				" order by t.id desc limit ?,?",
				{(page_no - 1) * page_size, page_size})
		elseif topic_type == "recent-reply" then
			res, err = db:query("select t.*, c.name as category_name, u.avatar as avatar from topic t " .. 
				" left join user u on t.user_id=u.id " ..
				" left join category c on t.category_id=c.id " ..
				" order by t.last_reply_time desc limit ?,?",
				{(page_no - 1) * page_size, page_size})
		elseif topic_type == "good" then
			res, err = db:query("select t.*, c.name as category_name, u.avatar as avatar from topic t " .. 
				" left join user u on t.user_id=u.id " ..
				" left join category c on t.category_id=c.id " ..
				" where t.is_good=1" ..
				" order by t.id desc limit ?,?",
				{(page_no - 1) * page_size, page_size})
		elseif topic_type == "noreply" then
			res, err = db:query("select t.*, c.name as category_name, u.avatar as avatar from topic t" .. 
				" left join user u on t.user_id=u.id " ..
				" left join category c on t.category_id=c.id " ..
				" where t.reply_num=0 " ..
				" order by t.id desc limit ?,?",
				{(page_no - 1) * page_size, page_size})
		end
	end

	if not res or err or type(res) ~= "table" or #res <= 0 then
		return {}
	else
		return res
	end
end


function topic_model:get_total_count(topic_type, category)
	local res, err 
	category = tonumber(category)

	if category ~= 0 then
		if not topic_type or topic_type == "default" then
			res, err =  db:query("select count(id) as c from topic where category_id=?", {category})
		elseif topic_type == "recent-reply" then
			res, err =  db:query("select count(id) as c from topic where category_id=?", {category})
		elseif topic_type == "good" then
			res, err =  db:query("select count(id) as c from topic where is_good=1 and category_id=?", {category})
		elseif topic_type == "noreply" then
			res, err =  db:query("select count(id) as c from topic where reply_num=0 and category_id=?", {category})
		end
	else
		if not topic_type or topic_type == "default" then
			res, err =  db:query("select count(id) as c from topic")
		elseif topic_type == "recent-reply" then
			res, err =  db:query("select count(id) as c from topic")
		elseif topic_type == "good" then
			res, err =  db:query("select count(id) as c from topic where is_good=1")
		elseif topic_type == "noreply" then
			res, err =  db:query("select count(id) as c from topic where reply_num=0")
		end
	end

	if err or not res or #res~=1 or not res[1].c then
   		return 0
   	else
   		return res[1].c
   	end
end

function topic_model:get_all_count()
	local res, err = db:query("select count(id) as c from topic")

	if err or not res or #res~=1 or not res[1].c then
   		return 0
   	else
   		return res[1].c
   	end
end

function topic_model:get_all_of_user(user_id, page_no, page_size)
	page_no = tonumber(page_no)
	page_size = tonumber(page_size)
	if page_no < 1 then 
		page_no = 1
	end
	local res, err = db:query("select t.*, u.avatar as avatar, c.name as category_name  from topic t " .. 
		" left join user u on t.user_id=u.id " .. 
		" left join category c on t.category_id=c.id " ..
		" where t.user_id=? order by t.id desc limit ?,?",
		{tonumber(user_id), (page_no - 1) * page_size, page_size})

	if not res or err or type(res) ~= "table" or #res <= 0 then
		return {}
	else
		return res
	end
end

function topic_model:get_total_count_of_user(user_id)
	local res, err = db:query("select count(id) as c from topic where user_id=?", {tonumber(user_id)})
	if err or not res or #res~=1 or not res[1].c then
   		return 0
   	else
   		return res[1].c
   	end
end



function topic_model:get_all_hot_of_user(user_id, page_no, page_size)
	page_no = tonumber(page_no)
	page_size = tonumber(page_size)
	if page_no < 1 then 
		page_no = 1
	end
	local res, err = db:query("select t.*, u.avatar as avatar, c.name as category_name  from topic t " .. 
		" left join user u on t.user_id=u.id " .. 
		" left join category c on t.category_id=c.id " ..
		" where t.user_id=? order by t.reply_num desc, like_num desc limit ?,?",
		{tonumber(user_id), (page_no - 1) * page_size, page_size})

	if not res or err or type(res) ~= "table" or #res <= 0 then
		return {}
	else
		return res
	end
end

function topic_model:get_total_hot_count_of_user(user_id)
	local res, err = db:query("select count(id) as c from topic where user_id=?", {tonumber(user_id)})
	if err or not res or #res~=1 or not res[1].c then
   		return 0
   	else
   		return res[1].c
   	end
end


function topic_model:get_all_like_of_user(user_id, page_no, page_size)
	page_no = tonumber(page_no)
	page_size = tonumber(page_size)
	if page_no < 1 then 
		page_no = 1
	end
	local res, err = db:query("select t.*, u.avatar as avatar, c.name as category_name  from `like` l " .. 
		" right join topic t on t.id=l.topic_id " ..
		" left join user u on t.user_id=u.id " .. 
		" left join category c on t.category_id=c.id " ..
		" where l.user_id=? order by l.id desc limit ?,?",
		{tonumber(user_id), (page_no - 1) * page_size, page_size})

	if not res or err or type(res) ~= "table" or #res <= 0 then
		return {}
	else
		return res
	end
end

function topic_model:get_total_like_count_of_user(user_id)
	local res, err = db:query("select count(l.id) as c from `like` l " .. 
		" right join topic t on l.topic_id=t.id " .. 
		" where l.user_id=?", {tonumber(user_id)})
	if err or not res or #res~=1 or not res[1].c then
   		return 0
   	else
   		return res[1].c
   	end
end


function topic_model:reset_last_reply(topic_id, user_id, user_name) -- 更新最后回复人
	local now = utils.now()
	db:query("update topic set last_reply_id=?, last_reply_name=?, last_reply_time=? where id=?", 
		{tonumber(topic_id), user_name, now, tonumber(topic_id)})
end

return topic_model
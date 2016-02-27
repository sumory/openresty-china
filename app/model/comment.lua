local DB = require("app.libs.db")
local db = DB:new()

local comment_model = {}

function comment_model:delete(user_id, comment_id)
    local res, err = db:query("delete from comment where id=? and user_id=?",
            {tonumber(comment_id), tonumber(user_id)})
    if res and not err then
    	return true
    else
    	return false
    end
end

function comment_model:new(topic_id,  user_id, content)
    return db:query("insert into comment(topic_id,user_id, content) values(?,?,?)",
            {tonumber(topic_id), tonumber(user_id), content})
end

function comment_model:query(comment_id)
	comment_id = tonumber(comment_id)
	if not comment_id or comment_id == 0 then
		return {}
	end


	local res, err = db:query("select c.*, u.avatar as avatar, u.username as user_name from comment c " ..
		" left join user u on c.user_id=u.id " .. 
		" where c.id=?",
		{comment_id})

	if not res or err or type(res) ~= "table" or #res <= 0 then
		return {}
	else
		return res[1]
	end
end


function comment_model:get_all_of_user(user_id, page_no, page_size)
	page_no = tonumber(page_no)
	page_size = tonumber(page_size)
	if page_no < 1 then 
		page_no = 1
	end
	local res, err = db:query("select t.id as topic_id, t.title as topic_title, c.content as comment_content,c.id as comment_id, c.create_time as comment_time from comment c" ..
		" right join topic t on c.topic_id=t.id" ..
		" where c.user_id=? order by c.id desc limit ?,?",
		{tonumber(user_id), (page_no - 1) * page_size, page_size})

	if not res or err or type(res) ~= "table" or #res <= 0 then
		return {}
	else
		return res
	end
end

function comment_model:get_total_count_of_user(user_id)
	local res, err = db:query("select count(c.id) as comment_count from comment c " .. 
		" right join topic t on c.topic_id=t.id" .. 
		" where c.user_id=?", {tonumber(user_id)})


	if err or not res or #res~=1 or not res[1].comment_count then
   		return 0
   	else
   		return res[1].comment_count
   	end
end

function comment_model:get_total_count()
	local res, err = db:query("select count(c.id) as comment_count from comment c ")


	if err or not res or #res~=1 or not res[1].comment_count then
   		return 0
   	else
   		return res[1].comment_count
   	end
end




function comment_model:get_total_count_of_topic(topic_id)
	topic_id = tonumber(topic_id)
	if not topic_id or topic_id == 0 then
		return 0
	end

	local res, err = db:query("select count(id) as c from comment where topic_id=?", {topic_id})

	if err or not res or #res~=1 or not res[1].c then
   		return 0
   	else
   		return res[1].c
   	end
end

function comment_model:get_all_of_topic(topic_id, page_no, page_size)
	topic_id = tonumber(topic_id)
	if not topic_id or topic_id == 0 then
		return 0
	end

	page_no = tonumber(page_no)
	page_size = tonumber(page_size)
	if page_no < 1 then 
		page_no = 1
	end
	local res, err = db:query("select c.*, u.avatar as avatar, u.username as user_name from comment c " ..
		" left join user u on c.user_id=u.id " .. 
		" where c.topic_id=? order by c.id asc limit ?,?",
		{topic_id, (page_no - 1) * page_size, page_size})

	if not res or err or type(res) ~= "table" or #res <= 0 then
		return {}
	else
		return res
	end
end

function comment_model:reset_topic_comment_num(topic_id)
	db:query("update topic set reply_num=(select count(id) from comment where topic_id=?) where id=?", 
		{tonumber(topic_id), tonumber(topic_id)})
end

return comment_model
local DB = require("app.libs.db")
local db = DB:new()

local collect_model = {}


function collect_model:get_all_of_user(user_id, page_no, page_size)
	page_no = tonumber(page_no)
	page_size = tonumber(page_size)
	if page_no < 1 then 
		page_no = 1
	end
	local res, err = db:query("select t.*, u.avatar as avatar, cc.name as category_name from collect c" ..
		" right join topic t on c.topic_id=t.id" ..
		" left join user u on t.user_id=u.id" ..
      " left join category cc on t.category_id=cc.id " ..
		" where c.user_id=? order by c.id desc limit ?,?",
		{tonumber(user_id), (page_no - 1) * page_size, page_size})

	if not res or err or type(res) ~= "table" or #res <= 0 then
		return {}
	else
		return res
	end
end

function collect_model:get_total_count_of_user(user_id)
	local res, err = db:query("select count(c.id) as collect_count from collect c " .. 
		" right join topic t on c.topic_id=t.id" .. 
		" where c.user_id=?", {tonumber(user_id)})
	if err or not res or #res~=1 or not res[1].collect_count then
   		return 0
   	else
   		return res[1].collect_count
   	end
end

function collect_model:is_collect(current_userid, topic_id)
	current_userid = tonumber(current_userid)
	topic_id = tonumber(topic_id)

	local res, err = db:query("select count(c.id) as c from collect c " .. 
		" where c.user_id=? and c.topic_id=?", {current_userid, topic_id})
	if err or not res or (#res>=1 and tonumber(res[1].c)<1) then
   		return false
   	else
   		return true
   	end
end


function collect_model:collect(user_id, topic_id)
   local res, err =  db:query("insert into collect (user_id,topic_id) values(?,?) ON DUPLICATE KEY UPDATE create_time=CURRENT_TIMESTAMP ", 
      {tonumber(user_id), tonumber(topic_id)})
      if err or not res then
         return false
      else
         return true
      end
end

function collect_model:cancel_collect(user_id, topic_id)
   local res, err =  db:query("delete from collect where user_id=? and topic_id=?", 
      {tonumber(user_id), tonumber(topic_id)})
      if err or not res then
         return false
      else
         return true
      end
end

function collect_model:reset_topic_collect_num(topic_id)
	db:query("update topic set collect_num=(select count(id) from collect where topic_id=?) where id=?", 
		{tonumber(topic_id), tonumber(topic_id)})
end


function collect_model:like(user_id, topic_id)
   local res, err =  db:query("insert into like (user_id,topic_id) values(?,?) ON DUPLICATE KEY UPDATE create_time=CURRENT_TIMESTAMP ", 
      {tonumber(user_id), tonumber(topic_id)})
      if err or not res then
         return false
      else
         return true
      end
end

function collect_model:cancel_like(user_id, topic_id)
   local res, err =  db:query("delete from like where user_id=? and topic_id=?", 
      {tonumber(user_id), tonumber(topic_id)})
      if err or not res then
         return false
      else
         return true
      end
end

function collect_model:reset_topic_like_num(topic_id)
	db:query("update topic set like_num=(select count(id) from like where topic_id=?) where id=?", 
		{tonumber(topic_id), tonumber(topic_id)})
end

return collect_model
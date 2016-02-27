local DB = require("app.libs.db")
local db = DB:new()

local like_model = {}

function like_model:is_like(current_userid, topic_id)
   current_userid = tonumber(current_userid)
   topic_id = tonumber(topic_id)

   local res, err = db:query("select count(l.id) as c from `like` l " .. 
      " where l.user_id=? and l.topic_id=?", {current_userid, topic_id})
   if err or not res or (#res>=1 and tonumber(res[1].c)<1) then
      return false
   else
      return true
   end
end

function like_model:like(user_id, topic_id)
   local res, err =  db:query("insert into `like` (user_id,topic_id) values(?,?) ON DUPLICATE KEY UPDATE create_time=CURRENT_TIMESTAMP", 
      {tonumber(user_id), tonumber(topic_id)})
      if err or not res then
         return false
      else
         return true
      end
end

function like_model:cancel_like(user_id, topic_id)
   local res, err =  db:query("delete from `like` where user_id=? and topic_id=?", 
      {tonumber(user_id), tonumber(topic_id)})
      if err or not res then
         return false
      else
         return true
      end
end

function like_model:reset_topic_like_num(topic_id)
	db:query("update topic set like_num=(select count(id) from `like` where topic_id=?) where id=?", 
		{tonumber(topic_id), tonumber(topic_id)})
end

return like_model
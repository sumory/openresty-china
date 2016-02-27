local DB = require("app.libs.db")
local db = DB:new()

local follow_model = {}

function follow_model:get_fans_of_user(user_id, page_no, page_size)
      local res, err =  db:query("select u.* from follow f right join user u on f.from_id=u.id where f.to_id=? limit ?,?", 
         {tonumber(user_id), (page_no - 1) * page_size, page_size})
      if err or not res or type(res) ~= "table" or #res<1 then
         return {}
      else
         return res
      end
end

function follow_model:get_follows_of_user(user_id, page_no, page_size)
      local res, err =  db:query("select u.* from follow f right join user u on f.to_id=u.id where f.from_id=? limit ?,?", 
         {tonumber(user_id), (page_no - 1) * page_size, page_size})
      if err or not res or type(res) ~= "table" or #res<1 then
         return {}
      else
         return res
      end
end

function follow_model:get_follows_count(user_id)
   	local res, err =  db:query("select count(f.id) as follows_count from follow f right join user u on f.to_id=u.id where from_id=?", {tonumber(user_id)})
   	if err or not res or #res~=1 or not res[1].follows_count then
   		return 0
   	else
   		return res[1].follows_count
   	end
end

function follow_model:get_fans_count(user_id)
   local res, err =  db:query("select count(f.id) as fans_count from follow  f right join user u on f.from_id=u.id where to_id=?", {tonumber(user_id)})
   	if err or not res or #res~=1 or not res[1].fans_count then
   		return 0
   	else
   		return res[1].fans_count
   	end
end

function follow_model:get_relation(id1, id2)
   local res, err =  db:query("select * from follow where (from_id=? and to_id=?) or (from_id=? and to_id=?)", 
      {tonumber(id1), tonumber(id2), tonumber(id2), tonumber(id1)})
      if err or not res or type(res)~="table" or #res<1 then
         return {}
      else
         return res
      end
end

function follow_model:follow(id1, id2)
   local res, err =  db:query("insert into follow (from_id,to_id) values(?,?) ON DUPLICATE KEY UPDATE create_time=CURRENT_TIMESTAMP ", 
      {tonumber(id1), tonumber(id2)})
      if err or not res then
         return false
      else
         return true
      end
end

function follow_model:cancel_follow(id1, id2)
   local res, err =  db:query("delete from follow  where from_id=? and to_id=?", 
      {tonumber(id1), tonumber(id2)})
      if err or not res then
         return false
      else
         return true
      end
end



return follow_model
local pairs = pairs
local ipairs = ipairs
local ssplit = string.split
local tconcat = table.concat
local tinsert = table.insert
local lor = require("lor.index")
local utils = require("app.libs.utils")
local user_model = require("app.model.user")
local topic_model = require("app.model.topic")
local comment_model = require("app.model.comment")
local notification_model = require("app.model.notification")
local comment_router = lor:Router()

comment_router:get("/:comment_id/delete", function(req, res, next)
    local comment_id = req.params.comment_id
    local userid = req.session.get("user").userid

    if not userid then
        return res:json({
            success = false,
            msg = "删除评论之前请先登录."
        })
    end

    if not comment_id then
        return res:json({
            success = false,
            msg = "参数错误."
        })
    end

    local comment = comment_model:query(comment_id)
    local result = comment_model:delete(userid, comment_id)

    if result then

        -- 重置评论所属的文章的评论数和最后回复等信息
        if comment and comment.topic_id ~=0 then
            local topic_id = comment.topic_id
            comment_model:reset_topic_comment_num(topic_id)

            local last_reply = comment_model:get_last_reply_of_topic(topic_id)
            if last_reply and last_reply.user_id~=0 then
                topic_model:reset_last_reply(topic_id, last_reply.user_id, last_reply.user_name, last_reply.create_time) -- 更新最后回复人
            else
                topic_model:reset_last_reply(topic_id, 0, "", "1970-01-01 00:00:00") -- 更新最后回复人
            end
        end

        res:json({
            success = true,
            msg = "删除评论成功"
        })
    else
        res:json({
            success = false,
            msg = "删除评论失败"
        })
    end

end)

comment_router:post("/new", function(req, res, next)
    local topic_id = req.body.topic_id
    local content = req.body.content
    local mention_users = req.body.mention_users
    

    local user = req.session.get("user")
    local user_id = user.userid

    if not user_id then
        return res:json({
            success = false,
            msg = "操作之前请先登录."
        })
    end

    if not topic_id or not content or content == "" then
        res:json({
            success = false,
            msg = "参数不得为空."
        })
        return
    end

    local mus -- 评论中提到的人
    if mention_users then
        mus = utils.string_split(mention_users, ",")
        if mus and type(mus) == "table" and #mus>5 then
            return res:json({
                success = false,
                msg = "评论涉及的人最多只能有5个!"
            })
        end
    end

    local result, err = comment_model:new(topic_id, user_id, content)
    if not result or err then
        res:json({
            success = false,
            msg = "保存评论失败"
        })
    else
        local new_comment_id = result.insert_id
        comment_model:reset_topic_comment_num(topic_id)

        local last_reply = comment_model:get_last_reply_of_topic(topic_id)
        if last_reply and last_reply.user_id~=0 then
            topic_model:reset_last_reply(topic_id, last_reply.user_id, last_reply.user_name, last_reply.create_time) -- 更新最后回复人
        end

        local new_comment =  comment_model:query(new_comment_id)

        -- 给评论涉及者发通知
        if mus and type(mus) == "table" and utils.table_is_array(mus) and #mus>0 then
            local clean_mus = {}
            for i,v in ipairs(mus) do
                if v and v~="" then
                    tinsert(clean_mus, utils.secure_str(v))
                end
            end
            if clean_mus and #clean_mus>0 then
                local usernames = tconcat(clean_mus, ",")
                if usernames and usernames ~= "" then
                    local uids, err = user_model:query_ids(usernames);
                    if uids and not err then
                        for i,u in pairs(uids) do -- 给每个人发通知
                            notification_model:comment_mention(u.id, user_id, "", topic_id, new_comment_id)
                        end
                    end
                end
            end
        end

        -- 给文章所有者发通知
        notification_model:comment_notify(user_id, "", topic_id, new_comment_id)

        res:json({
            success = true,
            msg = "保存评论成功",
            data = {
                c = new_comment
            }
        })
    end
end)


return comment_router

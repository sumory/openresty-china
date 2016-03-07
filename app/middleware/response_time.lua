local sformat = string.format

local function _set_header(options) 
    local digits = options.digits or 3
    local header = options.header or 'X-Response-Time'
    local suffix = options.suffix or false

    return function(req, res, time) 
        if ngx.req.get_headers()[header] then
          return
        end

        local val = sformat("%.".. digits .. "f", time)

        if suffix then
            val = val .. " ms"
        end

        res:set_header(header, val)
    end
end

local function _wrap(prev_send, res, fn)
    local invoked = false

    return function(self, content) 
        if not invoked then
            invoked = true
            fn()
        end

        prev_send(res, content)
    end
end

local function _inject(res, fn)

    res._send = _wrap(res._send, res, fn)
end

return function(options)
    local opts = options or {}
    local fn
    if type(opts) ~= 'function' then
        fn = _set_header(opts)
    else
        fn = opts
    end

    return function(req, res, next)
        local start = ngx.now()

        _inject(res, function()
            local diff = ngx.now()*1000 - start*1000
            fn(req, res, diff)
        end)

        next()
    end
end

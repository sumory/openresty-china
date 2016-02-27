
### 自定义插件目录(define your own middleware)


You are recommended to define your own middlewares and keep them in one place to manage.

建议用户将自定义插件存放在此目录下统一管理，然后在其他地方引用，插件的格式如下:

```
local middleware =  function(params)
    return function(req, res, next)
        -- do something with req/res
        next()
    end
end

return middleware
```


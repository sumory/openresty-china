local function split(str, delimiter)
    if str==nil or str=='' or delimiter==nil then
        return nil
    end
    
    local result = {}
    for match in (str..delimiter):gmatch("(.-)"..delimiter) do
        table.insert(result, match)
    end
    return result
end


local function compose(t, params)
	print(#t)
	print(#params)
	if t==nil or params==nil or type(t)~="table" or type(params)~="table" or #t~=#params+1 or #t==0 then
		return nil
	else
		local result = t[1]
		for i=1, #params do
			result = result  .. params[i].. t[i+1]
		end
		return result
	end
end



local t = split("select * from user where a=? and b=?","?")
local result = compose(t, {"1",2})
print(result)


local t = split("select * from user where a=? and b=? and i in(?,?)","?")
local result = compose(t, {"1",2,3,"4"})
print(result)

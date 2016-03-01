return function(text)

	return function(req, res, next)
	    res:set_header('X-Powered-By', text)
	    next()
	end

end
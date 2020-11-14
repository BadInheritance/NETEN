
GMath  = {
    sign = function(x)
        return x>0 and 1 or x<0 and -1 or 0
    end,
    abs = function (x)
        return GMath.sign(x) * x
    end,
    min = function(x, y)
        if x > y then return y else return x end
    end
}

return GMath
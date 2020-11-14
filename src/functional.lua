Functional = {}

Functional.foreach = function(tbl, fun)
    for k, v in pairs(tbl) do
        fun(v)
    end
end

return Functional
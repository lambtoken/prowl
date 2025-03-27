local vector = {}

function vector.new(x, y)
    return { x = x, y = y }
end

function vector.add(v1, v2)
    return vector.new(v1.x + v2.x, v1.y + v2.y)
end

function vector.subtract(v1, v2)
    return vector.new(v1.x - v2.x, v1.y - v2.y)
end

function vector.multiply(v, scalar)
    return vector.new(v.x * scalar, v.y * scalar)
end

function vector.divide(v, scalar)
    return vector.new(v.x / scalar, v.y / scalar)
end

function vector.magnitude(v)
    return math.sqrt(v.x * v.x + v.y * v.y)
end

function vector.normalize(v)
    local mag = vector.magnitude(v)
    if mag == 0 then
        return vector.new(0, 0)
    else
        return vector.divide(v, mag)
    end
end

return vector
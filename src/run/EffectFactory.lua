local EffectFactory = {}

-- effecttype: increase, increaseP
function EffectFactory.newStat(effectType, target, amount)
    assert(type(effectType) == "string" and
            effectType == "increase" or
            effectType == "increaseP"
            , "Invalid effecttype, got: " .. effectType)
    
    assert(type(amount) == "number", "Expected number, got: ".. amount)

    assert(type(target) == "string" and
        target == "atk" or
        target == "def" or 
        target == "hp" or 
        target == "crit" or
        target == "lifeSteal" or
        target == "pen"
        , "Invalid effect target, got: " .. target)

    return {effectType, amount, target}
end

-- effecttype: swapBase, add, extend, swap, remove, append
function EffectFactory.newPattern(effectType, target, pattern)
    assert(type(effectType) == "string" and
            effectType == "swapBase" or
            effectType == "add" or
            effectType == "extend" or
            effectType == "swap" or
            effectType == "remove" or
            effectType == "append"
        , "Invalid effecttype, got: " .. effectType)
    
    assert(type(pattern) == "table", "Expected table, got: " .. type(pattern))

    return {effectType, target, pattern}
end

return EffectFactory
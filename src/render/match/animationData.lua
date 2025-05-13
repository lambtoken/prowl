local EventManager = require("src.state.events"):getInstance()
local RM = require('src.render.RenderManager'):getInstance()

local SWAY_DURATION = 0.7
local SINE_DURATION = 1.7
local SINE_RANGE = 0.2

local animations = {

    idle = { 

        cancelCategory = "all",
        loop = true,
        stackable = false,
        onFinish = function() end,
        tweens = {
            {
                delay = 0,
                duration = SWAY_DURATION,
                target = 'translateX',
                from = 0,
                to = 5,
                func = "outSine"
            },
            {
                delay = SWAY_DURATION,
                duration = SWAY_DURATION * 2,
                target = 'translateX',
                from = 5,
                to = -5,
                func = "inOutSine"
            },
            {
                delay = SWAY_DURATION + SWAY_DURATION * 2,
                duration = SWAY_DURATION,
                target = 'translateX',
                from = -5,
                to = 0,
                func = "inSine"
            }
        }
    },

    hit = { 

        cancelCategory = "none",
        loop = false,
        stackable = true,
        onFinish = function(entity) EventManager:emit("afterAttack", entity) end,
        tweens = {
            {
                delay = 0,
                duration = 1,
                target = 'scaleX',
                from = 0,
                to = 0,
                func = "random"
            },
            {
                delay = 0,
                duration = 0.3,
                target = 'translateX',
                from = -10,
                to = 10,
                func = "random"
            },
            {
                delay = 0,
                duration = 0.3,
                target = 'scaleX',
                from = 0,
                to = 0.3,
                func = "outQuint"
            },
            {
                delay = 0.3,
                duration = 0.4,
                target = 'scaleX',
                from = 0.3,
                to = 0,
                func = "outBounce"
            }
        }
    },

    attack = {

        cancelCategory = "all",
        loop = false,
        stackable = false,
        onFinish = function() end,
        tweens = {
            {
                delay = 0,
                duration = 0.2,
                target = 'rotation',
                from = 0,
                to = -math.pi/8,
                func = "outQuint"
            },
            {
                delay = 0.2,
                duration = 0.3,
                target = 'rotation',
                from = -math.pi/8,
                to = 0,
                func = "outBounce"
            }
        }
    },

    death = {

        cancelCategory = "all",
        loop = false,
        stackable = false,
        onFinish = function(entity) EventManager:emit("setState", entity, "dead") end,
        tweens = {
            {
                delay = 0,
                duration = 1,
                target = 'rotation',
                from = 0,
                to = math.pi / 8,
                func = "outBounce"
            },
            {
                delay = 0,
                duration = 0.75,
                target = 'translateY',
                from = 0,
                to = -20,
                func = "outQuint"
            },
            {
                delay = 0.75,
                duration = 1.75,
                target = 'translateY',
                from = -20,
                to = RM.windowHeight + 100,
                func = "outBounce"
            },
            {
                delay = 1,
                duration = 1,
                target = 'rotation',
                from = math.pi / 8,
                to = - math.pi / 8,
                func = "outBounce"
            },
        }
    },
    
    trigger = { 

        cancelCategory = "none",
        loop = false,
        stackable = true,
        onFinish = function(entity) end,
        tweens = {
            {
                delay = 0,
                duration = 1,
                target = 'scaleX',
                from = 0,
                to = 0,
                func = "random"
            },
            {
                delay = 0,
                duration = 0.3,
                target = 'translateX',
                from = -10,
                to = 10,
                func = "random"
            },
            {
                delay = 0,
                duration = 0.3,
                target = 'scaleX',
                from = 0,
                to = 0.3,
                func = "outBounce"
            },
            {
                delay = 0.3,
                duration = 0.4,
                target = 'scaleX',
                from = 0.3,
                to = 0,
                func = "inBounce"
            }
        }
    },

    trigger_death = { 

        cancelCategory = "none",
        loop = false,
        stackable = true,
        onFinish = function(entity) EventManager:emit("setState", entity, "dead") end,
        tweens = {
            {
                delay = 0,
                duration = 1,
                target = 'scaleX',
                from = 0,
                to = 0,
                func = "random"
            },
            {
                delay = 0,
                duration = 0.3,
                target = 'translateX',
                from = -10,
                to = 10,
                func = "random"
            },
            {
                delay = 0,
                duration = 0.3,
                target = 'scaleX',
                from = 0,
                to = 0.3,
                func = "outBounce"
            },
            {
                delay = 0.3,
                duration = 0.4,
                target = 'scaleX',
                from = 0.3,
                to = 0,
                func = "inBounce"
            }
        }
    },

    tumble = { 

        cancelCategory = "none",
        loop = false,
        stackable = true,
        onFinish = function() end,
        tweens = {
            {
                delay = 0,
                duration = 2,
                target = 'rotation',
                from = 0,
                to = 2 * math.pi,
                func = "outQuart"
            },
        }
    },


    explode = { 

        cancelCategory = "none",
        loop = false,
        stackable = true,
        onFinish = function(entity) EventManager:emit("setState", entity, "dead") end,
        tweens = {
            {
                delay = 0,
                duration = 0.3,
                target = 'translateX',
                from = -10,
                to = 10,
                func = "random"
            },
            {
                delay = 0,
                duration = 0.3,
                target = 'scaleX',
                from = 0,
                to = 0.3,
                func = "outBounce"
            },
            {
                delay = 0.3,
                duration = 0.4,
                target = 'scaleX',
                from = 0.3,
                to = 0,
                func = "inBounce"
            }
        }
    },

    sine_wave = { 

        cancelCategory = "none",
        loop = false,
        stackable = true,
        onFinish = function() end,
        tweens = {
            {
                delay = 0,
                duration = SINE_DURATION,
                target = 'rotation',
                from = 0,
                to = SINE_RANGE,
                func = "outSine"
            },
            {
                delay = SINE_DURATION,
                duration = SINE_DURATION * 2,
                target = 'rotation',
                from = SINE_RANGE,
                to = -SINE_RANGE,
                func = "inOutSine"
            },
            {
                delay = SINE_DURATION + SINE_DURATION * 2,
                duration = SINE_DURATION,
                target = 'rotation',
                from = -SINE_RANGE,
                to = 0,
                func = "inSine"
            }
        }

    },

    bubble_up = { 

        cancelCategory = "none",
        loop = false,
        stackable = true,
        onFinish = function() end,
        tweens = {
            {
                delay = 0,
                duration = SINE_DURATION,
                target = 'scaleX',
                from = 0,
                to = SINE_RANGE,
                func = "outSine"
            },
            {
                delay = SINE_DURATION,
                duration = SINE_DURATION * 2,
                target = 'scaleX',
                from = SINE_RANGE,
                to = -SINE_RANGE,
                func = "inOutSine"
            },
            {
                delay = SINE_DURATION + SINE_DURATION * 2,
                duration = SINE_DURATION,
                target = 'scaleX',
                from = -SINE_RANGE,
                to = 0,
                func = "inSine"
            }
        }

    },
}


return animations
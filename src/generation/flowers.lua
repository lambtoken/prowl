local flowers = {}

-- names:

-- violet
-- dandelion
-- bluebell
-- sunflower
-- lily_of_the_valley
-- rose
-- canna_lily

flowers = {
    forest = {
        amount = {4, 6},
        rates = {
            {name = 'violet', rate = 10, limit = 0},
            {name = 'lily_of_the_valley', rate = 10, limit = 0},
            {name = 'bluebell', rate = 10, limit = 0},
        }
    },
    plains = {
        amount = {10, 14},
        rates = {
            {name = 'sunflower', rate = 5, limit = 0},
            {name = 'dandelion', rate = 10, limit = 0},
            {name = 'canna_lily', rate = 10, limit = 0},
            {name = 'rose', rate = 3, limit = 0},
        }
    }
}

return flowers
-- to do: add pitch alteration bool

local soundTable = {
    hit1 = {type = 'hit', file = 'hit1.wav'},
    hit2 = {type = 'hit', file = 'hit2.wav'},
    hit3 = {type = 'hit', file = 'hit3.wav', volume = 0.3},

    death = {type = 'death', file = 'something2.wav'},
    bear_trap = {type = 'effect', file = 'bear_trap.wav'},
    mouse_trap = {type = 'effect', file = 'mouse_trap.wav'},
    explosion = {type = 'effect', file = 'explosion.wav', volume = 0.5},
    arrow = {type = 'effect', file = 'arrow.wav', volume = 0.5},
    hiss = {type = 'effect', file = 'hiss.wav', volume = 1},
    bite = {type = 'effect', file = 'bite3.wav'},
    heal = {type = 'heal', file = 'heal.wav'},
    breaking = {type = 'effect', file = 'break.wav'},

    clicktech1 = {type = 'click', file = '01Pclicktech1.wav'},
    clicktech2 = {type = 'click', file = '01Pclicktech2.wav'},
    clicktech3 = {type = 'click', file = '01Pclicktech3.wav'},
    clicktech4 = {type = 'click', file = '01Pclicktech4.wav'},
    pclick1 = {type = 'click', file = '01Pclick1.wav'},
    pclick2 = {type = 'click', file = '01Pclick2.wav'},
    pclick3 = {type = 'click', file = '01Pclick3.wav', volume = 0.5},
    pclick4 = {type = 'click', file = '01Pclick4.wav'},
    pclick5 = {type = 'click', file = '01Pclick5.wav'},
    pclick6 = {type = 'click', file = '01Pclick6.wav'},
    pclick7 = {type = 'click', file = '01Pclick7.wav'},

    pdmg1 = {type = 'click', file = '01Pdmg1.wav', volume = 0.6},
    pdmg2 = {type = 'click', file = '01Pdmg2.wav', volume = 0.6},
    pdmg3 = {type = 'click', file = '01Pdmg3.wav', volume = 0.5},
    ppop = {type = 'click', file = '01Ppop.wav', volume = 0.8},
    pm3 = {type = 'ui', file = '01Pm3.wav', volume = 0.7},
    pm7 = {type = 'ui', file = '01Pm7.wav', volume = 0.7},

    click1 = {type = 'click', file = 'click1.wav'},
    click2 = {type = 'click', file = 'click2.wav'},
    click3 = {type = 'click', file = 'click3.mp3'},
    click4 = {type = 'click', file = 'click4.wav'},
    click5 = {type = 'click', file = 'click5.wav'},
    click6 = {type = 'click', file = 'click6.wav'},
    click7 = {type = 'click', file = 'click7.wav'},
    click8 = {type = 'click', file = 'click8.wav'},
    click10 = {type = 'click', file = 'click10.wav', volume = 0.5},
    click11 = {type = 'click', file = 'click11.wav', volume = 0.8},
    click12 = {type = 'click', file = 'click12.wav'},
    clickyclicky = {type = 'click', file = 'clickyclicky.wav'},

    softclick = {type = 'click', file = 'softclick.wav', volume = 0.7},
    softclick2 = {type = 'click', file = 'softclick2.wav', volume = 0.7},
    softclick3 = {type = 'click', file = 'softclick3.wav', volume = 0.7},

    knockback = {type = 'knockback', file = 'knockback.wav', volume = 0.7},
    displace = {type = 'displace', file = 'displace.wav', volume = 1},
    victory = {type = 'ui', file = 'victory.wav', volume = 1},
    loss = {type = 'ui', file = 'slowmo.wav', volume = 0.6},
    --arrow = {type = 'effect', file = 'oawn.wav', volume = 1},
    miss = {type = 'effect', file = 'miss.wav', volume = 0.6},
}

return soundTable
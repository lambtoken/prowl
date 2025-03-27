local sceneM = require('src.scene.SceneManager'):getInstance()

local menus = {}

menus.main = {
    buttons = {
        {
            text = 'New Game',
            callback = function()
                sceneM:switchScene('animalSelect')
            end
        },

        {
            text = 'Options',
            callback = function() sceneM:switchScene('options') end
        },

        {
            text = 'Quit',
            callback = function() love.event.quit() end
        }
    },

    width = 500,
    marginBottom = 20
}

menus.pause = {
    buttons = {
        settings = {
            text = 'Settings',
            callback = function()
                love.event.push('mainMenu')
            end
        },
    
        quitToMainMenu = {
            text = 'Quit to Main Menu',
            callback = function()
                love.event.push('mainMenu')
            end
        }
    },

    width = 500,
    marginBottom = 20
}

return menus
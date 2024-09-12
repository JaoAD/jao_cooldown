fx_version 'cerulean'
game 'gta5'

author 'Your Name'
description 'ESX Priority Cooldown with UI'
version '1.0.0'

shared_scripts {
    '@es_extended/imports.lua',
    '@es_extended/locale.lua',
    'locales/*.lua',
    'config.lua'
}

server_scripts {
    'server/main.lua'
}

client_scripts {
    'client/main.lua'
}

ui_page 'html/status.html'

files {
    'html/police_ui.html',
    'html/police_ui.css',
    'html/police_ui.js',
    'html/status.html'
}

dependencies {
    'es_extended'
}
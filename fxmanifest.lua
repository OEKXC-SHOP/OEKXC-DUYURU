fx_version 'cerulean'
game 'gta5'

author 'OEKXC'
description 'Admin Duyuru Sistemi'
version '1.0.0'

ui_page 'html/index.html'

shared_scripts {
    'config.lua'
}

client_scripts {
    'client/main.lua'
}

server_scripts {
    '@mysql-async/lib/MySQL.lua',
    '@oxmysql/lib/MySQL.lua',
    'config.lua',
    'server/main.lua'
}

files {
    'html/index.html',
    'html/panel.css',
    'html/announcement.css',
    'html/script.js'
}

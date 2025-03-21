ESX = nil
local Framework = nil

if Config.Framework == 'esx' then
    TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
else
    Framework = exports['qb-core']:GetCoreObject()
end

-- Duyuru gönderme
RegisterServerEvent('oekxc-duyuru:sendAnnouncement')
AddEventHandler('oekxc-duyuru:sendAnnouncement', function(message, importance)
    local source = source
    local xPlayer
    
    if Config.Framework == 'esx' then
        xPlayer = ESX.GetPlayerFromId(source)
    else
        xPlayer = Framework.Functions.GetPlayer(source)
    end

    if xPlayer then
        local adminName = GetPlayerName(source)
        
        -- Tüm oyunculara duyuruyu gönder
        TriggerClientEvent('oekxc-duyuru:showAnnouncement', -1, message, adminName, importance)
        
        -- Duyuruyu veritabanına kaydet
        SaveAnnouncement(message, adminName, importance)
    end
end)

-- Duyuru geçmişini alma
RegisterServerEvent('oekxc-duyuru:getHistory')
AddEventHandler('oekxc-duyuru:getHistory', function()
    local source = source
    local xPlayer
    
    if Config.Framework == 'esx' then
        xPlayer = ESX.GetPlayerFromId(source)
    else
        xPlayer = Framework.Functions.GetPlayer(source)
    end

    if xPlayer then
        -- Son 10 duyuruyu al ve gönder
        GetLastAnnouncements(function(announcements)
            TriggerClientEvent('oekxc-duyuru:receiveHistory', source, announcements)
        end)
    end
end)

-- Duyuruyu veritabanına kaydetme
function SaveAnnouncement(message, adminName, importance)
    if Config.Framework == 'esx' then
        MySQL.Async.execute('INSERT INTO oekxc_announcements (message, admin_name, importance_level, created_at) VALUES (@message, @admin_name, @importance, NOW())',
            {
                ['@message'] = message,
                ['@admin_name'] = adminName,
                ['@importance'] = importance
            }
        )
    else
        exports.oxmysql:execute('INSERT INTO oekxc_announcements (message, admin_name, importance_level, created_at) VALUES (?, ?, ?, NOW())',
            {message, adminName, importance}
        )
    end
end

-- Son duyuruları alma
function GetLastAnnouncements(cb)
    if Config.Framework == 'esx' then
        MySQL.Async.fetchAll('SELECT * FROM oekxc_announcements ORDER BY created_at DESC LIMIT 10', {}, function(results)
            cb(results)
        end)
    else
        exports.oxmysql:execute('SELECT * FROM oekxc_announcements ORDER BY created_at DESC LIMIT 10', {}, function(results)
            cb(results)
        end)
    end
end

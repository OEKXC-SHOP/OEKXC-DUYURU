ESX = nil
QBCore = nil

-- Framework başlatma
if Config.Framework == 'esx' then
    TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
else
    QBCore = exports['qb-core']:GetCoreObject()
end

-- Admin kontrolü
local function isAdmin(source)
    if Config.Framework == 'esx' then
        local xPlayer = ESX.GetPlayerFromId(source)
        if xPlayer then
            local group = xPlayer.getGroup()
            return Config.ESXAdminGroups[group] or false
        end
    else
        local Player = QBCore.Functions.GetPlayer(source)
        if Player then
            for permission, _ in pairs(Config.QBPermissions) do
                if QBCore.Functions.HasPermission(source, permission) then
                    return true
                end
            end
        end
    end
    return false
end

-- Oyuncu ismini alma
local function getPlayerName(source)
    if Config.Framework == 'esx' then
        local xPlayer = ESX.GetPlayerFromId(source)
        return xPlayer and xPlayer.getName() or 'Unknown'
    else
        local Player = QBCore.Functions.GetPlayer(source)
        return Player and Player.PlayerData.charinfo.firstname .. ' ' .. Player.PlayerData.charinfo.lastname or 'Unknown'
    end
end

-- Duyuru gönderme
RegisterServerEvent('oekxc-duyuru:sendAnnouncement')
AddEventHandler('oekxc-duyuru:sendAnnouncement', function(message, importance)
    local source = source
    if isAdmin(source) then
        local adminName = getPlayerName(source)
        local identifier = Config.Framework == 'esx' 
            and ESX.GetPlayerFromId(source).getIdentifier()
            or QBCore.Functions.GetIdentifier(source, 'license')
        
        -- Önem seviyesini kontrol et
        importance = importance or 'low'
        if not Config.ImportanceLevels[importance] then
            importance = 'low'
        end
        
        MySQL.Async.execute('INSERT INTO announcements (admin_identifier, admin_name, message, importance_level) VALUES (@identifier, @name, @message, @importance)',
            {
                ['@identifier'] = identifier,
                ['@name'] = adminName,
                ['@message'] = message,
                ['@importance'] = importance
            }
        )
        
        TriggerClientEvent('oekxc-duyuru:showAnnouncement', -1, message, adminName, importance)
        
        -- Konsola log
        print(string.format('[DUYURU] [%s] %s: %s', importance, adminName, message))
    end
end)

-- Geçmiş duyuruları getirme
RegisterServerEvent('oekxc-duyuru:getHistory')
AddEventHandler('oekxc-duyuru:getHistory', function()
    local source = source
    if isAdmin(source) then
        MySQL.Async.fetchAll('SELECT * FROM announcements ORDER BY created_at DESC LIMIT @limit',
            { ['@limit'] = Config.Settings.MaxHistory },
            function(results)
                TriggerClientEvent('oekxc-duyuru:receiveHistory', source, results)
            end
        )
    end
end)

ESX = nil
local Framework = nil
local display = false

Citizen.CreateThread(function()
    if Config.Framework == 'esx' then
        while ESX == nil do
            TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
            Citizen.Wait(0)
        end
    else
        while Framework == nil do
            Framework = exports['qb-core']:GetCoreObject()
            Citizen.Wait(0)
        end
    end
end)

-- NUI mesajlarını dinleme
RegisterNUICallback('close', function(data, cb)
    SetDisplay(false)
    cb('ok')
end)

RegisterNUICallback('sendAnnouncement', function(data, cb)
    if Config.Framework == 'esx' then
        TriggerServerEvent('oekxc-duyuru:sendAnnouncement', data.message, data.importance)
    else
        TriggerServerEvent('oekxc-duyuru:sendAnnouncement', data.message, data.importance)
    end
    cb('ok')
end)

-- Duyuru menüsünü açma
RegisterCommand(Config.Settings.Command, function()
    if Config.Framework == 'esx' then
        TriggerServerEvent('oekxc-duyuru:getHistory')
    else
        TriggerServerEvent('oekxc-duyuru:getHistory')
    end
    SetDisplay(true)
end)

-- Duyuruyu gösterme
RegisterNetEvent('oekxc-duyuru:showAnnouncement')
AddEventHandler('oekxc-duyuru:showAnnouncement', function(message, adminName, importance)
    SendNUIMessage({
        type = "announcement",
        message = message,
        admin = adminName,
        importance = importance,
        displayTime = Config.Settings.DisplayTime
    })
end)

-- Geçmiş duyuruları alma
RegisterNetEvent('oekxc-duyuru:receiveHistory')
AddEventHandler('oekxc-duyuru:receiveHistory', function(history)
    SendNUIMessage({
        type = "history",
        data = history
    })
end)

function SetDisplay(bool)
    display = bool
    SetNuiFocus(bool, bool)
    if bool then
        -- Arka planı karart ve etkileşimi engelle
        SetNuiFocusKeepInput(false)
        DisableControlAction(0, 1, true) -- Disable mouse look
        DisableControlAction(0, 2, true) -- Disable mouse look
        DisableControlAction(0, 142, true) -- Disable melee
        DisableControlAction(0, 18, true) -- Disable attack
        DisableControlAction(0, 322, true) -- Disable ESC
        DisableControlAction(0, 106, true) -- Disable vehicle mouse control
    else
        -- Arka plan efektlerini kaldır ve kontrolleri geri aç
        SetNuiFocusKeepInput(true)
        EnableAllControlActions(0)
    end
    SendNUIMessage({
        type = "ui",
        status = bool
    })
end

-- Sürekli kontrol için thread
Citizen.CreateThread(function()
    while true do
        if display then
            DisableControlAction(0, 1, true)
            DisableControlAction(0, 2, true)
            DisableControlAction(0, 142, true)
            DisableControlAction(0, 18, true)
            DisableControlAction(0, 322, true)
            DisableControlAction(0, 106, true)
            DisableControlAction(0, 24, true)
            DisableControlAction(0, 25, true)
            DisableControlAction(0, 257, true)
        end
        Citizen.Wait(0)
    end
end)

-- Oyuncu menüyü kapatmaya çalıştığında
Citizen.CreateThread(function()
    while true do
        Citizen.Wait(0)
        if display then
            if IsControlJustReleased(0, 322) then -- ESC tuşu
                SetDisplay(false)
            end
        end
    end
end)

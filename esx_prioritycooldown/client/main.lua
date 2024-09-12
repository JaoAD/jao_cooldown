local ESX = exports["es_extended"]:getSharedObject()

local cooldown = 0
local ispriority = true
local ishold = false

RegisterNetEvent('esx_prioritycooldown:updateStatus')
AddEventHandler('esx_prioritycooldown:updateStatus', function(data)
    ispriority = data.priority
    ishold = data.hold
    cooldown = data.cooldown
    SendNUIMessage({
        type = 'updateStatus',
        ispriority = ispriority,
        ishold = ishold,
        cooldown = cooldown
    })
end)

RegisterNetEvent('esx_prioritycooldown:openPoliceUI')
AddEventHandler('esx_prioritycooldown:openPoliceUI', function()
    SetNuiFocus(true, true)
    SendNUIMessage({type = 'openPoliceUI'})
end)

RegisterNUICallback('action', function(data, cb)
    TriggerServerEvent('esx_prioritycooldown:action', data.action)
    cb('ok')
end)

RegisterNUICallback('close', function(data, cb)
    SetNuiFocus(false, false)
    cb('ok')
end)

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(1000)
        if cooldown > 0 then
            cooldown = cooldown - 1
            SendNUIMessage({
                type = 'updateStatus',
                ispriority = ispriority,
                ishold = ishold,
                cooldown = cooldown
            })
        end
    end
end)

-- Add this to show the status UI when the resource starts
Citizen.CreateThread(function()
    Wait(100)
    SendNUIMessage({
        type = 'showStatusUI'
    })
end)
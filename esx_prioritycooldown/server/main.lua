ESX = exports["es_extended"]:getSharedObject()

local status = 1 -- 1 = Safe, 2 = In Progress, 3 = Cooldown
local cooldown = 0
local ispriority = true
local ishold = false

local function broadcastStatus()
    TriggerClientEvent('esx_prioritycooldown:updateStatus', -1, {
        priority = ispriority,
        hold = ishold,
        cooldown = cooldown
    })
end

RegisterNetEvent('esx_prioritycooldown:action')
AddEventHandler('esx_prioritycooldown:action', function(action)
    local source = source
    local xPlayer = ESX.GetPlayerFromId(source)
    
    if xPlayer.job.name ~= Config.allowedJob then
        TriggerClientEvent('esx:showNotification', source, _U('not_allowed'))
        return
    end

    if action == 'safe' then
        status = 1
        ispriority = true
        ishold = false
        cooldown = 0
    elseif action == 'cooldown' then
        status = 3
        ispriority = false
        ishold = false
        cooldown = Config.timer * 60 -- Convert minutes to seconds
    elseif action == 'inprogress' then
        status = 2
        ispriority = false
        ishold = true
        cooldown = 0
    elseif action == 'resetpcd' then
        cooldown = 0
        status = 1
        ispriority = true
        ishold = false
    end

    broadcastStatus()

    if Config.discordLogging then
        local ids = ExtractIdentifiers(source)
        local _discordID = ids.discord ~= "" and "\n**Discord ID:** <@" .. ids.discord:gsub("discord:", "") .. ">" or "\n**Discord ID:** N/A"
        local msg = GetPlayerName(source) .. _U('set_' .. action) .. "\n " .. _discordID .. "\n **Player ID:** " .. source
        sendWebhook(msg)
    end
end)

-- Cooldown timer
Citizen.CreateThread(function()
    while true do
        Citizen.Wait(1000) -- Update every second
        if cooldown > 0 then
            cooldown = cooldown - 1
            if cooldown % 5 == 0 then -- Broadcast every 5 seconds to reduce network traffic
                broadcastStatus()
            end
        end
    end
end)

function ExtractIdentifiers(src)
    local identifiers = {
        steam = "",
        ip = "",
        discord = "",
        license = "",
        xbl = "",
        live = ""
    }

    for i = 0, GetNumPlayerIdentifiers(src) - 1 do
        local id = GetPlayerIdentifier(src, i)
        if string.find(id, "steam") then
            identifiers.steam = id
        elseif string.find(id, "ip") then
            identifiers.ip = id
        elseif string.find(id, "discord") then
            identifiers.discord = id
        elseif string.find(id, "license") then
            identifiers.license = id
        elseif string.find(id, "xbl") then
            identifiers.xbl = id
        elseif string.find(id, "live") then
            identifiers.live = id
        end
    end

    return identifiers
end

function sendWebhook(message)
    if Config.discordWebhook ~= "" then
        PerformHttpRequest(Config.discordWebhook, function(err, text, headers) end, 'POST', json.encode({username = Config.webhookName, content = message}), { ['Content-Type'] = 'application/json' })
    end
end

RegisterCommand('pcd', function(source, args, rawCommand)
    local xPlayer = ESX.GetPlayerFromId(source)
    if xPlayer.job.name == Config.allowedJob then
        if #args == 1 then
            local action = args[1]
            if action == 'safe' or action == 'cooldown' or action == 'inprogress' or action == 'resetpcd' then
                TriggerEvent('esx_prioritycooldown:action', action)
            else
                TriggerClientEvent('esx:showNotification', source, 'Invalid action. Use: safe, cooldown, inprogress, or resetpcd')
            end
        else
            TriggerClientEvent('esx_prioritycooldown:openPoliceUI', source)
        end
    else
        TriggerClientEvent('esx:showNotification', source, _U('not_allowed'))
    end
end, false)

-- Initial broadcast on resource start
AddEventHandler('onResourceStart', function(resource)
    if resource == GetCurrentResourceName() then
        Citizen.Wait(1000) -- Wait for everything to initialize
        broadcastStatus()
    end
end)
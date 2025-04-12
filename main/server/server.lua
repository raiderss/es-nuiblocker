local playerWarnings = {}
local playerDetections = {}

local function serverLog(message, level)
    level = level or "info"
    local prefix = "^3[ES-NUIBLOCKER]^7 "
    if level == "warning" then
        prefix = "^3[ES-NUIBLOCKER]^7 "
    elseif level == "error" then  
        prefix = "^1[ES-NUIBLOCKER]^7 "
    elseif level == "success" then
        prefix = "^2[ES-NUIBLOCKER]^7 "
    end
    print(prefix .. message)
end

local function getidentifiers(player)
    local steamid = "Not Linked"
    local license = "Not Linked"
    local discord = "Not Linked"
    local xbl = "Not Linked"
    local liveid = "Not Linked"
    local ip = "Not Linked"

    for k, v in pairs(GetPlayerIdentifiers(player)) do
        if string.sub(v, 1, string.len("steam:")) == "steam:" then
            steamid = v
        elseif string.sub(v, 1, string.len("license:")) == "license:" then
            license = v
        elseif string.sub(v, 1, string.len("xbl:")) == "xbl:" then
            xbl = v
        elseif string.sub(v, 1, string.len("ip:")) == "ip:" then
            ip = string.sub(v, 4)
        elseif string.sub(v, 1, string.len("discord:")) == "discord:" then
            discordid = string.sub(v, 9)
            discord = "<@" .. discordid .. ">"
        elseif string.sub(v, 1, string.len("live:")) == "live:" then
            liveid = v
        end
    end

    return steamid, license, xbl, ip, discord, liveid
end

local function sendToDiscord(playerId, webhookUrl, detectionInfo)
    if not webhookUrl or webhookUrl == "" then return end

    local playerSteam, playerLicense, playerXBL, playerIP, playerDiscord, playerLiveID = getidentifiers(playerId)
    local playerName = GetPlayerName(playerId)  
    local reason = detectionInfo and detectionInfo.reason or "DevTools Usage"
    local currentTime = os.date("%Y-%m-%d %H:%M:%S")
    
    local embedData = {
        {
            ["title"] = "DevTools Usage Detected",
            ["description"] = "A player has been detected using browser developer tools.",
            ["color"] = 16711680,
            ["fields"] = {
                {["name"] = "Player Name", ["value"] = playerName, ["inline"] = true},  
                {["name"] = "Server ID", ["value"] = playerId, ["inline"] = true},
                {["name"] = "License", ["value"] = playerLicense, ["inline"] = true},
                {["name"] = "Steam", ["value"] = playerSteam, ["inline"] = true},
                {["name"] = "Discord", ["value"] = playerDiscord, ["inline"] = true},
                {["name"] = "IP Address", ["value"] = playerIP, ["inline"] = true},
                {["name"] = "Detection Type", ["value"] = reason, ["inline"] = true},
                {["name"] = "Detection Time", ["value"] = currentTime, ["inline"] = true}
            },
            ["footer"] = {["text"] = "ES-NUIBlocker | Anti-DevTools Protection"}
        }
    }

    local sent = false
    local function sendWebhook()
        if not sent then
            sent = true
            PerformHttpRequest(webhookUrl, function(err, text, headers) end, 'POST',
                json.encode({embeds = embedData}), { ['Content-Type'] = 'application/json' })
        end
    end

    sendWebhook()
end

RegisterNetEvent("es-nuiblocker:devToolsDetected")
AddEventHandler("es-nuiblocker:devToolsDetected", function(detectionReason)
    local src = source
    local playerName = "Unknown"

    serverLog(playerName .. " (ID: " .. src .. ") was detected using DevTools!")

    if Config.NUIBlocker.kickPlayers then
        local kickReason = Config.NUIBlocker.kickMessage or "DevTools usage is not allowed on this server!"
        serverLog(playerName .. " (ID: " .. src .. ") was kicked for using DevTools!", "error")
        Citizen.Wait(500)
        -- DropPlayer(src, kickReason)
    end

    local webhookUrl = Config.NUIBlocker.webhookUrl
    if webhookUrl and webhookUrl ~= "" then
        sendToDiscord(src, webhookUrl, {reason = detectionReason})
    end
end)

AddEventHandler('playerDropped', function()
    local src = source
    playerWarnings[src] = nil
    playerDetections[src] = nil
end)

RegisterCommand("nuiwarnings", function(source, args)
    local src = source
    local targetId = tonumber(args[1])

    if targetId then
        local targetWarnings = playerWarnings[targetId] or 0
        local name = "Unknown"

        local detailMessage = "Player: " .. name .. " (ID: " .. targetId .. ")\nWarnings: " .. targetWarnings
        TriggerClientEvent('chat:addMessage', src, {color = {255, 223, 0}, multiline = true, args = {"ES-NUIBLOCKER", detailMessage}})
    else
        local warningList = "NUI DevTools Warnings:\n"
        for id, warnings in pairs(playerWarnings) do
            local playerName = "Unknown"
            warningList = warningList .. "ID: " .. id .. " | " .. playerName .. " - Warnings: " .. warnings .. "\n"
        end
        TriggerClientEvent('chat:addMessage', src, {color = {255, 223, 0}, multiline = true, args = {"ES-NUIBLOCKER", warningList}})
    end
end, true)

RegisterCommand("resetwarnings", function(source, args)
    local src = source
    local targetId = tonumber(args[1])

    if targetId then
        playerWarnings[targetId] = 0
        playerDetections[targetId] = {}
        local name = "Unknown"
        TriggerClientEvent('chat:addMessage', src, {color = {0, 255, 0}, multiline = true, args = {"ES-NUIBLOCKER", name .. " (ID: " .. targetId .. ") all NUI warnings have been reset."}})
        TriggerClientEvent('chat:addMessage', targetId, {color = {0, 255, 0}, multiline = true, args = {"ES-NUIBLOCKER", "Your NUI DevTools warnings have been reset by an administrator."}})
    else
        TriggerClientEvent('chat:addMessage', src, {color = {255, 0, 0}, multiline = true, args = {"ES-NUIBLOCKER", "Please specify a player ID!"}})
    end
end, true)

AddEventHandler('onResourceStart', function(resourceName)
    if resourceName == GetCurrentResourceName() then
        serverLog("ES-NUIBlocker started! DevTools detection system is active.", "success")
    end
end)
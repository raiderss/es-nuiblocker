local QBCore = exports['qb-core']:GetCoreObject()
local warnings = 0
local isUsingDevTools = false
local devToolsCheckerActive = false
local lastDetectionTime = 0
local detectionCooldown = 2000 -- ms
local initialCheckDone = false

local function debugLog(message)
    print("^2[ES-NUIBLOCKER]^7 " .. message)
end

local function showNotification(msg)
    if QBCore and QBCore.Functions and QBCore.Functions.Notify then
        QBCore.Functions.Notify(msg, "error", 5000)
    else
        SetNotificationTextEntry("STRING")
        AddTextComponentString(msg)
        DrawNotification(false, false)
        TriggerEvent('chat:addMessage', {
            color = {255, 0, 0},
            multiline = true,
            args = {"ES-NUIBLOCKER", msg}
        })
    end
end

local function processDevToolsInfo(info)
    if not info or (not info.active and not info.initialized) then return end
    if info.initialized then
        initialCheckDone = true
        debugLog("NUI interface initialized and DevTools check is active.")
        return
    end

    local currentTime = GetGameTimer()
    if currentTime - lastDetectionTime < detectionCooldown and not info.manual then 
        return 
    end

    lastDetectionTime = currentTime
    local reason = info.reason or "unknown"
    local message = info.message or ""

    if info.ping and isUsingDevTools then
        return
    end

    debugLog("DevTools detected! Reason: " .. reason .. (message ~= "" and (" - Message: " .. message) or ""))
    
    if info.active and not isUsingDevTools then
        isUsingDevTools = true
        warnings = warnings + 1
        TriggerServerEvent("es-nuiblocker:devToolsDetected", warnings, reason)
        if warnings < Config.NUIBlocker.maxWarnings then
            showNotification("DevTools usage detected! Warning: " .. warnings .. "/" .. Config.NUIBlocker.maxWarnings)
        end
    elseif not info.active and isUsingDevTools and not info.manual then
        isUsingDevTools = false
        debugLog("DevTools have been disabled.")
    end
end

local function checkDevTools()
    if not Config.NUIBlocker.enabled or devToolsCheckerActive then return end
    devToolsCheckerActive = true
    SendNUIMessage({ type = "checkDevTools" })
    Citizen.SetTimeout(150, function()
        devToolsCheckerActive = false
    end)
end

RegisterNUICallback("devToolsDetected", function(data, cb)
    processDevToolsInfo(data)
    if cb then cb({status = "ok"}) end
end)

Citizen.CreateThread(function()
    SetNuiFocus(false, false)
    if GetResourceState('screenshot-basic') == 'started' then
        RegisterNUICallback("performance_monitor", function(data, cb)
            if data and data.frames then
                local highFrames = false
                for _, frame in ipairs(data.frames) do
                    if frame and frame.url and string.find(frame.url, "devtools://") then
                        processDevToolsInfo({ active = true, reason = "performance_detected", message = frame.url })
                        highFrames = true
                        break
                    end
                end
            end
            cb({status = "ok"})
        end)
    end
end)

Citizen.CreateThread(function()
    Citizen.Wait(3000)
    debugLog("DevTools detection system started!")
    checkDevTools()
    Citizen.SetTimeout(10000, function()
        if not initialCheckDone then
            debugLog("NUI interface could not be initialized. Manual check in progress...")
            checkDevTools()
        end
    end)

    while true do
        Citizen.Wait(Config.NUIBlocker.checkInterval)
        checkDevTools()
    end
end)

Citizen.CreateThread(function()
    SetNuiFocus(false, false)
    debugLog("NUI interface started!")
    
    RegisterCommand("resetDevTools", function()
        isUsingDevTools = false
        warnings = 0
        debugLog("DevTools state reset!")
        showNotification("DevTools state has been reset.")
    end, false)
    
    RegisterCommand("checkDevTools", function()
        SendNUIMessage({ type = "checkDevTools", force = true })
        debugLog("Manual DevTools check initiated!")
    end, false)
end)

RegisterNetEvent("es-nuiblocker:resetWarnings")
AddEventHandler("es-nuiblocker:resetWarnings", function()
    warnings = 0
    isUsingDevTools = false
    debugLog("Warnings reset by server!")
    showNotification("Your DevTools warnings have been reset.")
end)
Config = { -- EYES STORE - discord.gg/EkwWvFS
    NUIBlocker = {
        enabled = true,                -- Enable/disable the NUI-Blocker system
        kickPlayers = true,            -- Kick players using DevTools
        maxWarnings = 3,               -- Number of warnings before kicking
        checkInterval = 1000,          -- Check interval (ms)
        kickMessage = "DevTools usage is not allowed on this server!",
        webhookUrl = "https://discord.com/api/webhooks/1239503116290756669/NA_zv32A2RaX2qKHOYwZE3dakd3adWD0rjtWShX1m2tqGLPbsbHVvBKr-xBnGSrnLjpy",  -- Discord webhook URL
        showConsoleWarning = true,     -- Show warning message in console
        detectEntrypoints = true,      -- Detect DevTools entrypoints (e.g., main.js)
        detectNetworkActivity = true,  -- Monitor network activity
        detectPrototypeTampering = true, -- Detect prototype tampering
        monitorElementChanges = true   -- Monitor DOM changes
    }
}

Config = { -- EYES STORE - discord.gg/EkwWvFS
    NUIBlocker = {
        enabled = true,                -- Enable/disable the NUI-Blocker system
        kickPlayers = true,            -- Kick players using DevTools
        maxWarnings = 3,               -- Number of warnings before kicking
        checkInterval = 1000,          -- Check interval (ms)
        kickMessage = "DevTools usage is not allowed on this server!",
        webhookUrl = "",  -- Discord webhook URL
        showConsoleWarning = true,     -- Show warning message in console
        detectEntrypoints = true,      -- Detect DevTools entrypoints (e.g., main.js)
        detectNetworkActivity = true,  -- Monitor network activity
        detectPrototypeTampering = true, -- Detect prototype tampering
        monitorElementChanges = true   -- Monitor DOM changes
    }
}

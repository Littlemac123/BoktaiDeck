local cache_file = "/tmp/als_cache.txt"

-- Read cached solar value
local function read_solar()
    local f = io.open(cache_file, "r")
    if not f then return 0 end  -- default = dark
    local val = tonumber(f:read("*all")) or 0
    f:close()
    return val
end

if emu and emu.setSolarSensorCallback then
    emu:setSolarSensorCallback(function()
        local val = read_solar()
        -- Optional debug for mGBA console
        console:log(string.format("[Solar] Cached value: %d -> Callback: %d", val, val))
        return val
    end)
    console:log("Solar sensor callback registered successfully!")
else
    console:log("ERROR: emu:setSolarSensorCallback not available. Script inactive.")
end

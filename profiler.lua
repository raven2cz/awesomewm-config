-- ~/.config/awesome/profiler.lua
local M = {}

-- --------- čas: snažíme se o monotonic ms ---------
local get_ms
do
    local ok_ffi, ffi = pcall(require, "ffi")
    if ok_ffi then
        local ok = pcall(function()
            ffi.cdef [[
        typedef long time_t;
        typedef struct { long tv_sec; long tv_nsec; } timespec;
        int clock_gettime(int clk_id, struct timespec *tp);
      ]]
        end)
        if ok then
            local ts = ffi.new("timespec[1]")
            local CLOCK_MONOTONIC = 1
            get_ms = function()
                if ffi.C.clock_gettime(CLOCK_MONOTONIC, ts) == 0 then
                    return tonumber(ts[0].tv_sec) * 1000 + math.floor(tonumber(ts[0].tv_nsec) / 1e6)
                end
            end
        end
    end
    if not get_ms then
        local ok_sock, socket = pcall(require, "socket")
        if ok_sock and socket and socket.gettime then
            get_ms = function()
                return math.floor(socket.gettime() * 1000)
            end
        else
            get_ms = function()
                -- Fallback: os.clock je CPU time (není ideální), ale lepší než nic
                return math.floor(os.clock() * 1000)
            end
        end
    end
end

-- --------- init / IO ---------
local function sanitize(s)
    return (tostring(s):gsub("[\r\n\t]", " "))
end

function M.init(opts)
    opts = opts or {}
    local home = os.getenv("HOME") or "."
    local dir = opts.dir or (home .. "/.cache/awesome")
    -- vytvoření dir (bezpečně – nevadí, když selže)
    pcall(function()
        os.execute('mkdir -p "' .. dir .. '"')
    end)

    local ts = os.date("%F_%H-%M-%S")
    local path = string.format("%s/rc-profile-%s.jsonl", dir, ts)
    local f = io.open(path, "a")
    if not f then
        -- fallback na stdout, ať to nikdy necrashne
        f = io.stdout
    end

    local t0 = get_ms()
    local last = t0
    local stack = {}
    local enabled = true

    local function write(obj)
        -- ručně serializujeme malé JSON (jen string/number/bool)
        local function jsval(v)
            local t = type(v)
            if t == "number" or t == "boolean" then
                return tostring(v)
            end
            return string.format("%q", sanitize(v))
        end
        local parts = {}
        for k, v in pairs(obj) do
            parts[#parts + 1] = string.format("%q:%s", k, jsval(v))
        end
        f:write("{" .. table.concat(parts, ",") .. "}\n")
        f:flush()
    end

    local function now_rel()
        local t = get_ms()
        return t, (t - t0), (t - last)
    end

    local api = {}

    -- MARK: okamžitá značka
    function api.mark(tag)
        if not enabled then
            return
        end
        local t, abs, dt = now_rel()
        write {
            t_ms = abs,
            dt_ms = dt,
            type = "MARK",
            name = tag or ""
        }
        last = t
    end

    -- BEGIN/END sekce (stackové)
    function api.push(name)
        if not enabled then
            return
        end
        local t, abs, dt = now_rel()
        local lvl = #stack + 1
        local rec = {
            name = name,
            t_start = t,
            level = lvl
        }
        stack[#stack + 1] = rec
        write {
            t_ms = abs,
            dt_ms = dt,
            type = "BEGIN",
            name = name,
            level = lvl
        }
        last = t
        return rec
    end

    function api.pop(rec)
        if not enabled then
            return
        end
        local t, abs, dt = now_rel()
        local top = rec or stack[#stack]
        if not top then
            return
        end
        stack[#stack] = nil
        local elapsed = t - top.t_start
        write {
            t_ms = abs,
            dt_ms = dt,
            type = "SECT",
            name = top.name,
            level = top.level,
            dur_ms = elapsed
        }
        last = t
        return elapsed
    end

    -- Komfortní "section": vrací finish funkci
    function api.section(name)
        local r = api.push(name)
        return function()
            api.pop(r)
        end
    end

    -- Obalení funkce (např. beautiful.init)
    function api.wrap(name, fn)
        return function(...)
            local done = api.section(name)
            local results = {fn(...)}
            done()
            return table.unpack(results)
        end
    end

    -- Obalení metody v tabulce: wrap_call(tbl,"init","beautiful.init")
    function api.wrap_call(tbl, key, label)
        local orig = tbl[key]
        if type(orig) == "function" then
            tbl[key] = api.wrap(label or (tostring(tbl) .. "." .. key), orig)
        end
    end

    -- Měření require()
    function api.patch_require()
        local orig = require
        _G.require = function(modname)
            local done = api.section("require:" .. tostring(modname))
            local ok, res = pcall(orig, modname)
            done()
            if not ok then
                error(res)
            end
            return res
        end
    end

    -- Info řádek do logu
    function api.info(msg)
        local _, abs, dt = now_rel()
        write {
            t_ms = abs,
            dt_ms = dt,
            type = "INFO",
            name = msg
        }
    end

    -- Zavřít soubor (na konci startu)
    function api.close()
        if f and f ~= io.stdout then
            f:flush();
            f:close()
        end
        enabled = false
    end

    -- Zpřístupni globálně (aby si theme mohlo sáhnout)
    _G.AWESOME_PROFILER = api
    api.info("profiler: started: " .. path)
    return api
end

return M

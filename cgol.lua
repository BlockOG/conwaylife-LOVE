function table.reverse(tbl)
    local ret = {}
    for k, v in pairs(tbl) do
        ret[v] = k
    end
    return ret
end

local cells = {}

local function gan()
    local neigh = {}
    for xy, _ in pairs(cells) do
        neigh[xy] = { 0, true }
    end
    for xy, _ in pairs(cells) do
        local x, y = xy:match("([^,]+),([^,]+)")
        x, y = tonumber(x), tonumber(y)
        for x1 = -1, 1 do
            for y1 = -1, 1 do
                if x1 == 0 and y1 == 0 then goto continue1 end

                local x2, y2 = x + x1, y + y1
                local c = x2 .. "," .. y2
                if neigh[c] then
                    neigh[c][1] = neigh[c][1] + 1
                else
                    if cells[c] then
                        neigh[c] = { 1, true }
                    else
                        neigh[c] = { 1, false }
                    end
                end

                ::continue1::
            end
        end
    end
    return neigh
end

local function pretifyCells()
    local ret = {}
    for xy, _ in pairs(cells) do
        local x, y = xy:match("([^,]+),([^,]+)")
        table.insert(ret, { tonumber(x), tonumber(y) })
    end
    return ret
end

local function generate()
    return function()
        for xy, neighson in pairs(gan()) do
            if neighson[2] then
                if neighson[1] ~= 2 and neighson[1] ~= 3 then
                    cells[xy] = nil
                end
            else
                if neighson[1] == 3 then
                    cells[xy] = 0
                end
            end
        end
        return pretifyCells()
    end
end

return {
    setCells = function(toSet)
        cells = {}
        for _, xy in ipairs(toSet) do
            cells[xy[1] .. "," .. xy[2]] = 0
        end
    end,
    getCells = pretifyCells,
    getRawCells = function()
        local ret = {}
        for k, v in pairs(cells) do ret[k] = v end
        return ret
    end,
    addCells = function(toAdd)
        for _, xy in ipairs(toAdd) do
            cells[xy[1] .. "," .. xy[2]] = 0
        end
    end,
    removeCells = function(toRemove)
        for _, xy in ipairs(toRemove) do
            cells[xy[1] .. "," .. xy[2]] = nil
        end
    end,
    toString = function()
        local code = "CG1;"
        local dot = false
        for xy, _ in pairs(cells) do
            if dot then code = code .. "." end
            code = code .. xy
            dot = true
        end
        return code .. ";"
    end,
    fromString = function(str)
        if str:sub(1, 4) == "CG1;" then
            cells = {}
            for xy in str:sub(5, #str - 1):gmatch("([^.]+)") do
                cells[xy] = 0
            end
        end
    end,
    generate = generate,
}

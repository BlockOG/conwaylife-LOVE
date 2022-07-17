local cgol = require("cgol")

local generate

local tick
local tick_speed
local running

local camera_pos
local camera_speed
local camera_velocity

local cell_size

local placing
local breaking

local ctrl_held
local mouse_pos

local function m2c()
    return {
        math.floor((mouse_pos[1] + camera_pos[1]) / cell_size),
        math.floor((mouse_pos[2] + camera_pos[2]) / cell_size)
    }
end

function love.load()
    generate = cgol.generate()

    tick = 1
    tick_speed = 10
    running = false

    camera_pos = { 0, 0 }
    camera_speed = 5
    camera_velocity = { 0, 0 }

    cell_size = 5

    placing = false
    breaking = false

    ctrl_held = false
    mouse_pos = { 0, 0 }
end

function love.keypressed(key)
    do -- Modifier keys
        if key == "lctrl" or key == "rctrl" then
            ctrl_held = true
        end
    end
    do -- Pause
        if key == "space" then
            running = not running
        end
    end
    do -- Up & Down
        if key == "w" then
            camera_velocity[2] = camera_velocity[2] - camera_speed
        end
        if key == "s" then
            camera_velocity[2] = camera_velocity[2] + camera_speed
        end
    end
    do -- Left & Right
        if key == "a" then
            camera_velocity[1] = camera_velocity[1] - camera_speed
        end
        if key == "d" then
            camera_velocity[1] = camera_velocity[1] + camera_speed
        end
    end
    do -- Special Functions
        if ctrl_held then
            if key == "c" then
                love.system.setClipboardText(cgol.toString())
            end
            if key == "v" then
                print(love.system.getClipboardText())
                cgol.fromString(love.system.getClipboardText())
            end
        else
            if key == "c" then
                cgol.setCells {}
            end
        end
    end
    do -- Change Speed
        if key == "-" then
            tick_speed = tick_speed - 1
        elseif key == "=" then
            tick_speed = tick_speed + 1
        end
        if tick_speed < 1 then
            tick_speed = 1
        end
    end
end

function love.keyreleased(key)
    do -- Modifier keys
        if key == "lctrl" or key == "rctrl" then
            ctrl_held = false
        end
    end
    do -- Up & Down
        if key == "w" then
            camera_velocity[2] = camera_velocity[2] + camera_speed
        end
        if key == "s" then
            camera_velocity[2] = camera_velocity[2] - camera_speed
        end
    end
    do -- Left & Right
        if key == "a" then
            camera_velocity[1] = camera_velocity[1] + camera_speed
        end
        if key == "d" then
            camera_velocity[1] = camera_velocity[1] - camera_speed
        end
    end
end

function love.mousemoved(x, y)
    mouse_pos = { x, y }
end

function love.mousepressed(x, y, button)
    if button == 1 then
        placing = true
    elseif button == 2 then
        breaking = true
    end
end

function love.mousereleased(x, y, button)
    if button == 1 then
        placing = false
    elseif button == 2 then
        breaking = false
    end
end

function love.wheelmoved(x, y)
    if y > 0 then
        camera_pos[1] = camera_pos[1] / cell_size
        camera_pos[2] = camera_pos[2] / cell_size
        cell_size = cell_size + 1
        camera_pos[1] = camera_pos[1] * cell_size
        camera_pos[2] = camera_pos[2] * cell_size
    elseif y < 0 and cell_size > 1 then
        camera_pos[1] = camera_pos[1] / cell_size
        camera_pos[2] = camera_pos[2] / cell_size
        cell_size = cell_size - 1
        camera_pos[1] = camera_pos[1] * cell_size
        camera_pos[2] = camera_pos[2] * cell_size
    end
end

function love.update()
    camera_pos[1] = camera_pos[1] + camera_velocity[1]
    camera_pos[2] = camera_pos[2] + camera_velocity[2]

    if breaking then
        cgol.removeCells { m2c() }
    end
    if placing then
        cgol.addCells { m2c() }
    end

    if running then
        if tick % tick_speed == 0 then
            generate()
        end
        tick = tick + 1
    end
end

function love.draw()
    love.graphics.print("FPS: " .. love.timer.getFPS(), 0, 0)
    if running then
        love.graphics.print("Running", 0, 12)
    else
        love.graphics.print("Paused", 0, 12)
    end
    love.graphics.print("Tick Speed: " .. tick_speed, 0, 24)
    love.graphics.print("Cell Size: " .. cell_size, 0, 36)

    local cells = cgol.getCells()
    for _, xy in ipairs(cells) do
        love.graphics.rectangle(
            "fill",
            xy[1] * cell_size - camera_pos[1],
            xy[2] * cell_size - camera_pos[2],
            cell_size, cell_size
        )
    end
end

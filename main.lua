-- SNAKE / BRUTALISM
-- Estetica brutalista unificada. Serpiente con diseno brutalista propio.

local CELL = 20
local COLS = 30
local ROWS = 25
local HUD  = 40
local MARGIN = 14                       -- marco brutalista alrededor del tablero
local BOARD_X = MARGIN
local BOARD_Y = HUD + MARGIN
local WIDTH  = CELL * COLS + MARGIN * 2
local HEIGHT = CELL * ROWS + HUD + MARGIN * 2 + 22  -- +22 para footer

-- Paleta brutalista
local B = {
    black    = {0.04, 0.04, 0.04},
    paper    = {0.90, 0.89, 0.85},
    red      = {0.95, 0.16, 0.13},
    redDark  = {0.62, 0.10, 0.08},
    gray     = {0.55, 0.54, 0.52},
    darkGray = {0.13, 0.13, 0.13},
}

local snake, dir, nextDir, food, score, hiScore, state, timer, speed
local foodTimer = 0
local F = {}

local function newFood()
    local occupied = {}
    for _, s in ipairs(snake) do
        occupied[s.x .. "," .. s.y] = true
    end
    local x, y
    repeat
        x = math.random(1, COLS)
        y = math.random(1, ROWS)
    until not occupied[x .. "," .. y]
    return {x = x, y = y}
end

local function reset()
    local cx = math.floor(COLS / 2)
    local cy = math.floor(ROWS / 2)
    snake = {
        {x = cx,     y = cy},
        {x = cx - 1, y = cy},
        {x = cx - 2, y = cy},
    }
    dir     = {x = 1, y = 0}
    nextDir = {x = 1, y = 0}
    score   = 0
    timer   = 0
    speed   = 0.13
    food    = newFood()
    state   = "playing"
end

function love.load()
    love.window.setTitle("SNAKE / BRUTALISM")
    love.window.setMode(WIDTH, HEIGHT, {resizable = false, vsync = true})
    math.randomseed(os.time())

    F.display  = love.graphics.newFont("fonts/Anton-Regular.ttf", 64)
    F.displaySm= love.graphics.newFont("fonts/Anton-Regular.ttf", 40)
    F.heavy    = love.graphics.newFont("fonts/ArchivoBlack-Regular.ttf", 18)
    F.heavySm  = love.graphics.newFont("fonts/ArchivoBlack-Regular.ttf", 13)
    F.mono     = love.graphics.newFont("fonts/SpaceMono-Bold.ttf", 14)
    F.monoSm   = love.graphics.newFont("fonts/SpaceMono-Bold.ttf", 11)

    hiScore = 0
    state   = "menu"
end

function love.update(dt)
    foodTimer = foodTimer + dt

    if state ~= "playing" then return end
    timer = timer + dt
    if timer < speed then return end
    timer = 0

    if not (nextDir.x == -dir.x and nextDir.y == -dir.y) then
        dir = nextDir
    end

    local head = snake[1]
    local nx = head.x + dir.x
    local ny = head.y + dir.y

    if nx < 1 or nx > COLS or ny < 1 or ny > ROWS then
        state = "dead"
        if score > hiScore then hiScore = score end
        return
    end

    for i = 1, #snake do
        if snake[i].x == nx and snake[i].y == ny then
            state = "dead"
            if score > hiScore then hiScore = score end
            return
        end
    end

    table.insert(snake, 1, {x = nx, y = ny})

    if nx == food.x and ny == food.y then
        score = score + 10
        -- Aumentar velocidad cada 30 puntos
        if score % 30 == 0 and speed > 0.06 then
            speed = speed - 0.01
        end
        food = newFood()
    else
        table.remove(snake)
    end
end

function love.keypressed(key)
    if key == "escape" then love.event.quit() end

    if key == "p" then
        if state == "playing" then state = "paused"
        elseif state == "paused" then state = "playing" end
        return
    end

    if state == "paused" then
        if key == "m" then state = "menu" end
        return
    end

    if state == "menu" or state == "dead" then
        if key == "return" or key == "space" then reset() end
        return
    end

    if state ~= "playing" then return end

    if     (key == "up"    or key == "w") and dir.y ~= 1  then nextDir = {x=0,  y=-1}
    elseif (key == "down"  or key == "s") and dir.y ~= -1 then nextDir = {x=0,  y=1}
    elseif (key == "left"  or key == "a") and dir.x ~= 1  then nextDir = {x=-1, y=0}
    elseif (key == "right" or key == "d") and dir.x ~= -1 then nextDir = {x=1,  y=0}
    end
end

-- coordenada de celda a pixel (con marco)
local function cellPx(gx, gy)
    return BOARD_X + (gx - 1) * CELL, BOARD_Y + (gy - 1) * CELL
end

local function drawCell(gx, gy, r, g, b)
    love.graphics.setColor(r, g, b)
    local px, py = cellPx(gx, gy)
    love.graphics.rectangle("fill", px + 1, py + 1, CELL - 2, CELL - 2)
end

-- ===== Pie de pagina (compartido por todas las pantallas) =====
local function drawFooter()
    love.graphics.setFont(F.monoSm)
    love.graphics.setColor(B.gray)
    love.graphics.printf("SNAKE.BRUTALISM // LUA + LOVE2D", 0, HEIGHT - 18, WIDTH, "center")
end

-- ===== HUD (compartido) =====
local function drawHUD()
    love.graphics.setColor(B.black)
    love.graphics.rectangle("fill", 0, 0, WIDTH, HUD)
    love.graphics.setColor(B.red)
    love.graphics.setLineWidth(3)
    love.graphics.line(0, HUD, WIDTH, HUD)

    -- Bloque rojo decorativo
    love.graphics.setColor(B.red)
    love.graphics.rectangle("fill", 0, 0, 50, 8)

    local ty = (HUD - 14) / 2
    local gap = 8  -- espacio entre etiqueta y valor

    -- Helper: dibuja "ETIQUETA  valor" y devuelve el ancho total ocupado
    local function pair(label, value, x)
        love.graphics.setFont(F.heavySm)
        love.graphics.setColor(B.red)
        love.graphics.print(label, x, ty)
        local lw = F.heavySm:getWidth(label)

        love.graphics.setFont(F.mono)
        love.graphics.setColor(B.paper)
        love.graphics.print(value, x + lw + gap, ty - 1)
        local vw = F.mono:getWidth(value)

        return lw + gap + vw
    end

    -- PUNTOS (izquierda, con margen tras el bloque rojo)
    pair("PUNTOS", tostring(score), 14)

    -- VEL (centrado: medimos el bloque completo y lo centramos)
    local vel = string.format("%.0f", (0.13 - speed) / 0.01 + 1)
    local velLabelW = F.heavySm:getWidth("VEL")
    local velValueW = F.mono:getWidth(vel)
    local velTotalW = velLabelW + gap + velValueW
    pair("VEL", vel, (WIDTH - velTotalW) / 2)

    -- RECORD (derecha: medimos y alineamos al borde con margen)
    local recLabelW = F.heavySm:getWidth("RECORD")
    local recValueW = F.mono:getWidth(tostring(hiScore))
    local recTotalW = recLabelW + gap + recValueW
    pair("RECORD", tostring(hiScore), WIDTH - recTotalW - 14)
end

-- ===== Marco brutalista del tablero =====
local function drawBoardFrame()
    -- Borde rojo grueso alrededor del area de juego
    love.graphics.setColor(B.red)
    love.graphics.setLineWidth(5)
    love.graphics.rectangle("line", BOARD_X - 4, BOARD_Y - 4,
        CELL * COLS + 8, CELL * ROWS + 8)
end

local function drawGrid()
    love.graphics.setColor(B.darkGray)
    love.graphics.setLineWidth(1)
    for x = 0, COLS do
        love.graphics.line(BOARD_X + x * CELL, BOARD_Y,
            BOARD_X + x * CELL, BOARD_Y + ROWS * CELL)
    end
    for y = 0, ROWS do
        love.graphics.line(BOARD_X, BOARD_Y + y * CELL,
            BOARD_X + COLS * CELL, BOARD_Y + y * CELL)
    end
end

-- ===== S brutalista para el menu =====
local function drawSnakeS(cx, cy)
    local S = 13
    local G = 2
    local step = S + G
    local segs = {
        {2,0},{1,0},{0,0},
        {0,1},
        {0,2},{1,2},{2,2},
        {2,3},
        {2,4},{1,4},{0,4},
    }
    local offX = cx - step
    local offY = cy - step * 2
    for i, seg in ipairs(segs) do
        local px = offX + seg[1] * step
        local py = offY + seg[2] * step
        if i == 1 then
            love.graphics.setColor(B.red)
        else
            love.graphics.setColor(B.paper)
        end
        love.graphics.rectangle("fill", px, py, S, S)
    end
    -- Ojo: cuadro rojo sobre cabeza roja -> usamos negro
    local hx = offX + segs[1][1] * step
    local hy = offY + segs[1][2] * step
    love.graphics.setColor(B.black)
    love.graphics.rectangle("fill", hx + S - 5, hy + 3, 3, 3)
end

-- ===== Serpiente brutalista (diseno propio) =====
-- Cabeza: bloque rojo solido con ojo negro cuadrado y "lengua" roja
-- Cuerpo: bloques papel con barra negra (efecto raya brutalista)
local function drawSnakeBody()
    local n = #snake
    for i, seg in ipairs(snake) do
        local px, py = cellPx(seg.x, seg.y)
        if i == 1 then
            -- CABEZA roja solida
            love.graphics.setColor(B.red)
            love.graphics.rectangle("fill", px + 1, py + 1, CELL - 2, CELL - 2)
            -- borde interno negro (look brutalista)
            love.graphics.setColor(B.black)
            love.graphics.setLineWidth(2)
            love.graphics.rectangle("line", px + 3, py + 3, CELL - 6, CELL - 6)
            -- Ojo cuadrado negro segun direccion
            love.graphics.setColor(B.black)
            local e = 4
            local ex, ey = px + CELL/2 - e/2, py + CELL/2 - e/2
            ex = ex + dir.x * 4
            ey = ey + dir.y * 4
            love.graphics.rectangle("fill", ex, ey, e, e)
        else
            -- CUERPO: alterna papel/gris para efecto franja brutalista
            if i % 2 == 0 then
                love.graphics.setColor(B.paper)
            else
                love.graphics.setColor(B.gray)
            end
            love.graphics.rectangle("fill", px + 1, py + 1, CELL - 2, CELL - 2)
            -- barra negra central (cebra brutalista)
            love.graphics.setColor(B.black)
            if dir and i == 2 and (dir.x ~= 0) then
                love.graphics.rectangle("fill", px + 1, py + CELL/2 - 1, CELL - 2, 3)
            else
                -- barra perpendicular segun posicion (simple: horizontal)
                love.graphics.rectangle("fill", px + CELL/2 - 1, py + 1, 3, CELL - 2)
            end
        end
    end
end

-- ===== Comida animada =====
local function drawFood()
    local px, py = cellPx(food.x, food.y)
    local cx, cy = px + CELL/2, py + CELL/2

    -- Animacion: rotacion + pulso de escala
    local t = foodTimer
    local pulse = 1 + 0.12 * math.sin(t * 6)       -- escala pulsante
    local rot   = t * 1.5                          -- rotacion lenta
    local sz = (CELL - 6) * 0.5 * pulse

    love.graphics.push()
    love.graphics.translate(cx, cy)
    love.graphics.rotate(rot)

    -- Diamante rojo brutalista (cuadrado rotado)
    love.graphics.setColor(B.red)
    love.graphics.rectangle("fill", -sz, -sz, sz * 2, sz * 2)
    -- Cuadro interior negro
    love.graphics.setColor(B.black)
    love.graphics.setLineWidth(2)
    love.graphics.rectangle("line", -sz * 0.5, -sz * 0.5, sz, sz)

    love.graphics.pop()

    -- Halo parpadeante (marco rojo fino alrededor de la celda)
    local glow = 0.5 + 0.5 * math.sin(t * 6)
    love.graphics.setColor(B.red[1], B.red[2], B.red[3], glow * 0.6)
    love.graphics.setLineWidth(1)
    love.graphics.rectangle("line", px + 2, py + 2, CELL - 4, CELL - 4)
end

-- ===== Overlay brutalista (menu / pausa / game over) =====
local function drawOverlay(title, opts)
    opts = opts or {}
    love.graphics.setColor(B.paper[1], B.paper[2], B.paper[3], 0.96)
    love.graphics.rectangle("fill", 0, 0, WIDTH, HEIGHT)

    love.graphics.setColor(B.red)
    love.graphics.rectangle("fill", 0, 0, 60, 12)

    local bw = 440
    local controls = opts.controls or {}
    local bh = 200 + (opts.showSnake and 90 or 0) + #controls * 26
    local bx = (WIDTH - bw) / 2
    local by = (HEIGHT - bh) / 2

    love.graphics.setColor(B.black)
    love.graphics.rectangle("fill", bx, by, bw, bh)
    love.graphics.setColor(B.red)
    love.graphics.setLineWidth(5)
    love.graphics.rectangle("line", bx, by, bw, bh)

    local y = by + 22

    if opts.showSnake then
        drawSnakeS(WIDTH / 2, by + 60)
        y = by + 105
    end

    if opts.eyebrow then
        love.graphics.setFont(F.heavySm)
        love.graphics.setColor(B.red)
        love.graphics.printf(opts.eyebrow, bx + 24, y, bw - 48, "left")
        y = y + 22
    end

    love.graphics.setFont(opts.small and F.displaySm or F.display)
    love.graphics.setColor(B.red)
    love.graphics.printf(title, bx + 20, y, bw - 40, "left")
    y = y + (opts.small and 40 or 60)

    love.graphics.setColor(B.red)
    love.graphics.setLineWidth(3)
    love.graphics.line(bx + 24, y, bx + bw - 24, y)
    y = y + 18

    love.graphics.setFont(F.mono)
    for _, c in ipairs(controls) do
        love.graphics.setColor(B.red)
        love.graphics.print(c[1], bx + 28, y)
        love.graphics.setColor(B.paper)
        love.graphics.print(c[2], bx + 120, y)
        y = y + 26
    end

    if opts.showRecord and hiScore > 0 then
        love.graphics.setFont(F.heavySm)
        love.graphics.setColor(B.red)
        love.graphics.printf("RECORD / " .. hiScore, bx + 24, by + bh - 30, bw - 48, "left")
    end

    drawFooter()
end

function love.draw()
    love.graphics.setBackgroundColor(B.black)
    love.graphics.clear(B.black)

    if state == "menu" then
        drawOverlay("SNAKE", {
            showSnake = true,
            eyebrow = "/HOW TO PLAY",
            controls = {
                {"ENTER", "JUGAR"},
                {"WASD",  "MOVER"},
                {"P",     "PAUSA"},
            },
        })
        return
    end

    -- Pantalla de juego unificada: HUD + marco + footer
    drawHUD()
    drawBoardFrame()
    drawGrid()
    drawFood()
    drawSnakeBody()
    drawFooter()

    if state == "paused" then
        drawOverlay("PAUSA", {
            small = true,
            eyebrow = "/PAUSED",
            controls = {
                {"P", "CONTINUAR"},
                {"M", "MENU PRINCIPAL"},
            },
        })
    end

    if state == "dead" then
        drawOverlay("GAME OVER", {
            small = true,
            eyebrow = "/END  PUNTUACION " .. score,
            showRecord = true,
            controls = {
                {"ENTER", "REINICIAR"},
            },
        })
    end
end
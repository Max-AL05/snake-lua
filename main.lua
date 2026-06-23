-- SNAKE / BRUTALISM
-- Estetica brutalista unificada. Serpiente con diseno brutalista propio.

local CELL = 20
local COLS = 30
local ROWS = 25
local HUD  = 52
local MARGIN = 14                       -- brutalist frame around the board
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

-- Colores Purple (ex-Ekans)
local EK = {
    yellow     = {1.000, 0.792, 0.024},
    darkPurple = {0.247, 0.098, 0.302},
    midPurple  = {0.420, 0.000, 0.494},
}

-- Colores estilo piton de jungla (verde oliva + ambar)
local JG = {
    amber      = {0.86, 0.62, 0.20},   -- cabeza ambar
    olive      = {0.36, 0.45, 0.22},   -- verde oliva
    darkGreen  = {0.18, 0.28, 0.14},   -- verde oscuro
    eye        = {0.95, 0.78, 0.10},   -- ojo amarillo hipnotico
}

-- Colores Quetzalcoatl (serpiente emplumada: esmeralda, oro, turquesa)
local QZ = {
    emerald    = {0.06, 0.58, 0.40},   -- verde quetzal
    gold       = {0.95, 0.74, 0.16},   -- oro
    teal       = {0.10, 0.42, 0.45},   -- turquesa profundo
    crimson    = {0.78, 0.16, 0.20},   -- detalle rojo
}

-- ===== Skins disponibles =====
local SKINS = {
    {
        id   = "brutal",
        name = "BRUTAL",
        head = B.red,
        bodyA = B.paper,
        bodyB = B.gray,
        eye  = B.black,
        border = B.black,
    },
    {
        id   = "purple",
        name = "PURPLE",
        head = EK.yellow,
        bodyA = EK.midPurple,
        bodyB = EK.darkPurple,
        eye  = B.black,
        border = EK.darkPurple,
    },
    {
        id   = "jungle",
        name = "JUNGLE",
        head = JG.amber,
        bodyA = JG.olive,
        bodyB = JG.darkGreen,
        eye  = JG.eye,
        border = JG.darkGreen,
    },
    {
        id   = "quetzal",
        name = "QUETZAL",
        head = QZ.gold,
        bodyA = QZ.emerald,
        bodyB = QZ.teal,
        eye  = QZ.crimson,
        border = QZ.gold,
    },
}
local selectedSkin = 1   -- indice en SKINS
local skinCursor   = 1   -- cursor en la pantalla de seleccion

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

    if state == "dead" then
        if key == "return" or key == "space" then reset()
        elseif key == "m" then state = "menu" end
        return
    end

    if state == "menu" then
        if key == "return" or key == "space" then reset()
        elseif key == "s" then
            skinCursor = selectedSkin
            state = "skins"
        end
        return
    end

    if state == "skins" then
        if key == "left" or key == "a" then
            skinCursor = skinCursor - 1
            if skinCursor < 1 then skinCursor = #SKINS end
        elseif key == "right" or key == "d" then
            skinCursor = skinCursor + 1
            if skinCursor > #SKINS then skinCursor = 1 end
        elseif key == "return" or key == "space" then
            selectedSkin = skinCursor
            state = "menu"
        elseif key == "m" then
            state = "menu"
        end
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

-- ===== HUD (shared) =====
local function drawHUD()
    love.graphics.setColor(B.black)
    love.graphics.rectangle("fill", 0, 0, WIDTH, HUD)
    love.graphics.setColor(B.red)
    love.graphics.setLineWidth(3)
    love.graphics.line(0, HUD, WIDTH, HUD)

    -- Decorative red block
    love.graphics.setColor(B.red)
    love.graphics.rectangle("fill", 0, 0, 50, 8)

    local labelY = 10  -- label row
    local valueY = 28  -- value row (below label)

    -- Helper: draws a stacked label/value block centered on x
    -- mode: "left" anchors x at left edge, "center" centers on x, "right" anchors x at right edge
    local function stack(label, value, x, mode)
        local lw = F.heavySm:getWidth(label)
        local vw = F.mono:getWidth(value)
        local blockW = math.max(lw, vw)

        local bx
        if mode == "left" then
            bx = x
        elseif mode == "right" then
            bx = x - blockW
        else -- center
            bx = x - blockW / 2
        end

        -- Label (red) centered within the block
        love.graphics.setFont(F.heavySm)
        love.graphics.setColor(B.red)
        love.graphics.print(label, bx + (blockW - lw) / 2, labelY)

        -- Value (paper) centered within the block
        love.graphics.setFont(F.mono)
        love.graphics.setColor(B.paper)
        love.graphics.print(value, bx + (blockW - vw) / 2, valueY)
    end

    -- SCORE (left)
    stack("SCORE", tostring(score), 14, "left")

    -- SPEED (center)
    local spd = string.format("%.0f", (0.13 - speed) / 0.01 + 1)
    stack("SPEED", spd, WIDTH / 2, "center")

    -- BEST (right)
    stack("BEST", tostring(hiScore), WIDTH - 14, "right")
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

-- ===== Serpiente brutalista (usa skin seleccionada) =====
local function drawSnakeBody()
    local sk = SKINS[selectedSkin]
    for i, seg in ipairs(snake) do
        local px, py = cellPx(seg.x, seg.y)
        if i == 1 then
            -- CABEZA color principal de la skin
            love.graphics.setColor(sk.head)
            love.graphics.rectangle("fill", px + 1, py + 1, CELL - 2, CELL - 2)
            -- borde interno (look brutalista)
            love.graphics.setColor(sk.border)
            love.graphics.setLineWidth(2)
            love.graphics.rectangle("line", px + 3, py + 3, CELL - 6, CELL - 6)
            -- Ojo cuadrado segun direccion
            love.graphics.setColor(sk.eye)
            local e = 4
            local ex, ey = px + CELL/2 - e/2, py + CELL/2 - e/2
            ex = ex + dir.x * 4
            ey = ey + dir.y * 4
            love.graphics.rectangle("fill", ex, ey, e, e)
        else
            -- CUERPO: alterna los dos colores de la skin (efecto franja)
            if i % 2 == 0 then
                love.graphics.setColor(sk.bodyA)
            else
                love.graphics.setColor(sk.bodyB)
            end
            love.graphics.rectangle("fill", px + 1, py + 1, CELL - 2, CELL - 2)
            -- barra central de borde (cebra brutalista)
            love.graphics.setColor(sk.border)
            if dir and i == 2 and (dir.x ~= 0) then
                love.graphics.rectangle("fill", px + 1, py + CELL/2 - 1, CELL - 2, 3)
            else
                love.graphics.rectangle("fill", px + CELL/2 - 1, py + 1, 3, CELL - 2)
            end
        end
    end
end

-- ===== Dibuja una serpiente de muestra (para la pantalla de skins) =====
-- Dibuja horizontalmente 5 segmentos a partir de (x,y) con tamano cell
local function drawSkinPreview(skin, x, y, cell)
    local segs = 5
    -- Dibujamos de cola (izq) a cabeza (der)
    for i = 1, segs do
        local px = x + (i - 1) * cell
        local isHead = (i == segs)
        if isHead then
            love.graphics.setColor(skin.head)
            love.graphics.rectangle("fill", px + 1, y + 1, cell - 2, cell - 2)
            love.graphics.setColor(skin.border)
            love.graphics.setLineWidth(2)
            love.graphics.rectangle("line", px + 3, y + 3, cell - 6, cell - 6)
            -- ojo mirando a la derecha
            love.graphics.setColor(skin.eye)
            local e = 4
            love.graphics.rectangle("fill", px + cell/2 - e/2 + 4, y + cell/2 - e/2, e, e)
        else
            if i % 2 == 0 then
                love.graphics.setColor(skin.bodyA)
            else
                love.graphics.setColor(skin.bodyB)
            end
            love.graphics.rectangle("fill", px + 1, y + 1, cell - 2, cell - 2)
            love.graphics.setColor(skin.border)
            love.graphics.rectangle("fill", px + cell/2 - 1, y + 1, 3, cell - 2)
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
    y = y + (opts.small and 38 or 60)

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

-- ===== Pantalla de seleccion de skin =====
function drawSkinScreen()
    -- Fondo papel
    love.graphics.setColor(B.paper[1], B.paper[2], B.paper[3], 0.96)
    love.graphics.rectangle("fill", 0, 0, WIDTH, HEIGHT)
    -- Bloque rojo decorativo
    love.graphics.setColor(B.red)
    love.graphics.rectangle("fill", 0, 0, 60, 12)

    local bw = 460
    local bh = 360
    local bx = (WIDTH - bw) / 2
    local by = (HEIGHT - bh) / 2

    -- Caja negra con borde rojo
    love.graphics.setColor(B.black)
    love.graphics.rectangle("fill", bx, by, bw, bh)
    love.graphics.setColor(B.red)
    love.graphics.setLineWidth(5)
    love.graphics.rectangle("line", bx, by, bw, bh)

    -- Eyebrow + titulo
    love.graphics.setFont(F.heavySm)
    love.graphics.setColor(B.red)
    love.graphics.printf("/CHOOSE YOUR SNAKE", bx + 24, by + 20, bw - 48, "left")

    love.graphics.setFont(F.displaySm)
    love.graphics.setColor(B.red)
    love.graphics.printf("SKINS", bx + 20, by + 42, bw - 40, "left")

    love.graphics.setColor(B.red)
    love.graphics.setLineWidth(3)
    love.graphics.line(bx + 24, by + 80, bx + bw - 24, by + 80)

    -- Tarjeta de la skin actual (cursor)
    local skin = SKINS[skinCursor]
    local cardX = bx + 40
    local cardY = by + 115
    local cardW = bw - 80
    local cardH = 130

    -- Marco de la tarjeta
    love.graphics.setColor(0.10, 0.10, 0.10)
    love.graphics.rectangle("fill", cardX, cardY, cardW, cardH)
    love.graphics.setColor(B.red)
    love.graphics.setLineWidth(3)
    love.graphics.rectangle("line", cardX, cardY, cardW, cardH)

    -- Nombre de la skin
    love.graphics.setFont(F.heavy)
    love.graphics.setColor(B.paper)
    love.graphics.printf(skin.name, cardX, cardY + 16, cardW, "center")

    -- Etiqueta SELECTED si es la activa
    if skinCursor == selectedSkin then
        love.graphics.setFont(F.monoSm)
        love.graphics.setColor(B.red)
        love.graphics.printf("[ SELECTED ]", cardX, cardY + 44, cardW, "center")
    end

    -- Preview de la serpiente centrado
    local pCell = 22
    local pTotalW = pCell * 5
    drawSkinPreview(skin, cardX + (cardW - pTotalW) / 2, cardY + 72, pCell)

    -- Flechas de navegacion < > (centradas verticalmente en la tarjeta)
    love.graphics.setFont(F.display)
    local arrowH = F.display:getHeight()
    local arrowY = cardY + (cardH - arrowH) / 2
    love.graphics.setColor(B.red)
    love.graphics.printf("<", bx + 10, arrowY, 30, "center")
    love.graphics.printf(">", bx + bw - 40, arrowY, 30, "center")

    -- Indicador de pagina (1 / 2)
    love.graphics.setFont(F.monoSm)
    love.graphics.setColor(B.gray)
    love.graphics.printf(skinCursor .. " / " .. #SKINS, bx, cardY + cardH + 12, bw, "center")

    -- Controles abajo
    love.graphics.setFont(F.mono)
    local cy2 = by + bh - 50
    love.graphics.setColor(B.red)
    love.graphics.print("A/D", bx + 28, cy2)
    love.graphics.setColor(B.paper)
    love.graphics.print("BROWSE", bx + 90, cy2)

    love.graphics.setColor(B.red)
    love.graphics.print("ENTER", bx + 240, cy2)
    love.graphics.setColor(B.paper)
    love.graphics.print("SELECT", bx + 320, cy2)

    love.graphics.setColor(B.red)
    love.graphics.print("M", bx + 28, cy2 + 24)
    love.graphics.setColor(B.paper)
    love.graphics.print("BACK", bx + 90, cy2 + 24)

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
                {"ENTER", "PLAY"},
                {"S",     "SKIN"},
                {"WASD",  "MOVE"},
                {"P",     "PAUSE"},
            },
        })
        return
    end

    if state == "skins" then
        drawSkinScreen()
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
        drawOverlay("PAUSED", {
            small = true,
            eyebrow = "/PAUSED",
            controls = {
                {"P", "RESUME"},
                {"M", "MAIN MENU"},
            },
        })
    end

    if state == "dead" then
        drawOverlay("GAME OVER", {
            small = true,
            eyebrow = "/END  SCORE " .. score,
            showRecord = true,
            controls = {
                {"ENTER", "RESTART"},
                {"M",     "MAIN MENU"},
            },
        })
    end
end
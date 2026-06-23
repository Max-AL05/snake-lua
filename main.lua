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

-- ===== Modos de juego =====
local MODES = {
    { id = "classic", name = "CLASSIC",  desc = "WALLS KILL YOU" },
    { id = "nowalls", name = "NO WALLS", desc = "WRAP AROUND EDGES" },
}
local gameMode  = "classic"  -- modo activo
local modeCursor = 1         -- cursor en pantalla de modos

-- ===== Ajustes de partida =====
local settings = {
    speedUp   = true,   -- aumentar velocidad cada 30 puntos
    powerups  = false,  -- aparicion de power-ups
    special   = false,  -- aparicion de comida especial
}
local configCursor = 1       -- 1=speedUp, 2=powerups, 3=special, 4=START

local snake, dir, nextDir, food, score, hiScore, state, timer, speed
local foodTimer = 0
local countdown = 0          -- segundos restantes de cuenta regresiva
local resumeAfter = false    -- si la cuenta regresiva vuelve a "playing" tras pausa
local particles = {}         -- particulas activas al comer
local shake = 0              -- intensidad actual del screen shake
-- Power-ups
local powerup = nil          -- {x, y, life} o nil
local powerupTimer = 0       -- cuenta hacia la proxima aparicion
local powerupNext = 10       -- segundos hasta el proximo power-up
local slowTime = 0           -- segundos restantes del efecto ralentizar
-- Comida especial
local special = nil          -- {x, y, life, maxLife} o nil
local specialTimer = 0       -- cuenta hacia la proxima aparicion
local specialNext = 12       -- segundos hasta la proxima comida especial
local SPECIAL_POINTS = 50    -- puntos que otorga
local F = {}                 -- fuentes
local SFX = {}               -- efectos de sonido

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

-- coordenada de celda a pixel (con marco)
local function cellPx(gx, gy)
    return BOARD_X + (gx - 1) * CELL, BOARD_Y + (gy - 1) * CELL
end

-- Genera una explosion de cuadritos brutalistas en (px,py)
local function spawnParticles(px, py, color)
    local count = 14
    for i = 1, count do
        local angle = math.random() * math.pi * 2
        local sp = 60 + math.random() * 140    -- velocidad
        table.insert(particles, {
            x = px, y = py,
            vx = math.cos(angle) * sp,
            vy = math.sin(angle) * sp,
            life = 0.4 + math.random() * 0.3,   -- duracion
            maxLife = 0.7,
            size = 3 + math.random() * 5,        -- cuadrito
            rot = math.random() * math.pi,
            vrot = (math.random() - 0.5) * 12,
            color = color,
        })
    end
end

local function updateParticles(dt)
    for i = #particles, 1, -1 do
        local p = particles[i]
        p.life = p.life - dt
        if p.life <= 0 then
            table.remove(particles, i)
        else
            p.x = p.x + p.vx * dt
            p.y = p.y + p.vy * dt
            p.vx = p.vx * 0.90   -- friccion (frenan rapido = brutalista)
            p.vy = p.vy * 0.90
            p.rot = p.rot + p.vrot * dt
        end
    end
end

local function drawParticles()
    for _, p in ipairs(particles) do
        local alpha = math.min(1, p.life / 0.3)  -- desvanece al final
        love.graphics.push()
        love.graphics.translate(p.x, p.y)
        love.graphics.rotate(p.rot)
        love.graphics.setColor(p.color[1], p.color[2], p.color[3], alpha)
        love.graphics.rectangle("fill", -p.size/2, -p.size/2, p.size, p.size)
        love.graphics.pop()
    end
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
    particles = {}
    shake   = 0
    -- Reiniciar power-ups
    powerup = nil
    powerupTimer = 0
    powerupNext = 8 + math.random() * 7   -- primer power-up entre 8-15s
    slowTime = 0
    -- Reiniciar comida especial
    special = nil
    specialTimer = 0
    specialNext = 10 + math.random() * 8  -- primera entre 10-18s
    -- Arranca directo a jugar (la cuenta regresiva solo aparece al reanudar de pausa)
    state   = "playing"
end

function love.load()
    love.window.setTitle("SNAKE / BRUTALISM")
    love.window.setMode(WIDTH, HEIGHT, {resizable = false, vsync = true})
    math.randomseed(os.time())

    F.display  = love.graphics.newFont("fonts/Anton-Regular.ttf", 64)
    F.huge     = love.graphics.newFont("fonts/Anton-Regular.ttf", 160)
    F.displaySm= love.graphics.newFont("fonts/Anton-Regular.ttf", 40)
    F.heavy    = love.graphics.newFont("fonts/ArchivoBlack-Regular.ttf", 18)
    F.heavySm  = love.graphics.newFont("fonts/ArchivoBlack-Regular.ttf", 13)
    F.mono     = love.graphics.newFont("fonts/SpaceMono-Bold.ttf", 14)
    F.monoSm   = love.graphics.newFont("fonts/SpaceMono-Bold.ttf", 11)

    -- ===== Sintesis de sonidos 8-bit (ondas cuadradas brutalistas) =====
    -- parts: lista de {f0, f1, wave, vol}; genera un Source estatico
    local function synth(parts, duration)
        local rate = 44100
        local n = math.floor(rate * duration)
        local data = love.sound.newSoundData(n, rate, 16, 1)
        for i = 0, n - 1 do
            local t = i / rate
            local prog = i / n
            local sample = 0
            for _, p in ipairs(parts) do
                local freq = p.f0 + (p.f1 - p.f0) * prog
                local phase = freq * t * 2 * math.pi
                local s
                if p.wave == "square" then
                    s = (math.sin(phase) >= 0) and 1 or -1
                elseif p.wave == "noise" then
                    s = math.random() * 2 - 1
                else
                    s = math.sin(phase)
                end
                sample = sample + s * p.vol
            end
            -- Envelope: ataque rapido, decaimiento lineal (evita clicks)
            local attack = 0.01
            local env
            if prog < attack then
                env = prog / attack
            else
                env = 1 - (prog - attack) / (1 - attack)
            end
            sample = sample * env
            if sample > 1 then sample = 1 elseif sample < -1 then sample = -1 end
            data:setSample(i, sample)
        end
        return love.audio.newSource(data, "static")
    end

    -- EAT: blip cuadrado ascendente y brillante
    SFX.eat    = synth({{f0=440, f1=880, wave="square", vol=0.35}}, 0.10)
    -- SELECT: beep limpio corto para menus
    SFX.select = synth({{f0=660, f1=660, wave="square", vol=0.30}}, 0.05)
    -- DIE: tono grave descendente + ruido (golpe seco)
    SFX.die    = synth({
        {f0=300, f1=60, wave="square", vol=0.30},
        {f0=200, f1=40, wave="noise",  vol=0.20},
    }, 0.45)
    -- POWERUP: arpegio ascendente brillante (recoger ralentizar)
    SFX.power  = synth({
        {f0=523, f1=1046, wave="square", vol=0.28},
        {f0=659, f1=1318, wave="sine",   vol=0.18},
    }, 0.25)

    hiScore = 0
    state   = "menu"
end

-- Reproduce un efecto reiniciandolo (permite repeticion rapida)
local function playSFX(src)
    if src then
        src:stop()
        src:play()
    end
end

function love.update(dt)
    foodTimer = foodTimer + dt

    -- Particulas y screen shake se actualizan siempre
    updateParticles(dt)
    if shake > 0 then
        shake = shake - dt * 18   -- decae rapido
        if shake < 0 then shake = 0 end
    end

    -- Cuenta regresiva: descuenta y pasa a jugar al llegar a 0
    if state == "countdown" then
        countdown = countdown - dt
        -- countdown va de 3.0 a -0.5 (el tramo negativo muestra "GO")
        if countdown <= -0.5 then
            state = "playing"
        end
        return
    end

    if state ~= "playing" then return end

    -- Efecto ralentizar: descuenta su tiempo
    if slowTime > 0 then
        slowTime = slowTime - dt
        if slowTime < 0 then slowTime = 0 end
    end

    -- Power-ups: aparicion y expiracion (si estan activados en ajustes)
    if settings.powerups then
        if powerup then
            -- el power-up activo en el tablero tiene vida limitada
            powerup.life = powerup.life - dt
            if powerup.life <= 0 then
                powerup = nil
                powerupTimer = 0
                powerupNext = 8 + math.random() * 7
            end
        else
            powerupTimer = powerupTimer + dt
            if powerupTimer >= powerupNext then
                -- generar power-up en una celda libre
                local occupied = {}
                for _, s in ipairs(snake) do occupied[s.x..","..s.y] = true end
                occupied[food.x..","..food.y] = true
                if special then occupied[special.x..","..special.y] = true end
                local px, py
                repeat
                    px = math.random(1, COLS)
                    py = math.random(1, ROWS)
                until not occupied[px..","..py]
                powerup = {x = px, y = py, life = 6.0}  -- visible 6s
            end
        end
    end

    -- Comida especial: aparicion y expiracion (si esta activada)
    if settings.special then
        if special then
            special.life = special.life - dt
            if special.life <= 0 then
                special = nil
                specialTimer = 0
                specialNext = 10 + math.random() * 8
            end
        else
            specialTimer = specialTimer + dt
            if specialTimer >= specialNext then
                local occupied = {}
                for _, s in ipairs(snake) do occupied[s.x..","..s.y] = true end
                occupied[food.x..","..food.y] = true
                if powerup then occupied[powerup.x..","..powerup.y] = true end
                local px, py
                repeat
                    px = math.random(1, COLS)
                    py = math.random(1, ROWS)
                until not occupied[px..","..py]
                local lifeDur = 5.0   -- visible 5s
                special = {x = px, y = py, life = lifeDur, maxLife = lifeDur}
            end
        end
    end

    -- Velocidad efectiva: el doble de lento si el efecto esta activo
    local effSpeed = speed
    if slowTime > 0 then effSpeed = speed * 2 end

    timer = timer + dt
    if timer < effSpeed then return end
    timer = 0

    if not (nextDir.x == -dir.x and nextDir.y == -dir.y) then
        dir = nextDir
    end

    local head = snake[1]
    local nx = head.x + dir.x
    local ny = head.y + dir.y

    -- Paredes: en modo classic matan; en nowalls se envuelve al lado opuesto
    if nx < 1 or nx > COLS or ny < 1 or ny > ROWS then
        if gameMode == "nowalls" then
            if nx < 1 then nx = COLS elseif nx > COLS then nx = 1 end
            if ny < 1 then ny = ROWS elseif ny > ROWS then ny = 1 end
        else
            state = "dead"
            shake = 1.0
            playSFX(SFX.die)
            if score > hiScore then hiScore = score end
            return
        end
    end

    for i = 1, #snake do
        if snake[i].x == nx and snake[i].y == ny then
            state = "dead"
            shake = 1.0
            playSFX(SFX.die)
            if score > hiScore then hiScore = score end
            return
        end
    end

    table.insert(snake, 1, {x = nx, y = ny})
    local grew = false   -- si la serpiente crecio este turno (no quitar cola)

    -- Recoger power-up (ralentizar tiempo)
    if powerup and nx == powerup.x and ny == powerup.y then
        slowTime = 5.0   -- 5 segundos de tiempo lento
        playSFX(SFX.power)
        local ppx, ppy = cellPx(powerup.x, powerup.y)
        spawnParticles(ppx + CELL/2, ppy + CELL/2, {0.3, 0.7, 1.0})  -- particulas azules
        powerup = nil
        powerupTimer = 0
        powerupNext = 8 + math.random() * 7
    end

    -- Recoger comida especial (mas puntos, hace crecer)
    if special and nx == special.x and ny == special.y then
        score = score + SPECIAL_POINTS
        grew = true
        playSFX(SFX.power)
        local spx, spy = cellPx(special.x, special.y)
        spawnParticles(spx + CELL/2, spy + CELL/2, {1.0, 0.79, 0.05})  -- particulas doradas
        special = nil
        specialTimer = 0
        specialNext = 10 + math.random() * 8
        -- Tambien puede subir velocidad si toca multiplo de 30
        if settings.speedUp and score % 30 == 0 and speed > 0.06 then
            speed = speed - 0.01
        end
    end

    if nx == food.x and ny == food.y then
        score = score + 10
        grew = true
        playSFX(SFX.eat)
        -- Particulas brutalistas en la posicion de la comida
        local fpx, fpy = cellPx(food.x, food.y)
        spawnParticles(fpx + CELL/2, fpy + CELL/2, SKINS[selectedSkin].head)
        -- Aumentar velocidad cada 30 puntos (si el ajuste esta activo)
        if settings.speedUp and score % 30 == 0 and speed > 0.06 then
            speed = speed - 0.01
        end
        food = newFood()
    end

    if not grew then
        table.remove(snake)   -- mover: quitar cola si no crecio
    end
end

function love.keypressed(key)
    if key == "escape" then love.event.quit() end

    if key == "p" then
        if state == "playing" then
            state = "paused"
            playSFX(SFX.select)
        elseif state == "paused" then
            -- Reanudar con una cuenta regresiva corta
            countdown = 1.5
            state = "countdown"
            playSFX(SFX.select)
        end
        return
    end

    -- Durante la cuenta regresiva ignoramos el resto de inputs
    if state == "countdown" then return end

    if state == "paused" then
        if key == "m" then
            state = "menu"
            playSFX(SFX.select)
        end
        return
    end

    if state == "dead" then
        if key == "return" or key == "space" then
            playSFX(SFX.select)
            reset()
        elseif key == "m" then
            state = "menu"
            playSFX(SFX.select)
        end
        return
    end

    if state == "menu" then
        if key == "return" or key == "space" then
            playSFX(SFX.select)
            reset()
        elseif key == "g" then
            modeCursor = 1
            for i, m in ipairs(MODES) do
                if m.id == gameMode then modeCursor = i end
            end
            state = "modes"
            playSFX(SFX.select)
        elseif key == "s" then
            skinCursor = selectedSkin
            state = "skins"
            playSFX(SFX.select)
        end
        return
    end

    if state == "modes" then
        if key == "left" or key == "a" then
            modeCursor = modeCursor - 1
            if modeCursor < 1 then modeCursor = #MODES end
            playSFX(SFX.select)
        elseif key == "right" or key == "d" then
            modeCursor = modeCursor + 1
            if modeCursor > #MODES then modeCursor = 1 end
            playSFX(SFX.select)
        elseif key == "return" or key == "space" then
            gameMode = MODES[modeCursor].id
            configCursor = 1
            state = "config"
            playSFX(SFX.select)
        elseif key == "m" then
            state = "menu"
            playSFX(SFX.select)
        end
        return
    end

    if state == "config" then
        if key == "up" or key == "w" then
            configCursor = configCursor - 1
            if configCursor < 1 then configCursor = 4 end
            playSFX(SFX.select)
        elseif key == "down" or key == "s" then
            configCursor = configCursor + 1
            if configCursor > 4 then configCursor = 1 end
            playSFX(SFX.select)
        elseif key == "left" or key == "right" or key == "a" or key == "d" then
            if configCursor == 1 then
                settings.speedUp = not settings.speedUp
                playSFX(SFX.select)
            elseif configCursor == 2 then
                settings.powerups = not settings.powerups
                playSFX(SFX.select)
            elseif configCursor == 3 then
                settings.special = not settings.special
                playSFX(SFX.select)
            end
        elseif key == "return" or key == "space" then
            if configCursor == 1 then
                settings.speedUp = not settings.speedUp
                playSFX(SFX.select)
            elseif configCursor == 2 then
                settings.powerups = not settings.powerups
                playSFX(SFX.select)
            elseif configCursor == 3 then
                settings.special = not settings.special
                playSFX(SFX.select)
            else
                -- START: arrancar partida
                playSFX(SFX.select)
                reset()
            end
        elseif key == "m" then
            state = "modes"
            playSFX(SFX.select)
        end
        return
    end

    if state == "skins" then
        if key == "left" or key == "a" then
            skinCursor = skinCursor - 1
            if skinCursor < 1 then skinCursor = #SKINS end
            playSFX(SFX.select)
        elseif key == "right" or key == "d" then
            skinCursor = skinCursor + 1
            if skinCursor > #SKINS then skinCursor = 1 end
            playSFX(SFX.select)
        elseif key == "return" or key == "space" then
            selectedSkin = skinCursor
            state = "menu"
            playSFX(SFX.select)
        elseif key == "m" then
            state = "menu"
            playSFX(SFX.select)
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

-- Dibuja el power-up de ralentizar (reloj/cristal azul) si existe
local function drawPowerup()
    if not powerup then return end
    local px, py = cellPx(powerup.x, powerup.y)
    local cx, cy = px + CELL/2, py + CELL/2
    local t = foodTimer
    local blue = {0.30, 0.70, 1.00}

    -- Parpadeo cuando esta por desaparecer (ultimo 1.5s)
    local visible = true
    if powerup.life < 1.5 then
        visible = (math.floor(t * 8) % 2 == 0)
    end
    if not visible then return end

    local pulse = 1 + 0.15 * math.sin(t * 8)
    local sz = (CELL - 4) * 0.5 * pulse

    -- Bloque azul con borde grueso negro (brutalista)
    love.graphics.setColor(blue)
    love.graphics.rectangle("fill", cx - sz, cy - sz, sz * 2, sz * 2)
    love.graphics.setColor(B.black)
    love.graphics.setLineWidth(2)
    love.graphics.rectangle("line", cx - sz, cy - sz, sz * 2, sz * 2)

    -- Simbolo de reloj (manecillas) en negro
    love.graphics.setLineWidth(2)
    love.graphics.line(cx, cy, cx, cy - sz * 0.55)
    love.graphics.line(cx, cy, cx + sz * 0.45, cy)
end

-- Dibuja la comida especial (estrella dorada) con barra de tiempo descontando
local function drawSpecial()
    if not special then return end
    local px, py = cellPx(special.x, special.y)
    local cx, cy = px + CELL/2, py + CELL/2
    local t = foodTimer
    local gold = {1.0, 0.79, 0.05}

    -- Parpadeo en el ultimo segundo
    local visible = true
    if special.life < 1.0 then
        visible = (math.floor(t * 10) % 2 == 0)
    end

    if visible then
        -- Bloque dorado rotando con borde negro grueso (diamante brutalista doble)
        local pulse = 1 + 0.12 * math.sin(t * 7)
        local sz = (CELL - 4) * 0.5 * pulse
        love.graphics.push()
        love.graphics.translate(cx, cy)
        love.graphics.rotate(t * 2)
        love.graphics.setColor(gold)
        love.graphics.rectangle("fill", -sz, -sz, sz*2, sz*2)
        love.graphics.setColor(B.black)
        love.graphics.setLineWidth(2)
        love.graphics.rectangle("line", -sz*0.5, -sz*0.5, sz, sz)
        love.graphics.pop()
    end

    -- Barra de tiempo brutalista justo encima de la celda
    local frac = special.life / special.maxLife
    local barW = CELL + 6
    local barX = px - 3
    local barY = py - 8
    -- fondo de la barra
    love.graphics.setColor(B.black)
    love.graphics.rectangle("fill", barX, barY, barW, 5)
    -- relleno dorado descontando
    love.graphics.setColor(gold)
    love.graphics.rectangle("fill", barX, barY, barW * frac, 5)
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

-- ===== Pantalla de seleccion de modo =====
function drawModeScreen()
    love.graphics.setColor(B.paper[1], B.paper[2], B.paper[3], 0.96)
    love.graphics.rectangle("fill", 0, 0, WIDTH, HEIGHT)
    love.graphics.setColor(B.red)
    love.graphics.rectangle("fill", 0, 0, 60, 12)

    local bw, bh = 460, 320
    local bx = (WIDTH - bw) / 2
    local by = (HEIGHT - bh) / 2

    love.graphics.setColor(B.black)
    love.graphics.rectangle("fill", bx, by, bw, bh)
    love.graphics.setColor(B.red)
    love.graphics.setLineWidth(5)
    love.graphics.rectangle("line", bx, by, bw, bh)

    love.graphics.setFont(F.heavySm)
    love.graphics.setColor(B.red)
    love.graphics.printf("/SELECT MODE", bx + 24, by + 20, bw - 48, "left")

    love.graphics.setFont(F.displaySm)
    love.graphics.setColor(B.red)
    love.graphics.printf("MODE", bx + 20, by + 42, bw - 40, "left")
    love.graphics.setColor(B.red)
    love.graphics.setLineWidth(3)
    love.graphics.line(bx + 24, by + 80, bx + bw - 24, by + 80)

    -- Tarjeta del modo actual
    local mode = MODES[modeCursor]
    local cardX, cardY = bx + 40, by + 110
    local cardW, cardH = bw - 80, 120

    love.graphics.setColor(0.10, 0.10, 0.10)
    love.graphics.rectangle("fill", cardX, cardY, cardW, cardH)
    love.graphics.setColor(B.red)
    love.graphics.setLineWidth(3)
    love.graphics.rectangle("line", cardX, cardY, cardW, cardH)

    love.graphics.setFont(F.heavy)
    love.graphics.setColor(B.paper)
    love.graphics.printf(mode.name, cardX, cardY + 28, cardW, "center")

    love.graphics.setFont(F.mono)
    love.graphics.setColor(B.gray)
    love.graphics.printf(mode.desc, cardX, cardY + 64, cardW, "center")

    if mode.id == gameMode then
        love.graphics.setFont(F.monoSm)
        love.graphics.setColor(B.red)
        love.graphics.printf("[ CURRENT ]", cardX, cardY + 90, cardW, "center")
    end

    -- Flechas
    love.graphics.setFont(F.display)
    local arrowH = F.display:getHeight()
    local arrowY = cardY + (cardH - arrowH) / 2
    love.graphics.setColor(B.red)
    love.graphics.printf("<", bx + 10, arrowY, 30, "center")
    love.graphics.printf(">", bx + bw - 40, arrowY, 30, "center")

    love.graphics.setFont(F.monoSm)
    love.graphics.setColor(B.gray)
    love.graphics.printf(modeCursor .. " / " .. #MODES, bx, cardY + cardH + 12, bw, "center")

    -- Controles
    love.graphics.setFont(F.mono)
    local cy2 = by + bh - 44
    love.graphics.setColor(B.red);  love.graphics.print("A/D", bx + 28, cy2)
    love.graphics.setColor(B.paper);love.graphics.print("BROWSE", bx + 90, cy2)
    love.graphics.setColor(B.red);  love.graphics.print("ENTER", bx + 240, cy2)
    love.graphics.setColor(B.paper);love.graphics.print("NEXT", bx + 320, cy2)
    love.graphics.setColor(B.red);  love.graphics.print("M", bx + 28, cy2 + 22)
    love.graphics.setColor(B.paper);love.graphics.print("BACK", bx + 90, cy2 + 22)

    drawFooter()
end

-- ===== Pantalla de configuracion de partida =====
function drawConfigScreen()
    love.graphics.setColor(B.paper[1], B.paper[2], B.paper[3], 0.96)
    love.graphics.rectangle("fill", 0, 0, WIDTH, HEIGHT)
    love.graphics.setColor(B.red)
    love.graphics.rectangle("fill", 0, 0, 60, 12)

    local bw, bh = 460, 390
    local bx = (WIDTH - bw) / 2
    local by = (HEIGHT - bh) / 2

    love.graphics.setColor(B.black)
    love.graphics.rectangle("fill", bx, by, bw, bh)
    love.graphics.setColor(B.red)
    love.graphics.setLineWidth(5)
    love.graphics.rectangle("line", bx, by, bw, bh)

    love.graphics.setFont(F.heavySm)
    love.graphics.setColor(B.red)
    love.graphics.printf("/MODE: " .. MODES[modeCursor].name, bx + 24, by + 20, bw - 48, "left")

    love.graphics.setFont(F.displaySm)
    love.graphics.setColor(B.red)
    love.graphics.printf("SETUP", bx + 20, by + 42, bw - 40, "left")
    love.graphics.setColor(B.red)
    love.graphics.setLineWidth(3)
    love.graphics.line(bx + 24, by + 80, bx + bw - 24, by + 80)

    -- Filas de ajustes
    local rowX = bx + 40
    local rowW = bw - 80
    local items = {
        { label = "SPEED UP / 30 PTS", val = settings.speedUp },
        { label = "POWER-UPS",          val = settings.powerups },
        { label = "SPECIAL FOOD",       val = settings.special },
    }

    local function drawRow(y, label, on, selected)
        -- resaltar fila seleccionada
        if selected then
            love.graphics.setColor(B.red)
            love.graphics.rectangle("fill", rowX - 12, y - 4, 6, 28)
        end
        love.graphics.setFont(F.mono)
        love.graphics.setColor(selected and B.paper or B.gray)
        love.graphics.print(label, rowX, y)

        -- Pildora ON/OFF a la derecha
        local boxW = 56
        local boxX = rowX + rowW - boxW
        love.graphics.setColor(on and B.red or B.darkGray)
        love.graphics.rectangle("fill", boxX, y - 2, boxW, 22)
        love.graphics.setColor(B.paper)
        love.graphics.setFont(F.monoSm)
        love.graphics.printf(on and "ON" or "OFF", boxX, y + 2, boxW, "center")
    end

    drawRow(by + 104, items[1].label, items[1].val, configCursor == 1)
    drawRow(by + 142, items[2].label, items[2].val, configCursor == 2)
    drawRow(by + 180, items[3].label, items[3].val, configCursor == 3)

    -- Boton START
    local startY = by + 224
    local stW, stH = rowW, 46
    if configCursor == 4 then
        love.graphics.setColor(B.red)
        love.graphics.rectangle("fill", rowX, startY, stW, stH)
        love.graphics.setColor(B.black)
    else
        love.graphics.setColor(B.darkGray)
        love.graphics.rectangle("fill", rowX, startY, stW, stH)
        love.graphics.setColor(B.red)
        love.graphics.setLineWidth(3)
        love.graphics.rectangle("line", rowX, startY, stW, stH)
        love.graphics.setColor(B.paper)
    end
    love.graphics.setFont(F.heavy)
    love.graphics.printf("START GAME", rowX, startY + 12, stW, "center")

    -- Controles
    love.graphics.setFont(F.mono)
    local cy2 = by + bh - 40
    love.graphics.setColor(B.red);  love.graphics.print("W/S", bx + 28, cy2)
    love.graphics.setColor(B.paper);love.graphics.print("MOVE", bx + 90, cy2)
    love.graphics.setColor(B.red);  love.graphics.print("ENTER", bx + 200, cy2)
    love.graphics.setColor(B.paper);love.graphics.print("TOGGLE/START", bx + 280, cy2)
    love.graphics.setColor(B.red);  love.graphics.print("M", bx + 28, cy2 + 20)
    love.graphics.setColor(B.paper);love.graphics.print("BACK", bx + 90, cy2 + 20)

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
                {"G",     "GAME MODE"},
                {"S",     "SKIN"},
                {"P",     "PAUSE"},
            },
        })
        return
    end

    if state == "skins" then
        drawSkinScreen()
        return
    end

    if state == "modes" then
        drawModeScreen()
        return
    end

    if state == "config" then
        drawConfigScreen()
        return
    end

    -- Screen shake: desplazamiento aleatorio decreciente
    local sx, sy = 0, 0
    if shake > 0 then
        local mag = shake * 8   -- amplitud maxima en pixeles
        sx = (math.random() - 0.5) * 2 * mag
        sy = (math.random() - 0.5) * 2 * mag
    end

    love.graphics.push()
    love.graphics.translate(sx, sy)

    -- Pantalla de juego unificada: HUD + marco + footer
    drawHUD()
    drawBoardFrame()
    drawGrid()
    drawFood()
    drawPowerup()
    drawSpecial()
    drawSnakeBody()
    drawParticles()

    love.graphics.pop()

    drawFooter()

    -- Indicador de efecto SLOW activo
    if (state == "playing" or state == "paused") and slowTime > 0 then
        local bw2 = 130
        local bx2 = (WIDTH - bw2) / 2
        local by2 = BOARD_Y + 6
        -- barra de tiempo restante
        local frac = slowTime / 5.0
        love.graphics.setColor(0.30, 0.70, 1.00, 0.92)
        love.graphics.rectangle("fill", bx2, by2, bw2, 22)
        love.graphics.setColor(B.black)
        love.graphics.setLineWidth(2)
        love.graphics.rectangle("line", bx2, by2, bw2, 22)
        -- progreso
        love.graphics.setColor(0, 0, 0, 0.25)
        love.graphics.rectangle("fill", bx2, by2, bw2 * (1 - frac), 22)
        -- texto
        love.graphics.setFont(F.monoSm)
        love.graphics.setColor(B.black)
        love.graphics.printf("SLOW " .. string.format("%.1f", slowTime) .. "S", bx2, by2 + 5, bw2, "center")
    end

    -- Cuenta regresiva encima del tablero
    if state == "countdown" then
        -- Oscurecer el tablero
        love.graphics.setColor(0, 0, 0, 0.55)
        love.graphics.rectangle("fill", BOARD_X - 4, BOARD_Y - 4,
            CELL * COLS + 8, CELL * ROWS + 8)

        -- Numero (3,2,1) o GO en el tramo final
        local label
        if countdown > 0 then
            label = tostring(math.ceil(countdown))
        else
            label = "GO"
        end

        -- Animacion de "pop": grande al inicio de cada numero, se asienta
        local frac = countdown - math.floor(countdown)  -- 0..1
        local scale = 0.85 + 0.15 * frac

        local cx = WIDTH / 2
        local cy = BOARD_Y + (CELL * ROWS) / 2

        love.graphics.setFont(F.huge)
        local tw = F.huge:getWidth(label)
        local th = F.huge:getHeight()

        love.graphics.push()
        love.graphics.translate(cx, cy)
        love.graphics.scale(scale, scale)

        -- Sombra/borde negro grueso (brutalista) dibujando el texto desplazado
        love.graphics.setColor(B.black)
        for _, off in ipairs({{-3,-3},{3,-3},{-3,3},{3,3}}) do
            love.graphics.print(label, -tw/2 + off[1], -th/2 + off[2])
        end
        -- Texto del color de la skin seleccionada
        love.graphics.setColor(SKINS[selectedSkin].head)
        love.graphics.print(label, -tw/2, -th/2)
        love.graphics.pop()

        -- Etiqueta inferior (solo durante 3,2,1)
        if countdown > 0 then
            love.graphics.setFont(F.heavySm)
            love.graphics.setColor(B.paper)
            love.graphics.printf("GET READY", 0, cy + 90, WIDTH, "center")
        end
    end

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
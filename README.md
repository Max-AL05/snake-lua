# SNAKE / BRUTALISM

A Snake game built in Lua with [LÖVE2D](https://love2d.org), designed with a raw brutalist aesthetic — hard edges, heavy typography, red and black palette, and square-pixel everything.

![Lua](https://img.shields.io/badge/Lua-5.4-2C2D72?style=flat&logo=lua&logoColor=white)
![LÖVE2D](https://img.shields.io/badge/LÖVE2D-11.5-ff5d9e?style=flat)
![Platform](https://img.shields.io/badge/Platform-Windows%20%7C%20macOS%20%7C%20Linux-lightgrey?style=flat)

---

## Features

**Game modes**
- **Classic** — standard Snake, walls kill you
- **Obstacles** — internal walls spawn as you level up (every 40 points, 3 new walls appear)

**Setup options** (configurable per session)
- Speed increase every 30 points — ON/OFF
- Power-ups (slow time for 5 seconds) — ON/OFF
- Special food (50 pts, disappears after 5s) — ON/OFF
- No walls (wrap-around edges) — ON/OFF

**Polish**
- 4 brutalist snake skins (BRUTAL, PURPLE, JUNGLE, QUETZAL)
- Particle explosion on eat (matches skin color)
- Screen shake on death
- Countdown on resume from pause (3, 2, 1, GO)
- Animated food (rotating diamond)
- Special food with a live countdown bar
- 8-bit synthesized sound effects (no audio files needed)
- Brutalist UI with Anton, Archivo Black, and Space Mono fonts

---

## Requirements

- [LÖVE2D 11.5](https://love2d.org) (Windows 64-bit installer or `.zip`)

No other dependencies. Sound effects are synthesized at runtime — no audio files required.

---

## Installation

```
git clone https://github.com/Max-AL05/snake-brutalism
cd snake-brutalism
```

Make sure your folder structure looks like this:

```
snake-brutalism/
├── main.lua
├── README.md
├── .luarc.json
└── fonts/
    ├── Anton-Regular.ttf
    ├── ArchivoBlack-Regular.ttf
    └── SpaceMono-Bold.ttf
```

---

## Running the game

**Option A — drag and drop**

Drag the `snake-brutalism` folder onto `love.exe`.

**Option B — terminal**

```bash
"C:\Program Files\LOVE\love-11.5-win64.exe" "C:\path\to\snake-brutalism"
```

**Option C — add LÖVE to PATH** (recommended)

Add `C:\Program Files\LOVE` (or wherever you extracted LÖVE) to your system `PATH`, then run from any terminal:

```bash
love snake-brutalism
```

---

## Controls

| Key | Action |
|---|---|
| `↑ W` | Move up |
| `↓ S` | Move down |
| `← A` | Move left |
| `→ D` | Move right |
| `G` | Game mode select |
| `S` | Skin select |
| `P` | Pause / Resume |
| `M` | Back to main menu (from pause or game over) |
| `Enter / Space` | Confirm / Play / Restart |
| `Escape` | Quit |

---

## How to play

1. From the main menu, press **G** to choose a game mode and configure your session.
2. Set your toggles (speed, power-ups, special food, no walls) and press **START GAME**.
3. Press **S** from the main menu to pick a skin before playing.
4. Eat the red food to grow and score points.
5. Blue clock icon = slow time power-up (5 seconds). Gold diamond = special food (50 pts, expires).
6. In Obstacles mode, walls appear as you score — survive as long as you can.

---

## Project structure

```
main.lua          — all game logic and rendering (~1500 lines)
fonts/            — three open-source fonts (OFL license)
.luarc.json       — tells the Lua LSP that `love` is a valid global
```

Everything lives in `main.lua`. No external dependencies, no build step.

---

## Font licenses

All fonts are licensed under the [SIL Open Font License (OFL)](https://scripts.sil.org/OFL):

- [Anton](https://fonts.google.com/specimen/Anton) — The Anton Project Authors
- [Archivo Black](https://fonts.google.com/specimen/Archivo+Black) — Omnibus-Type
- [Space Mono](https://fonts.google.com/specimen/Space+Mono) — Colophon Foundry

---

## Built with

- [Lua 5.4](https://www.lua.org)
- [LÖVE2D 11.5](https://love2d.org)

---

*SNAKE.BRUTALISM // LUA + LOVE2D*
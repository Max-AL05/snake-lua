
// SNAKE / BRUTALISM — USER MANUAL

#let f-display = "Anton"
#let f-body    = "Archivo Black"
#let f-mono    = "Space Mono"

#let red       = rgb("#F22921")
#let black     = rgb("#0A0A0A")
#let paper     = rgb("#E6E3DA")
#let gray      = rgb("#8C8A85")
#let dark      = rgb("#1E1E1E")
#let cell-alt  = rgb("#EBEBDF")

// ── Header / footer defined as variables first ───────────────
#let hdr = [
  #set text(font: f-mono, size: 7.5pt, fill: gray)
  SNAKE / BRUTALISM #h(1fr) USER MANUAL #h(1fr) v1.0
  #line(length: 100%, stroke: 0.75pt + red)
]

#let ftr = [
  #line(length: 100%, stroke: 0.5pt + gray)
  #v(3pt)
  #set text(font: f-mono, size: 7.5pt, fill: gray)
  SNAKE.BRUTALISM #h(1fr) #context counter(page).display("1 of 1", both: true)
]

// ── Page ─────────────────────────────────────────────────────
#set page(
  paper: "a4",
  margin: (top: 2.6cm, bottom: 2.6cm, left: 2.6cm, right: 2.6cm),
  fill: paper,
  header: hdr,
  footer: ftr,
)

#set text(font: f-body, size: 10pt, fill: black, hyphenate: false)
#set par(leading: 0.8em, spacing: 1.1em)

// ── Headings ─────────────────────────────────────────────────
#show heading.where(level: 1): it => {
  v(1.6em)
  block[
    #set text(font: f-display, size: 26pt, fill: red)
    #it.body
    #v(-4pt)
    #line(length: 100%, stroke: 3pt + red)
  ]
  v(0.4em)
}
#show heading.where(level: 2): it => {
  v(1.0em)
  block[
    #set text(font: f-display, size: 14pt, fill: black)
    #it.body
    #v(-3pt)
    #line(length: 100%, stroke: 1pt + black)
  ]
  v(0.2em)
}
#show heading.where(level: 3): it => {
  v(0.6em)
  text(font: f-body, size: 10pt, fill: red, it.body)
  v(0.1em)
}

// ── Shared components ─────────────────────────────────────────
#let eyebrow(t) = block(below: 4pt)[
  #set text(font: f-mono, size: 8pt, fill: red)
  #sym.slash #t
]

#let key(k) = box(fill: black, inset: (x: 5pt, y: 3pt))[
  #set text(font: f-mono, size: 8pt, fill: paper, weight: "bold"); #k
]

#let note(body) = block(
  width: 100%,
  stroke: (left: 4pt + red, rest: 0.5pt + gray),
  inset: (left: 12pt, top: 8pt, bottom: 8pt, right: 10pt),
  below: 1em,
)[#set text(size: 9pt); #body]

#let codebox(body) = block(
  fill: dark, inset: 12pt, width: 100%, below: 0.8em, radius: 0pt,
)[#set text(font: f-mono, size: 9pt, fill: paper); #body]

#let pill(on) = box(
  fill: if on { red } else { dark },
  inset: (x: 6pt, y: 3pt),
)[#set text(font: f-mono, size: 8pt, fill: paper)
  #if on [ON] else [OFF]]

#let brow-table(cols, headers, ..rows) = {
  let hcells = headers.map(h => table.cell(fill: dark)[
    #set text(font: f-mono, size: 8pt, fill: paper); #h
  ])
  table(
    columns: cols,
    stroke: none,
    inset: (x: 8pt, y: 7pt),
    fill: (_, y) => if y == 0 { dark }
                    else if calc.odd(y) { cell-alt }
                    else { white },
    ..hcells,
    ..rows,
  )
}

// ╔═══════════════════════╗
// ║  COVER               ║
// ╚═══════════════════════╝
#page(fill: black, header: none, footer: none)[
  #set text(fill: paper)
  #place(top + left, rect(width: 6cm, height: 10pt, fill: red))
  #v(3.8cm)

  #text(font: f-mono, size: 10pt, fill: gray)[#sym.slash USER MANUAL]
  #v(0.4cm)
  #text(font: f-display, size: 76pt, fill: red)[SNAKE]
  #v(-0.9cm)
  #line(length: 100%, stroke: 4pt + red)
  #v(0.1cm)
  #text(font: f-display, size: 30pt, fill: paper)[BRUTALISM]
  #v(1.4cm)

  #rect(
    fill: none,
    stroke: (left: 4pt + red, rest: none),
    inset: (left: 14pt, y: 10pt),
  )[
    #set text(font: f-body, size: 11pt, fill: paper)
    A Snake game built in Lua with LÖVE2D. \
    Brutalist aesthetic. Complete user documentation.
  ]

  #v(1fr)
  #text(font: f-mono, size: 8pt, fill: gray)[
    VERSION 1.0 #sym.dash.em LUA 5.4 + LÖVE2D 11.5 #sym.dash.em WINDOWS #sym.dot.c MACOS #sym.dot.c LINUX
  ]
]

#counter(page).update(1)

// ╔═══════════════════════╗
// ║  CONTENTS            ║
// ╚═══════════════════════╝
#page(header: none)[
  #eyebrow("DOCUMENT INDEX")

  #block[
    #set text(font: f-display, size: 36pt, fill: red)
    CONTENTS
    #v(-5pt)
    #line(length: 100%, stroke: 3pt + red)
  ]
  #v(0.5cm)

  #let entry(num, title, desc) = {
    grid(
      columns: (1.6cm, 1fr),
      text(font: f-display, size: 20pt, fill: red)[#num],
      block[
        #text(font: f-body, size: 11pt)[#title] \
        #text(font: f-mono, size: 8pt, fill: gray)[#desc]
      ]
    )
    line(length: 100%, stroke: 0.5pt + gray)
    v(3pt)
  }

  #entry("01", "Overview",               "What this game is and how it works")
  #entry("02", "System Requirements",    "Software needed to run the game")
  #entry("03", "Installation",           "Getting the game running on your machine")
  #entry("04", "Main Menu",              "Navigating the entry screen")
  #entry("05", "Game Modes",             "Classic and Obstacles explained")
  #entry("06", "Session Setup",          "Configuring each match before you play")
  #entry("07", "Controls",               "Full keyboard reference")
  #entry("08", "Gameplay",               "Core mechanics, scoring, and progression")
  #entry("09", "Skins",                  "Choosing your snake appearance")
  #entry("10", "Power-ups & Special Food","Bonus items and their effects")
  #entry("11", "HUD Reference",          "Reading the in-game interface")
  #entry("12", "Pause & Navigation",     "Pausing, resuming, and returning to menu")
]

// ── 01 ────────────────────────────────────────────────────────
= 01 — Overview

#eyebrow("WHAT IS THIS")

*Snake / Brutalism* is a Snake game built in Lua using the LÖVE2D game framework.
It follows the classic rules of the Snake genre while introducing configurable game
modes, cosmetic skins, power-ups, and special food items. The visual design adopts a
brutalist graphic language: hard edges, heavy typography, a red and black palette,
and square-pixel graphics with no rounded corners.

This document provides complete reference information for installation, navigation,
and gameplay.

== Design Philosophy

The game is designed around three principles:

- *All configuration before play.* Game mode, toggles, and skin are selected from
  dedicated screens before a session begins.

- *No hidden mechanics.* Every active modifier — slow time, speed level, special
  food countdown — is communicated visually on screen at all times.

- *Consistent visual language.* Menus, overlays, and in-game elements share the
  same typographic system, palette, and layout conventions.

// ── 02 ────────────────────────────────────────────────────────
= 02 — System Requirements

#eyebrow("WHAT YOU NEED")

#brow-table(
  (3.2cm, 1fr),
  ("COMPONENT", "REQUIREMENT"),
  [Runtime],  [LÖVE2D 11.5 — download at love2d.org],
  [Language], [Lua 5.4 (bundled with LÖVE2D, no separate install needed)],
  [OS],       [Windows 10/11 #sym.dot.c macOS 12+ #sym.dot.c Linux x86-64],
  [Storage],  [Less than 5 MB (fonts + source)],
  [Audio],    [Any output device — sound is synthesized at runtime],
  [Display],  [Minimum 660 #sym.times 560 px available window area],
)

#note[
  No internet connection is required after the initial download. All sound effects
  are generated programmatically — no audio files are bundled.
]

// ── 03 ────────────────────────────────────────────────────────
= 03 — Installation

#eyebrow("GETTING STARTED")

== Step 1 — Install LÖVE2D

Download LÖVE2D 11.5 from *love2d.org* and install it. On Windows, use the 64-bit
installer. Note the installation path (typically `C:\Program Files\LOVE`).

== Step 2 — Obtain the Game Files

Clone the repository or download the source archive:

#codebox[git clone https://github.com/YOUR_USERNAME/snake-brutalism]

== Step 3 — Verify Folder Structure

The `fonts/` directory must be present alongside `main.lua`. The game will not
start if fonts are missing.

#codebox[
  snake-brutalism/ \
  #h(1em) main.lua \
  #h(1em) README.md \
  #h(1em) .luarc.json \
  #h(1em) fonts/ \
  #h(2em) Anton-Regular.ttf \
  #h(2em) ArchivoBlack-Regular.ttf \
  #h(2em) SpaceMono-Bold.ttf
]

== Step 4 — Run the Game

*Option A — Drag and drop:* drag the project folder onto `love.exe`.

*Option B — Terminal:*

#codebox["C:\Program Files\LOVE\love-11.5-win64.exe" "C:\path\to\snake-brutalism"]

*Option C — PATH method (recommended):* add the LÖVE directory to your system
PATH, then from any terminal:

#codebox[love snake-brutalism]

#note[
  To add LÖVE to PATH on Windows: search "Environment Variables" in the Start menu,
  edit the `Path` variable, and add the LÖVE installation folder. Restart any open
  terminal for the change to take effect.
]

// ── 04 ────────────────────────────────────────────────────────
= 04 — Main Menu

#eyebrow("ENTRY SCREEN")

The main menu is displayed on launch. It features a snake icon in the shape of the
letter S, the game title, and the following options:

#brow-table(
  (3cm, 1fr),
  ("KEY", "ACTION"),
  [#key("Enter")], [Start a session with the last configured mode and settings],
  [#key("G")],     [Open the Game Mode selection and Setup screen],
  [#key("S")],     [Open the Skin selection screen],
  [#key("Esc")],   [Quit the application],
)

#note[
  Pressing #key("Enter") from the main menu starts immediately using the last saved
  configuration. To change mode or options, press #key("G") first.
]

// ── 05 ────────────────────────────────────────────────────────
= 05 — Game Modes

#eyebrow("HOW THE FIELD BEHAVES")

Two modes are available, selectable via #key("G") from the main menu.

== Classic

Standard Snake rules. The playing field is bounded on all four sides. Any collision
with the outer wall ends the session immediately. No structural challenge beyond the
snake's own body is introduced by the mode itself.

== Obstacles

An escalating challenge mode. The field begins empty, but internal wall segments
are added as the player accumulates points.

#brow-table(
  (3.5cm, 1fr),
  ("THRESHOLD", "EVENT"),
  [Every 40 points], [3 new wall segments are placed on the field],
  [Progressively],   [Walls accumulate and are never removed during a session],
)

#v(0.4em)

Wall segments are rendered as dark blocks with a red border and a diagonal danger
stripe. Placement rules:

- Never within 4 cells of the snake's current head (safe zone).
- Never on a cell occupied by the snake, food, power-up, or special food.
- Never adjacent to the outer boundary.
- A short audio cue sounds each time new walls appear.

#note[
  Obstacle mode is fully compatible with the No Walls toggle (Section 06). When
  both are active, the outer boundary wraps around but internal wall segments
  remain lethal.
]

// ── 06 ────────────────────────────────────────────────────────
= 06 — Session Setup

#eyebrow("CONFIGURING YOUR MATCH")

After selecting a mode and pressing #key("Enter"), the Setup screen is displayed.
Navigate rows with #key("W") #sym.slash #key("S"). Toggle with #key("Enter") or
the arrow keys. Press #key("M") to go back. Navigate to *START GAME* and press
#key("Enter") to begin the session.

#v(0.4em)

#brow-table(
  (3.5cm, 1.8cm, 1fr),
  ("OPTION", "DEFAULT", "DESCRIPTION"),
  [Speed Up / 30 pts], [#pill(true)],
    [Movement interval decreases each time the score reaches a multiple of 30.
     Cumulative and permanent for the session.],
  [Power-Ups], [#pill(false)],
    [Enables the Slow Time power-up. See Section 10.],
  [Special Food], [#pill(false)],
    [Enables the high-value food item that expires after a fixed duration. See Section 10.],
  [No Walls], [#pill(false)],
    [Removes outer boundary lethality. The snake exits one edge and re-enters from
     the opposite side. Compatible with both modes.],
)

// ── 07 ────────────────────────────────────────────────────────
= 07 — Controls

#eyebrow("KEYBOARD REFERENCE")

== In-Game

#brow-table(
  (3.5cm, 1fr),
  ("KEY", "ACTION"),
  [#key("↑") #h(4pt) #key("W")], [Move up],
  [#key("↓") #h(4pt) #key("S")], [Move down],
  [#key("←") #h(4pt) #key("A")], [Move left],
  [#key("→") #h(4pt) #key("D")], [Move right],
  [#key("P")],   [Pause the current session],
  [#key("Esc")], [Quit the application immediately],
)

== Menus and Overlays

#brow-table(
  (3.5cm, 1fr),
  ("KEY", "ACTION"),
  [#key("Enter") #h(3pt) #key("Space")], [Confirm / Start / Restart],
  [#key("A") #h(4pt) #key("D")],         [Browse (Mode and Skin screens)],
  [#key("W") #h(4pt) #key("S")],         [Navigate rows (Setup screen)],
  [#key("G")],   [Game Mode screen (main menu only)],
  [#key("S")],   [Skin screen (main menu only)],
  [#key("P")],   [Resume from pause (triggers countdown)],
  [#key("M")],   [Return to previous screen or main menu],
)

#note[
  Direction reversal is not permitted. Pressing the key directly opposite the
  current direction of travel has no effect.
]

// ── 08 ────────────────────────────────────────────────────────
= 08 — Gameplay

#eyebrow("CORE MECHANICS")

== Objective

Guide the snake to consume food items. Each item increases the snake's length by
one segment and awards points. The session ends on collision with an outer wall
(if No Walls is off), the snake's own body, or an obstacle (Obstacles mode).

== Scoring

#brow-table(
  (4.5cm, 1fr),
  ("EVENT", "POINTS"),
  [Standard food consumed],  [+10],
  [Special food consumed],   [+50],
  [Power-up collected],      [0 (effect only — no points)],
  [Collision],               [Session ends],
)

== Speed Progression

When *Speed Up* is enabled, the movement interval decreases each time the score
reaches a multiple of 30. The effect is cumulative and does not reset between
levels in Obstacles mode. The current speed level appears in the HUD under *SPEED*.

== Death and Restart

On collision, a screen-shake effect and death sound trigger simultaneously.
The Game Over overlay shows the final score and current best. Two options:

- #key("Enter") or #key("Space") — restart with the same mode and settings.
- #key("M") — return to the main menu.

*BEST* is retained in memory for the application run. It is not saved to disk.

// ── 09 ────────────────────────────────────────────────────────
= 09 — Skins

#eyebrow("SNAKE APPEARANCE")

Press #key("S") from the main menu. Browse with #key("A") #sym.slash #key("D"),
preview the live snake in the card, and confirm with #key("Enter"). Press #key("M")
to return without changing. The active skin is labeled *[ SELECTED ]*.

The active skin determines the color of the snake, the eat particles, and the
3#sym.dot.c 2#sym.dot.c 1#sym.dot.c GO countdown numbers.

#brow-table(
  (2.3cm, 2.3cm, 1fr),
  ("SKIN", "HEAD", "BODY STYLE"),
  [BRUTAL],  [Red],    [Off-white / gray alternating — black center stripe],
  [PURPLE],  [Yellow], [Mid-purple / dark purple alternating],
  [JUNGLE],  [Amber],  [Olive green / dark green alternating],
  [QUETZAL], [Gold],   [Emerald / teal alternating — gold border detail],
)

All skins share the same brutalist block style: square segments, hard edges, no
rounding, and a directional square eye on the head that tracks direction of movement.

// ── 10 ────────────────────────────────────────────────────────
= 10 — Power-ups & Special Food

#eyebrow("BONUS ITEMS")

Both item types must be enabled in Session Setup. They are always placed on free
cells — never overlapping the snake, food, obstacles, or each other.

== Slow Time Power-up

#brow-table(
  (3.2cm, 1fr),
  ("ATTRIBUTE", "DETAIL"),
  [Appearance],  [Blue square block with clock hands in black],
  [Spawn rate],  [One item every 8–15 seconds (randomized)],
  [Visibility],  [6 seconds on the field before auto-disappearing],
  [Effect],      [Halves the snake's movement speed for 5 seconds],
  [Visual cue],  [A blue bar labeled SLOW X.Xs appears at the top of the field],
  [On collect],  [Ascending arpeggio + blue particle burst],
)

#note[
  The Slow Time effect doubles the movement interval (half speed). Especially
  useful in Obstacles mode when navigating dense wall clusters at higher scores.
]

== Special Food

#brow-table(
  (3.2cm, 1fr),
  ("ATTRIBUTE", "DETAIL"),
  [Appearance],  [Rotating gold diamond with black inner square],
  [Spawn rate],  [One item every 10–18 seconds (randomized)],
  [Visibility],  [5 seconds before expiring],
  [Points],      [+50 — five times the value of standard food],
  [Timer bar],   [Gold bar above the cell counts down remaining time. Item flashes in the final second.],
  [On collect],  [Ascending arpeggio + gold particle burst],
)

Special food causes the snake to grow by one segment, identical to standard food.
The two item types are fully independent.

// ── 11 ────────────────────────────────────────────────────────
= 11 — HUD Reference

#eyebrow("READING THE INTERFACE")

The HUD occupies the bar at the top of the window, separated from the playing
field by a red horizontal line. Three values are displayed:

#brow-table(
  (2cm, 1fr),
  ("LABEL", "DESCRIPTION"),
  [SCORE], [Points accumulated in the current session],
  [SPEED], [Current speed level. Starts at 1. Increments by 1 every 30 points when Speed Up is enabled.],
  [BEST],  [Highest score achieved since the application was launched. Resets to 0 on quit.],
)

Each label is displayed in red above its value. Values use the Space Mono typeface.

== In-Game Overlays

#brow-table(
  (3.5cm, 1fr),
  ("ELEMENT", "DESCRIPTION"),
  [SLOW X.Xs bar],       [Blue progress bar at the top of the field. Active when Slow Time is in effect.],
  [Special food bar],    [Gold bar above the special food cell. Counts down remaining visibility.],
  [3#sym.dot.c 2#sym.dot.c 1#sym.dot.c GO], [Countdown on resume from pause. Color matches the active skin's head.],
)

// ── 12 ────────────────────────────────────────────────────────
= 12 — Pause & Navigation

#eyebrow("PAUSING AND RETURNING TO MENU")

== Pausing

Press #key("P") during an active session to pause. The game state freezes
completely — the snake, all item lifetimes, the slow time effect, and all
timers halt.

#brow-table(
  (2.2cm, 1fr),
  ("KEY", "ACTION"),
  [#key("P")], [Resume — triggers the 3#sym.dot.c 2#sym.dot.c 1#sym.dot.c GO countdown],
  [#key("M")], [Return to the main menu — the current session is abandoned],
)

== Resume Countdown

When resuming from pause, a countdown sequence (3 — 2 — 1 — GO) is displayed over
the frozen field. Numbers render in the head color of the active skin with a black
outline. Gameplay resumes immediately after GO completes.

This countdown does *not* appear when starting a new session from the menu. It is
exclusive to the pause-resume flow and exists to prevent the player from being
caught off guard on return.

== Game Over Navigation

After a session ends, the Game Over overlay shows the final score and the current
best. Two options are available:

#brow-table(
  (3.5cm, 1fr),
  ("KEY", "ACTION"),
  [#key("Enter") #h(3pt) #key("Space")], [Restart with the same mode and settings],
  [#key("M")], [Return to the main menu],
)

#v(3em)
#line(length: 100%, stroke: 2pt + red)
#v(0.5em)
#text(font: f-mono, size: 8pt, fill: gray)[
  END OF DOCUMENT #sym.dot.c SNAKE / BRUTALISM USER MANUAL #sym.dot.c VERSION 1.0
]

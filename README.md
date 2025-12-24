# frupre
Alternative to kzrush /showpre (but not really)

AI slopped readme:
# AMXX Scroll Statistics (Jump/Duck)

A precise movement utility for GoldSrc (Counter-Strike 1.6) that tracks scroll input timing, Frames On Ground (FOG), and real-time velocity. Designed for movement players to refine Bunnyhop and Stand-Up timing.

## 🚀 Features

* **Smart Tracking**: Displays total scroll count and the specific "fire" index (the notch that triggered the action).
* **FOG (Frames On Ground)**: Shows exactly how many server frames you spent on the ground before the action fired.
* **Live Speedometer**: Real-time horizontal velocity (XY axis) updated every frame, displayed without prefixes for a clean look.
* **Intelligent Filtering**:
    * **Threshold**: Requires at least 2 scroll notches to trigger HUD updates.
    * **Exclusive HUD**: Jump and Duck stats cancel each other out to prevent clutter.
    * **FOG Cap**: Automatically hides stats if FOG exceeds 50 frames.
* **High-Fidelity HUD**: Uses the engine `print_center` font, positioned 12 lines lower than center to avoid crosshair overlap.

## 📋 Requirements

* AMX Mod X 1.8.2 or higher
* `fakemeta` module

## 🔧 Installation

1.  Download the `.sma` file.
2.  Compile the script.
3.  Place `scroll_stats.amxx` in `addons/amxmodx/plugins/`.
4.  Add `scroll_stats.amxx` to your `plugins.ini`.
5.  Change map or restart the server.

## 🕹️ HUD Layout

The display appears at the bottom-center of your screen:

```text
J: 15 [1]     <- Scroll count [Fire index]
FOG: 2        <- Frames on ground
250           <- Live speed

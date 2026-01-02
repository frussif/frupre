# Frupre Pro Ultimate - modular edition

A professional-grade movement utility for Counter-Strike 1.6. Frupre offers a fully customizable modular HUD, tracking scroll timing, Frames On Ground (FOG), and advanced jump mechanics like Gain, Sync, and Overlaps.

It serves as a powerful, modern alternative to `showpre`, featuring unique **Smart Hiding** logic to keep your screen clean during normal gameplay.

## 🚀 Installation
1. Download [frupre.amxx](https://github.com/frussif/frupre/raw/refs/heads/modularstats/frupre.amxx)
2. Place it in `cstrike/addons/amxmodx/plugins/`.
3. Add `frupre.amxx` to a new line in `cstrike/addons/amxmodx/configs/plugins.ini`.

## ⚙️ Configuration
The plugin features a hybrid configuration system. Use the **Chat Menu** for general toggles and the **Console Command** for advanced HUD design.

### Chat Menu
Type **/frupre** or **!frupre** in chat to open the settings menu.

| Option | Description |
| :--- | :--- |
| **Plugin** | Global toggle (On/Off). |
| **Mode** | Detection mode: `Off`, `Jump`, `Duck`, or `Both`. |
| **Scroll Info** | Toggle the scroll count line (e.g., `12 [3]`). |
| **HUD Height** | Vertical position adjustment (0-20 scale). |
| **Gap** | Fine-tune spacing between Scroll Info and Layout lines. |
| **Colors** | Toggle adaptive colors (Green/Orange/Red) based on performance. |
| **Speed Type** | Toggle between `XY` (Horizontal) or `XYZ` (3D) velocity. |

### Modular HUD Layout
Use the console command `frupre_layout` to design your own HUD.
**Example:** `frupre_layout "FOG: %fog %n %speedstatic (%gain) %n %sync%% | %dist"`

**Available Tags:**
* `%fog`: Frames on Ground.
* `%gain`: Speed gained during the jump.
* `%speed`: Live real-time velocity.
* `%speedstatic`: Velocity at the moment of the jump/duck.
* `%sync`: Strafe synchronization percentage.
* `%overlap`: Frames where both A+D were held.
* `%dead`: Frames where no strafe keys were held.
* `%dist`: Jump distance.
* `%n`: New line.

---

* **Adaptive Colors:** * **FOG:** 1-2 (Green), 3 (Orange), 4+ (Red).
    * **Scroll Steps:** 1-2 (Green), 3-4 (Orange), 5+ (Red).

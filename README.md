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
| **Scrollinfo Gap** | Fine-tune spacing between Scroll Info and Layout lines. |
| **Colors** | Toggle colour performance indicators, see [Adaptive Colors](#adaptive-colors). |
| **Speed Type** | Toggle between `XY` (Horizontal) or `XYZ` (3D) velocity. |
| **HUD Type** | Toggle between HUD and DHUD, DHUD offers (much) bigger and clearer text. |

### Modular HUD Layout
Use the console command `frupre_layout` to design your own HUD.  
**Default:** `frupre_layout "%speedstatic (%gain) [%fog]%n%strafesx %sync%% [%overlap/%deadair]%n%dist"`

**Available Tags:**
* `%fog`: Frames on Ground.
* `%gain`: Speed gained during the jump.
* `%speedstatic`: Max velocity at the moment of the jump/duck.
* `%speed`: Live real-time velocity.
* `%premsg`: Speed quality text (e.g., "Perfect", "Good", "Bad").
* `%strafes`: Number of strafes performed in the jump.
* `%sync`: Strafe synchronization percentage.
* `%overlap`: Frames where both A+D were held.
* `%deadair`: Frames where no strafe keys were held.
* `%dist`: Jump distance.
* `%n`: New line.

---

<a id="adaptive-colors"></a>
### 🎨 Adaptive Colors
The HUD dynamically changes color based on your performance:

* **Scroll Steps (Timing):**
  * **1-2:** Green (Perfect)
  * **3-4:** Orange (Decent)
  * **5+:** Red (Slow)

* **Frames on Ground (FOG):**
  * **1-2:** Green (Perfect)
  * **3:** Orange (Decent)
  * **4+:** Red (Bad)

* **Speed (Max Speed before jumping):**
  * **300+:** Blue/Dark Blue (Speed too high)
  * **280+:** Green (Perfect)
  * **240+:** Cyan/Lighter Blue (Good)
  * **220+:** Yellow (Bad)
  * **Below 220:** Red (Terrible)

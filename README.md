  # Frupre Scroll Statistics

A precise movement utility for Counter-Strike 1.6 that tracks scroll input timing, Frames On Ground (FOG), and real-time velocity.

Kind of an alternative to kzrush's /showpre, also shows scroll step count.

Download the compiled plugin here [https://github.com/frussif/frupre/blob/main/frupre.amxx](https://github.com/frussif/frupre/raw/refs/heads/main/frupre.amxx).

## ⚙️ Configuration
The plugin is fully menu-driven. Type **/frupre** or **!frupre** in chat to configure your personal settings. Settings are saved per player in the vault.

| Option | Default | Description |
| :--- | :--- | :--- |
| **Jump** | `ON` | Toggle display of Jump (+jump) stats. |
| **Duck** | `ON` | Toggle display of Duck (+duck) stats. |
| **FOG** | `ON` | Toggle the FOG (Frames On Ground) display. |
| **Speed** | `Live` | `OFF`, `Live` (continuous), or `Static` (shows pre/post speed). |
| **Speed Type** | `XY` | `XY` for horizontal speed, `XYZ` for true 3D speed. |
| **Height** | `12` | Adjust HUD vertical position (0-20 scale). |
| **Colors** | `ON` | Toggle adaptive colors (Green/Orange/Red) for RGB HUD. |
| **HUD Type** | `RGB` | `CenterPrint` (Yellow) or `RGB HUD` (Multi-color). |

---
> **Note:** Always select **"Save Settings"** at the bottom of the menu to ensure your changes persist after you disconnect.

## 🕹️ HUD Layout

```text
J: 15 [1]     <- Scroll step count [Step that triggered +jump/+duck]
FOG: 2        <- Frames on ground
250           <- Live speed

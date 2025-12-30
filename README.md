  # Frupre Scroll Statistics

A precise movement utility for Counter-Strike 1.6 that tracks scroll input timing, Frames On Ground (FOG), and real-time velocity.

Kind of an alternative to kzrush's /showpre, also shows scroll step count.

Download the compiled plugin here [https://github.com/frussif/frupre/blob/main/frupre.amxx](https://github.com/frussif/frupre/raw/refs/heads/main/frupre.amxx).

## ⚙️ Configuration
The plugin is fully menu-driven. Type **/frupre** or **!frupre** in chat to configure your personal settings. Settings are saved in your cstrike folder under "frupre_save".

# Frupre Pro Ultimate - Configuration Options

| Option | Default | Description |
| :--- | :--- | :--- |
| **Plugin** | `On` | Global toggle for the entire plugin. |
| **Mode** | `Both` | Cycles through `Off`, `Jump`, `Duck`, or `Both` (J+D) detection. |
| **Scroll Info** | `On` | Toggle the scroll count line (e.g., `J: 12 [2]`). |
| **FOG** | `On` | Toggle the FOG (Frames On Ground) display. |
| **Speed** | `Live` | `Off`, `Live` (continuous), or `Static` (shows max speed on landing). |
| **Speed Type** | `XY` | `XY` for horizontal speed, `XYZ` for true 3D speed. |
| **Height** | `12` | Adjust HUD vertical position (0-20 scale). |
| **Colors** | `On` | Toggle adaptive colors (Green/Orange/Red) for RGB HUD. |
| **HUD Type** | `RGB` | `CenterPrint` (Yellow) or `RGB HUD` (Multi-color). |

---
**Note:** Use the `Save` option at the bottom of the menu to persist your changes across sessions.

## 🕹️ HUD Layout

```text
     15 [1]        <- Scroll step count [Step that triggered +jump/+duck]
     FOG: 2        <- Frames on ground
    250 (30)       <- Live speed or max speed and gain in brackets (depends on option)
75% | 3/5 | 250.1  <- Sync %, overlaps/dead air & distance

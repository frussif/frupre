# Frupre Scroll Statistics

A precise movement utility for Counter-Strike 1.6 that tracks scroll input timing, Frames On Ground (FOG), and real-time velocity.

Kind of an alternative to kzrush's /showpre, also shows scroll step count.

Download the compiled plugin here [https://github.com/frussif/frupre/blob/main/frupre.amxx](https://github.com/frussif/frupre/raw/refs/heads/main/frupre.amxx).

## ⚙️ Configuration
The plugin is fully menu-driven. Type **/frupre** or **!frupre** in chat to configure your personal settings. Settings are saved in your cstrike folder under "frupre_save.txt".

# Frupre Pro Ultimate - Configuration Options

| Option | Default | Description |
| :--- | :--- | :--- |
| **Plugin** | `On` | Global toggle for the entire plugin. |
| **Mode** | `Both` | Cycles through `Off`, `Jump`, `Duck`, or `Both` (J+D) detection. |
| **Scroll Info** | `On` | Toggle the scroll count line (e.g., `12 [3]`). |
| **FOG** | `On` | Toggle the FOG (Frames On Ground) display. |
| **Speed** | `Live` | `Off`, `Live` (continuous), or `Static` (shows max speed on landing, as well as gain in brackets). |
| **Stats** | `On` | Toggle extra movement stats (Sync/Gain/Dist). |
| **HUD Height** | `12` | Adjust HUD vertical position (0-20 scale). |
| **Scrollinfo Gap** | `0.013` | Fine-tune the vertical spacing between Scroll Info and Stats to fix overlap issues on lower resolutions. |
| **Speed Type** | `XY` | `XY` for horizontal speed, `XYZ` for true 3D speed. |
| **HUD Type** | `RGB` | `CenterPrint` (White) or `RGB HUD` (Multi-color). |
| **Colors** | `On` | Toggle adaptive colors (Green/Orange/Red) based on FOG/Steps. |

FOG/Speed/Stats are in the same channel, so they'll show the same colour based on the FOG.

For FOG 1-2 the colour is green, for 3 it's yellow, 4 and up red.
The FOG display can be turned off, the colours will still represent the FOG.

For the scroll info: Steps 1-2 are green, 3-4 yellow, 5 and up red.

---
Settings are automatically saved whenever an option is changed.

## 🕹️ HUD Layout
FOG 1-2 for the FOG/Speed/Stats are green, 3 is yellow, 4 and up red.
For the scrollinfo: Steps 1-2 are green, 3-4 yellow, 5 and up red.

```text
      12 [3]        <- Total scrolls [The specific scroll that triggered jump/duck]
      FOG: 2        <- Frames on ground (1 = Perfect, 2 = Good)
     250 (30)       <- Live speed or Landing Speed (Gain in brackets)
 85% | 2/1 | 240.5  <- Sync % | Overlap/Dead frames | Jump Distance

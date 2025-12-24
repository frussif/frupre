# Frupre Scroll Statistics

A precise movement utility for Counter-Strike 1.6 that tracks scroll input timing, Frames On Ground (FOG), and real-time velocity.

## ⚙️ CVARs

| CVAR | Default | Description |
| :--- | :--- | :--- |
| `frupre_enable` | `1` | Master toggle for the plugin. |
| `frupre_jump` | `1` | Toggle display of Jump (+jump) stats. |
| `frupre_duck` | `1` | Toggle display of Duck (+duck) stats. |
| `frupre_fog` | `1` | Toggle the FOG (Frames On Ground) display. |
| `frupre_speed` | `1` | Toggle the live speed display. |

## 🕹️ HUD Layout

```text
J: 15 [1]     <- Scroll step count [Step that triggered +jump/+duck]
FOG: 2        <- Frames on ground
250           <- Live speed

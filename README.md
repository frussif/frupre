# Frupre Scroll Statistics

A precise movement utility for Counter-Strike 1.6 that tracks scroll input timing, Frames On Ground (FOG), and real-time velocity.

Kind of an alternative to kzrush's /showpre, also shows scroll step count.

Download the compiled plugin here [https://github.com/frussif/frupre/blob/main/frupre.amxx](https://github.com/frussif/frupre/raw/refs/heads/main/frupre.amxx).

## ⚙️ CVARs

| CVAR | Default | Description |
| :--- | :--- | :--- |
| `frupre_enable` | `1` | Master toggle for the plugin. |
| `frupre_jump` | `1` | Toggle display of Jump (+jump) stats. |
| `frupre_duck` | `1` | Toggle display of Duck (+duck) stats. |
| `frupre_fog` | `1` | Toggle the FOG (Frames On Ground) display. |
| `frupre_speed` | `1` | 0 = OFF, 1 = Live (continuous), 2 = Static (updates on scroll). |
| `frupre_speed_type` | `1` | 1 = Horizontal (XY), 2 = True 3D (XYZ). |
| `frupre_height` | `10` | Change the height at which it's displayed, 10 is around the center. |

## 🕹️ HUD Layout

```text
J: 15 [1]     <- Scroll step count [Step that triggered +jump/+duck]
FOG: 2        <- Frames on ground
250           <- Live speed

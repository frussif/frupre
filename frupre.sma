#include <amxmodx>
#include <fakemeta>

new g_jCount[33], g_jFire[33], g_jFinalFOG[33]
new g_dCount[33], g_dFire[33], g_dFinalFOG[33]
new g_jFOG[33], g_dFOG[33], bool:g_onGround[33]
new Float:g_lastScrollTime[33], g_lastType[33]
new g_preSpeed[33], g_postSpeed[33]

new p_enabled, p_show_jump, p_show_duck, p_show_fog, p_speed_mode, p_speed_type, p_height, p_colors, p_hud_type

public plugin_init() {
    register_plugin("Frupre Multi-Tier Colors", "8.1", "Custom")
    register_forward(FM_PlayerPreThink, "fwd_PlayerPreThink")
    
    p_enabled      = register_cvar("frupre_enable", "1")
    p_show_jump    = register_cvar("frupre_jump", "1")
    p_show_duck    = register_cvar("frupre_duck", "1")
    p_show_fog     = register_cvar("frupre_fog", "1")
    p_speed_mode   = register_cvar("frupre_speed", "1")      
    p_speed_type   = register_cvar("frupre_speed_type", "1") 
    p_height       = register_cvar("frupre_height", "12")
    p_colors       = register_cvar("frupre_colors", "1") 
    p_hud_type     = register_cvar("frupre_hud_type", "2") 
}

public fwd_PlayerPreThink(id) {
    if (!get_pcvar_num(p_enabled) || !is_user_alive(id)) return

    static buttons, oldbuttons, flags
    buttons = pev(id, pev_button); oldbuttons = pev(id, pev_oldbuttons); flags = pev(id, pev_flags)
    new Float:fTime = get_gametime()

    if (flags & FL_ONGROUND) {
        if (!g_onGround[id]) { 
            g_onGround[id] = true; 
            g_jFOG[id] = 0; g_dFOG[id] = 0;
            g_preSpeed[id] = calculate_speed(id)
        }
        g_jFOG[id]++; g_dFOG[id]++
    } else g_onGround[id] = false

    if ((buttons & IN_DUCK) && !(oldbuttons & IN_DUCK) && get_pcvar_num(p_show_duck)) {
        if (fTime - g_lastScrollTime[id] > 0.05) { g_dCount[id] = 0; g_dFire[id] = 0; }
        g_dCount[id]++
        if (g_dCount[id] >= 2) { 
            if (g_lastType[id] == 1) { g_jCount[id] = 0; g_jFire[id] = 0; } 
            g_lastType[id] = 2; 
        }
        if (!(flags & FL_DUCKING) && g_dFire[id] == 0) { 
            g_dFire[id] = g_dCount[id]; g_dFinalFOG[id] = g_dFOG[id]; 
            g_postSpeed[id] = calculate_speed(id)
        }
        g_lastScrollTime[id] = fTime
    }

    if ((buttons & IN_JUMP) && !(oldbuttons & IN_JUMP) && get_pcvar_num(p_show_jump)) {
        if (fTime - g_lastScrollTime[id] > 0.05) { g_jCount[id] = 0; g_jFire[id] = 0; }
        g_jCount[id]++
        if (g_jCount[id] >= 2) { 
            if (g_lastType[id] == 2) { g_dCount[id] = 0; g_dFire[id] = 0; } 
            g_lastType[id] = 1; 
        }
        if ((flags & FL_ONGROUND) && g_jFire[id] == 0) { 
            g_jFire[id] = g_jCount[id]; g_jFinalFOG[id] = g_jFOG[id]; 
            g_postSpeed[id] = calculate_speed(id)
        }
        g_lastScrollTime[id] = fTime
    }
    update_display(id, fTime)
}

calculate_speed(id) {
    static Float:vel[3]; pev(id, pev_velocity, vel)
    if (get_pcvar_num(p_speed_type) == 2)
        return floatround(floatsqroot(vel[0]*vel[0] + vel[1]*vel[1] + vel[2]*vel[2]))
    return floatround(floatsqroot(vel[0]*vel[0] + vel[1]*vel[1]))
}

update_display(id, Float:fTime) {
    new bool:showStats = (fTime - g_lastScrollTime[id] < 2.0)
    new bool:colorsOn = (get_pcvar_num(p_colors) == 1)
    new bool:fogOn = (get_pcvar_num(p_show_fog) == 1)
    new curFog = (g_lastType[id] == 1) ? g_jFinalFOG[id] : g_dFinalFOG[id]
    new curStep = (g_lastType[id] == 1) ? g_jFire[id] : g_dFire[id]
    
    if (get_pcvar_num(p_hud_type) == 1) {
        // --- TYPE 1: PRINT_CENTER ---
        static szStats[64], szFog[32], szSpeed[32], szPad[64], szMain[192]
        szStats[0] = 0; szFog[0] = 0; szSpeed[0] = 0; szPad[0] = 0
        for(new i = 0; i < clamp(get_pcvar_num(p_height), 0, 20); i++) add(szPad, 63, "^n")

        if (showStats && curFog <= 20) {
            if (g_lastType[id] == 1 && g_jCount[id] >= 2) formatex(szStats, 63, "J: %d [%d]", g_jCount[id], g_jFire[id])
            else if (g_lastType[id] == 2 && g_dCount[id] >= 2) formatex(szStats, 63, "D: %d [%d]", g_dCount[id], g_dFire[id])
            if (szStats[0] && fogOn) formatex(szFog, 31, "^nFOG: %d", curFog)
        }
        new iMode = get_pcvar_num(p_speed_mode)
        if (iMode == 1) formatex(szSpeed, 31, "^n%d", calculate_speed(id))
        else if (iMode == 2 && showStats) {
            if (curFog <= 20) formatex(szSpeed, 31, "^n%d, %d", g_preSpeed[id], g_postSpeed[id])
            else formatex(szSpeed, 31, "^n%d", g_postSpeed[id])
        }
        if (szStats[0] || szSpeed[0]) {
            formatex(szMain, 191, "%s%s%s%s", szPad, szStats, szFog, szSpeed)
            client_print(id, print_center, szMain)
        }
    } else {
        // --- TYPE 2: RGB HUD ---
        new Float:startY = 0.35 + (float(get_pcvar_num(p_height)) * 0.025)
        new Float:gap = 0.012
        static szLine[64]

        if (showStats && curFog <= 20) {
            szLine[0] = 0
            if (g_lastType[id] == 1 && g_jCount[id] >= 2) formatex(szLine, 63, "J: %d [%d]", g_jCount[id], g_jFire[id])
            else if (g_lastType[id] == 2 && g_dCount[id] >= 2) formatex(szLine, 63, "D: %d [%d]", g_dCount[id], g_dFire[id])
            
            if (szLine[0]) {
                new r = 255, g = 255, b = 255
                if (colorsOn) {
                    if (curStep <= 2) { r = 0; g = 255; b = 0; }        // Green
                    else if (curStep <= 4) { r = 255; g = 150; b = 0; } // Yellow/Orange
                    else { r = 255; g = 0; b = 0; }                    // Red
                }
                set_hudmessage(r, g, b, -1.0, startY, 0, 0.0, 0.1, 0.0, 0.0, 1)
                show_hudmessage(id, szLine)
            }
        }

        if (showStats && curFog <= 20 && fogOn) {
            formatex(szLine, 63, "FOG: %d", curFog)
            new r = 255, g = 255, b = 255
            if (colorsOn) {
                if (curFog <= 2) { r = 0; g = 255; b = 0; }         // Green
                else if (curFog == 3) { r = 255; g = 150; b = 0; }  // Yellow/Orange
                else { r = 255; g = 0; b = 0; }                    // Red
            }
            set_hudmessage(r, g, b, -1.0, startY + gap, 0, 0.0, 0.1, 0.0, 0.0, 2)
            show_hudmessage(id, szLine)
        }

        new iMode = get_pcvar_num(p_speed_mode)
        if (iMode > 0) {
            szLine[0] = 0
            if (iMode == 1) formatex(szLine, 63, "%d", calculate_speed(id))
            else if (iMode == 2 && showStats) {
                if (curFog <= 20) formatex(szLine, 63, "%d, %d", g_preSpeed[id], g_postSpeed[id])
                else formatex(szLine, 63, "%d", g_postSpeed[id])
            }
            if (szLine[0]) {
                new Float:speedY = startY + (fogOn ? (gap * 2.0) : gap)
                set_hudmessage(255, 255, 100, -1.0, speedY, 0, 0.0, 0.1, 0.0, 0.0, 3)
                show_hudmessage(id, szLine)
            }
        }
    }
}
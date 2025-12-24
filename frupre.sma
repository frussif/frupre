#include <amxmodx>
#include <fakemeta>

new g_jCount[33], g_jFire[33], g_jFinalFOG[33]
new g_dCount[33], g_dFire[33], g_dFinalFOG[33]
new g_jFOG[33], g_dFOG[33], bool:g_onGround[33]
new Float:g_lastScrollTime[33], g_lastType[33]

new p_enabled, p_show_jump, p_show_duck, p_show_fog, p_show_speed, p_height

public plugin_init() {
    register_plugin("Frupre Stable HUD", "4.4", "Custom")
    register_forward(FM_PlayerPreThink, "fwd_PlayerPreThink")
    
    p_enabled    = register_cvar("frupre_enable", "1")
    p_show_jump  = register_cvar("frupre_jump", "1")
    p_show_duck  = register_cvar("frupre_duck", "1")
    p_show_fog   = register_cvar("frupre_fog", "1")
    p_show_speed = register_cvar("frupre_speed", "1")
    p_height     = register_cvar("frupre_height", "12")
}

public fwd_PlayerPreThink(id) {
    if (!get_pcvar_num(p_enabled) || !is_user_alive(id)) return

    static buttons, oldbuttons, flags
    buttons = pev(id, pev_button); oldbuttons = pev(id, pev_oldbuttons); flags = pev(id, pev_flags)
    new Float:fTime = get_gametime()

    if (flags & FL_ONGROUND) {
        if (!g_onGround[id]) { g_onGround[id] = true; g_jFOG[id] = 0; g_dFOG[id] = 0; }
        g_jFOG[id]++; g_dFOG[id]++
    } else g_onGround[id] = false

    if ((buttons & IN_DUCK) && !(oldbuttons & IN_DUCK) && get_pcvar_num(p_show_duck)) {
        if (fTime - g_lastScrollTime[id] > 0.05) { g_dCount[id] = 0; g_dFire[id] = 0; }
        g_dCount[id]++
        if (g_dCount[id] >= 2) { if (g_lastType[id] == 1) { g_jCount[id] = 0; g_jFire[id] = 0; } g_lastType[id] = 2; }
        if (!(flags & FL_DUCKING) && g_dFire[id] == 0) { g_dFire[id] = g_dCount[id]; g_dFinalFOG[id] = g_dFOG[id]; }
        g_lastScrollTime[id] = fTime
    }

    if ((buttons & IN_JUMP) && !(oldbuttons & IN_JUMP) && get_pcvar_num(p_show_jump)) {
        if (fTime - g_lastScrollTime[id] > 0.05) { g_jCount[id] = 0; g_jFire[id] = 0; }
        g_jCount[id]++
        if (g_jCount[id] >= 2) { if (g_lastType[id] == 2) { g_dCount[id] = 0; g_dFire[id] = 0; } g_lastType[id] = 1; }
        if ((flags & FL_ONGROUND) && g_jFire[id] == 0) { g_jFire[id] = g_jCount[id]; g_jFinalFOG[id] = g_jFOG[id]; }
        g_lastScrollTime[id] = fTime
    }
    update_display(id, fTime)
}

update_display(id, Float:fTime) {
    static szStats[128], szFog[32], szSpeed[32], szPad[64]
    new bool:showStats = (fTime - g_lastScrollTime[id] < 2.0)
    
    // Top Padding (Dynamic Height)
    szPad[0] = 0
    new iHeight = clamp(get_pcvar_num(p_height), 0, 20)
    for(new i = 0; i < iHeight; i++) add(szPad, charsmax(szPad), "^n")
    
    szStats[0] = 0; szFog[0] = 0; szSpeed[0] = 0

    // Logic: If stats are hidden, we add empty lines to keep the Speed in the same spot
    if (showStats) {
        if (g_lastType[id] == 1 && g_jCount[id] >= 2 && g_jFinalFOG[id] <= 50)
            formatex(szStats, charsmax(szStats), "J: %d [%d]", g_jCount[id], g_jFire[id])
        else if (g_lastType[id] == 2 && g_dCount[id] >= 2 && g_dFinalFOG[id] <= 50)
            formatex(szStats, charsmax(szStats), "D: %d [%d]", g_dCount[id], g_dFire[id])
    }

    // Always reserve a line if Jump/Duck is enabled but not active
    if (!szStats[0]) copy(szStats, charsmax(szStats), " ") 

    if (get_pcvar_num(p_show_fog)) {
        if (szStats[0] && szStats[0] != ' ' && showStats) {
            new fogVal = (g_lastType[id] == 1) ? g_jFinalFOG[id] : g_dFinalFOG[id]
            formatex(szFog, charsmax(szFog), "^nFOG: %d", fogVal)
        } else {
            copy(szFog, charsmax(szFog), "^n ") // Invisible placeholder
        }
    }

    if (get_pcvar_num(p_show_speed)) {
        static Float:vel[3]; pev(id, pev_velocity, vel)
        formatex(szSpeed, charsmax(szSpeed), "^n%d", floatround(floatsqroot(vel[0]*vel[0] + vel[1]*vel[1])))
    }

    client_print(id, print_center, "%s%s%s%s", szPad, szStats, szFog, szSpeed)
}
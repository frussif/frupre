#include <amxmodx>
#include <fakemeta>
#include <nvault>

// Player Settings & Stats
new g_vault, g_pJump[33], g_pDuck[33], g_pFog[33], g_pSpeed[33], g_pSType[33], g_pHeight[33], g_pColor[33], g_pHud[33]
new g_jCount[33], g_jFire[33], g_jFinalFOG[33], g_dCount[33], g_dFire[33], g_dFinalFOG[33]
new g_jFOG[33], g_dFOG[33], bool:g_onGround[33], Float:g_lastScrollTime[33], g_lastType[33]
new g_preSpeed[33], g_postSpeed[33]

public plugin_init() {
    register_plugin("Frupre Pro Ultimate", "4.2", "Custom")
    register_forward(FM_PlayerPreThink, "fwd_PlayerPreThink")
    
    register_clcmd("say /fru", "menu_fru")
    register_clcmd("say !fru", "menu_fru")
    
    g_vault = nvault_open("frupre_settings")
}

public client_putinserver(id) load_data(id)
public client_disconnected(id) save_data(id)

public fwd_PlayerPreThink(id) {
    if (!is_user_alive(id)) return
    
    static buttons, oldbuttons, flags
    buttons = pev(id, pev_button); oldbuttons = pev(id, pev_oldbuttons); flags = pev(id, pev_flags)
    new Float:fTime = get_gametime()

    if (flags & FL_ONGROUND) {
        if (!g_onGround[id]) { 
            g_onGround[id] = true; g_jFOG[id] = 0; g_dFOG[id] = 0;
            g_preSpeed[id] = calculate_speed(id)
        }
        g_jFOG[id]++; g_dFOG[id]++
    } else g_onGround[id] = false

    if ((buttons & IN_DUCK) && !(oldbuttons & IN_DUCK) && g_pDuck[id]) {
        if (fTime - g_lastScrollTime[id] > 0.05) { g_dCount[id] = 0; g_dFire[id] = 0; }
        g_dCount[id]++
        if (g_dCount[id] >= 2) { if (g_lastType[id] == 1) { g_jCount[id] = 0; g_jFire[id] = 0; } g_lastType[id] = 2; }
        if (!(flags & FL_DUCKING) && g_dFire[id] == 0) { 
            g_dFire[id] = g_dCount[id]; g_dFinalFOG[id] = g_dFOG[id]; g_postSpeed[id] = calculate_speed(id) 
        }
        g_lastScrollTime[id] = fTime
    }

    if ((buttons & IN_JUMP) && !(oldbuttons & IN_JUMP) && g_pJump[id]) {
        if (fTime - g_lastScrollTime[id] > 0.05) { g_jCount[id] = 0; g_jFire[id] = 0; }
        g_jCount[id]++
        if (g_jCount[id] >= 2) { if (g_lastType[id] == 2) { g_dCount[id] = 0; g_dFire[id] = 0; } g_lastType[id] = 1; }
        if ((flags & FL_ONGROUND) && g_jFire[id] == 0) { 
            g_jFire[id] = g_jCount[id]; g_jFinalFOG[id] = g_jFOG[id]; g_postSpeed[id] = calculate_speed(id)
        }
        g_lastScrollTime[id] = fTime
    }
    update_display(id, fTime)
}

calculate_speed(id) {
    static Float:vel[3]; pev(id, pev_velocity, vel)
    if (g_pSType[id] == 2) return floatround(floatsqroot(vel[0]*vel[0] + vel[1]*vel[1] + vel[2]*vel[2]))
    return floatround(floatsqroot(vel[0]*vel[0] + vel[1]*vel[1]))
}

update_display(id, Float:fTime) {
    static szMain[192], szStats[64], szFog[32], szSpeed[32], szPad[64]
    szStats[0]=0; szFog[0]=0; szSpeed[0]=0; szPad[0]=0
    
    new bool:showStats = (fTime - g_lastScrollTime[id] < 2.0)
    new curFog = (g_lastType[id] == 1) ? g_jFinalFOG[id] : g_dFinalFOG[id]
    
    if (g_pHud[id] == 1) {
        for(new i = 0; i < clamp(g_pHeight[id], 0, 20); i++) add(szPad, 63, "^n")
        if (showStats && curFog <= 20) {
            formatex(szStats, 63, "%s: %d [%d]", (g_lastType[id] == 1) ? "J" : "D", (g_lastType[id] == 1) ? g_jCount[id] : g_dCount[id], (g_lastType[id] == 1) ? g_jFire[id] : g_dFire[id])
            if (g_pFog[id]) formatex(szFog, 31, "^nFOG: %d", curFog)
        }
        if (g_pSpeed[id] == 1) formatex(szSpeed, 31, "^n%d", calculate_speed(id))
        else if (g_pSpeed[id] == 2 && showStats) formatex(szSpeed, 31, (curFog > 20) ? "^n%d" : "^n%d, %d", g_preSpeed[id], g_postSpeed[id])
        if (szStats[0] || szSpeed[0]) { formatex(szMain, 191, "%s%s%s%s", szPad, szStats, szFog, szSpeed); client_print(id, print_center, szMain); }
    } else {
        new Float:sY = 0.35 + (float(g_pHeight[id]) * 0.025), r=255, g=255, b=255
        if (showStats && curFog <= 20) {
            if (g_pColor[id]) { if (curFog <= 2) { r=0; g=255; b=0; } else if (curFog == 3) { r=255; g=150; b=0; } else { r=255; g=0; b=0; } }
            formatex(szStats, 63, "%s: %d [%d]", (g_lastType[id] == 1) ? "J" : "D", (g_lastType[id] == 1) ? g_jCount[id] : g_dCount[id], (g_lastType[id] == 1) ? g_jFire[id] : g_dFire[id])
            set_hudmessage(r, g, b, -1.0, sY, 0, 0.0, 0.1, 0.0, 0.0, 3); show_hudmessage(id, szStats)
            if (g_pFog[id]) { formatex(szFog, 31, "FOG: %d", curFog); set_hudmessage(r, g, b, -1.0, sY+0.012, 0, 0.0, 0.1, 0.0, 0.0, 4); show_hudmessage(id, szFog); }
        }
        if (g_pSpeed[id] > 0) {
            if (g_pSpeed[id] == 1) formatex(szSpeed, 31, "%d", calculate_speed(id))
            else if (showStats) formatex(szSpeed, 31, (curFog > 20) ? "%d" : "%d, %d", g_preSpeed[id], g_postSpeed[id])
            if (szSpeed[0]) { set_hudmessage(255, 255, 100, -1.0, sY+(g_pFog[id]?0.024:0.012), 0, 0.0, 0.1, 0.0, 0.0, -1); show_hudmessage(id, szSpeed); }
        }
    }
}

public menu_fru(id) {
    new menu = menu_create("\yFrupre Settings \w[Page 1]", "menu_handler")
    menu_additem(menu, g_pJump[id] ? "Jump Stats: \yON" : "Jump Stats: \rOFF")
    menu_additem(menu, g_pDuck[id] ? "Duck Stats: \yON" : "Duck Stats: \rOFF")
    menu_additem(menu, g_pFog[id] ? "FOG Display: \yON" : "FOG Display: \rOFF")
    new sp[32]; formatex(sp, 31, "Speed Mode: \y%s", (g_pSpeed[id]==0)?"OFF":(g_pSpeed[id]==1?"Live":"Static")); menu_additem(menu, sp)
    menu_additem(menu, "Height: \yIncrease (+)")
    menu_additem(menu, "Height: \rDecrease (-)")
    menu_additem(menu, g_pColor[id] ? "Adaptive Colors: \yON" : "Adaptive Colors: \rOFF")
    
    menu_setprop(menu, MPROP_PERPAGE, 0)
    menu_additem(menu, "\wMore Options...") // Item 7
    menu_additem(menu, "\gSave Settings")   // Item 8
    menu_display(id, menu)
}

public menu_handler(id, menu, item) {
    if (item == MENU_EXIT) { menu_destroy(menu); return PLUGIN_HANDLED; }
    switch(item) {
        case 0: g_pJump[id]=!g_pJump[id]; case 1: g_pDuck[id]=!g_pDuck[id]; case 2: g_pFog[id]=!g_pFog[id]
        case 3: { g_pSpeed[id]++; if (g_pSpeed[id]>2) g_pSpeed[id]=0; }
        case 4: { if (g_pHeight[id] > 0) g_pHeight[id]--; } 
        case 5: { if (g_pHeight[id] < 20) g_pHeight[id]++; }
        case 6: g_pColor[id]=!g_pColor[id]
        case 7: { menu_more(id); menu_destroy(menu); return PLUGIN_HANDLED; }
        case 8: { save_data(id); client_print(id, print_chat, "[Frupre] Settings Saved!"); menu_destroy(menu); return PLUGIN_HANDLED; }
    }
    menu_fru(id); return PLUGIN_HANDLED
}

public menu_more(id) {
    new menu = menu_create("\yFrupre Settings \w[Page 2]", "handler_more")
    menu_additem(menu, g_pSType[id] == 1 ? "Speed Type: \yXY" : "Speed Type: \yXYZ") // 0
    menu_additem(menu, g_pHud[id] == 1 ? "HUD Type: \yCenterPrint" : "HUD Type: \yRGB HUD") // 1
    menu_additem(menu, "Back to Main") // 2
    
    // Manual numbering for the save button on slot 9
    menu_additem(menu, "\gSave Settings", .callback = -1) // This will be index 3 but we'll map it to key 9 visually
    
    menu_setprop(menu, MPROP_PERPAGE, 0)
    menu_display(id, menu)
}

public handler_more(id, menu, item) {
    if (item == MENU_EXIT) { menu_destroy(menu); return PLUGIN_HANDLED; }
    switch(item) {
        case 0: g_pSType[id]=(g_pSType[id]==1?2:1)
        case 1: g_pHud[id]=(g_pHud[id]==1?2:1)
        case 2: { menu_fru(id); menu_destroy(menu); return PLUGIN_HANDLED; }
        case 3: { save_data(id); client_print(id, print_chat, "[Frupre] Settings Saved!"); menu_destroy(menu); return PLUGIN_HANDLED; }
    }
    menu_more(id); return PLUGIN_HANDLED
}

save_data(id) {
    new auth[32], data[128]; get_user_authid(id, auth, 31)
    formatex(data, 127, "%d %d %d %d %d %d %d %d", g_pJump[id], g_pDuck[id], g_pFog[id], g_pSpeed[id], g_pSType[id], g_pHeight[id], g_pColor[id], g_pHud[id])
    nvault_set(g_vault, auth, data)
}

load_data(id) {
    new auth[32], data[128]; get_user_authid(id, auth, 31)
    if (nvault_get(g_vault, auth, data, 127)) {
        new j[2], d[2], f[2], s[2], st[2], h[3], c[2], hu[2]
        parse(data, j, 1, d, 1, f, 1, s, 1, st, 1, h, 2, c, 1, hu, 1)
        g_pJump[id]=str_to_num(j); g_pDuck[id]=str_to_num(d); g_pFog[id]=str_to_num(f); g_pSpeed[id]=str_to_num(s)
        g_pSType[id]=str_to_num(st); g_pHeight[id]=str_to_num(h); g_pColor[id]=str_to_num(c); g_pHud[id]=str_to_num(hu)
    } else { g_pJump[id]=1; g_pDuck[id]=1; g_pFog[id]=1; g_pSpeed[id]=1; g_pSType[id]=1; g_pHeight[id]=12; g_pColor[id]=1; g_pHud[id]=2; }
}
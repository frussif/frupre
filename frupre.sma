#include <amxmodx>
#include <fakemeta>

// Settings & Layout
new g_pMode[33], g_pSType[33], g_pHeight[33], g_pColor[33], g_pEnabled[33], g_pScrollInfo[33], g_pGap[33]
new g_pLayout[33][128]

// Movement Data
new g_jCount[33], g_jFire[33], g_jFinalFOG[33], g_dCount[33], g_dFire[33], g_dFinalFOG[33]
new g_jFOG[33], g_dFOG[33], bool:g_onGround[33], Float:g_lastScrollTime[33], g_lastType[33], g_staticSpeed[33]
new Float:g_preSpeed[33], g_finalGain[33]
new g_frames[33], g_syncFrames[33], g_overlapFrames[33], g_deadFrames[33], Float:g_lastYaw[33], g_finalSync[33], g_finalOverlap[33], g_finalDead[33]
new Float:g_takeOff[33][3], Float:g_finalDist[33], g_strafes[33], g_lastSide[33], g_finalStrafes[33]

// Optimization Timer
new Float:g_lastHudUpdate[33]

public plugin_init() {
    register_plugin("Frupre Pro Ultimate", "27.7", "Full-Modular")
    register_forward(FM_PlayerPreThink, "fwd_PlayerPreThink")
    register_clcmd("say /frupre", "menu_fru")
    register_clcmd("say !frupre", "menu_fru")
    
    register_concmd("frupre", "cmd_toggle", ADMIN_USER, "<0/1>")
    register_concmd("frupre_layout", "cmd_layout", ADMIN_USER, "<string>")

    // Hot-Plug: Initialize for players already connected
    new players[32], num, id;
    get_players(players, num)
    for(new i = 0; i < num; i++) {
        id = players[i]
        if(is_user_connected(id)) init_player(id)
    }
}

public client_putinserver(id) {
    init_player(id)
}

public init_player(id) {
    g_pEnabled[id]=1; g_pMode[id]=3; g_pSType[id]=1; g_pHeight[id]=12; 
    g_pColor[id]=1; g_pScrollInfo[id]=1; g_pGap[id]=13;
    copy(g_pLayout[id], 127, "FOG: %fog %n %premsg %n %speedstatic (%gain)")
    set_task(0.5, "load_data", id)
}

public cmd_toggle(id) {
    new arg[8]; read_argv(1, arg, 7)
    if(!arg[0]) {
        console_print(id, "[Frupre] Plugin is %s", g_pEnabled[id] ? "Enabled" : "Disabled")
        return PLUGIN_HANDLED
    }
    g_pEnabled[id] = str_to_num(arg); save_data(id); return PLUGIN_HANDLED
}

public cmd_layout(id) {
    new arg[128]; read_args(arg, 127); remove_quotes(arg)
    if(!arg[0]) {
        console_print(id, "^n[Frupre] Current Layout: %s", g_pLayout[id])
        return PLUGIN_HANDLED
    }
    copy(g_pLayout[id], 127, arg); console_print(id, "[Frupre] Layout updated."); save_data(id)
    return PLUGIN_HANDLED
}

public fwd_PlayerPreThink(id) {
    if (!is_user_alive(id) || !g_pEnabled[id]) return
    
    static buttons, oldbuttons, flags; 
    buttons = pev(id, pev_button); oldbuttons = pev(id, pev_oldbuttons); flags = pev(id, pev_flags)
    
    new Float:fTime = get_gametime()
    new curSpeed = calculate_speed(id)

    // Physics Logic
    if (flags & FL_ONGROUND) {
        if (!g_onGround[id]) { 
            g_onGround[id] = true; 
            static Float:vLand[3]; pev(id, pev_origin, vLand)
            g_finalDist[id] = get_distance_f(g_takeOff[id], vLand) + ((flags & FL_DUCKING) ? 33.03125 : 32.03125)
            new gain = curSpeed - floatround(g_preSpeed[id])
            g_finalGain[id] = (gain > 0) ? gain : 0
            
            if (g_frames[id] > 0) {
                g_finalSync[id] = (g_syncFrames[id] * 100) / g_frames[id]
                g_finalOverlap[id] = g_overlapFrames[id]; g_finalDead[id] = g_deadFrames[id]
                g_finalStrafes[id] = g_strafes[id]
            }
            g_jFOG[id] = 0; g_dFOG[id] = 0; 
        }
        g_jFOG[id]++; g_dFOG[id]++
    } else {
        if (g_onGround[id]) {
            g_onGround[id] = false; g_preSpeed[id] = float(curSpeed); pev(id, pev_origin, g_takeOff[id])
            g_frames[id] = 0; g_syncFrames[id] = 0; g_overlapFrames[id] = 0; g_deadFrames[id] = 0; 
            g_strafes[id] = 0; g_lastSide[id] = 0;
        }
        g_frames[id]++; 
        static Float:ang[3]; pev(id, pev_angles, ang)
        new Float:yD = ang[1] - g_lastYaw[id]
        if (yD > 180.0) yD -= 360.0; else if (yD < -180.0) yD += 360.0
        
        new bool:mL = (buttons & IN_MOVELEFT) ? true : false
        new bool:mR = (buttons & IN_MOVERIGHT) ? true : false

        if (mL && !mR) { if (g_lastSide[id] == 2) g_strafes[id]++; g_lastSide[id] = 1; }
        else if (mR && !mL) { if (g_lastSide[id] == 1) g_strafes[id]++; g_lastSide[id] = 2; }
        
        if (mL && mR) g_overlapFrames[id]++; else if (!mL && !mR) g_deadFrames[id]++;
        else if ((yD > 0.0 && mL) || (yD < 0.0 && mR)) g_syncFrames[id]++;
        g_lastYaw[id] = ang[1]
    }

    if ((buttons & IN_DUCK) && !(oldbuttons & IN_DUCK) && (g_pMode[id] & 2)) {
        if (fTime - g_lastScrollTime[id] > 0.05) { g_dCount[id] = 0; g_dFire[id] = 0; }
        g_dCount[id]++; if (g_dCount[id] >= 2) { if (g_lastType[id] == 1) { g_jCount[id] = 0; g_jFire[id] = 0; } g_lastType[id] = 2; }
        if (!(flags & FL_DUCKING) && g_dFire[id] == 0 && (flags & FL_ONGROUND)) { g_dFire[id] = g_dCount[id]; g_dFinalFOG[id] = g_dFOG[id]; g_staticSpeed[id] = curSpeed; }
        g_lastScrollTime[id] = fTime
        update_display(id, fTime)
    }
    if ((buttons & IN_JUMP) && !(oldbuttons & IN_JUMP) && (g_pMode[id] & 1)) {
        if (fTime - g_lastScrollTime[id] > 0.05) { g_jCount[id] = 0; g_jFire[id] = 0; }
        g_jCount[id]++; if (g_jCount[id] >= 2) { if (g_lastType[id] == 2) { g_dCount[id] = 0; g_dFire[id] = 0; } g_lastType[id] = 1; }
        if ((flags & FL_ONGROUND) && g_jFire[id] == 0) { g_jFire[id] = g_jCount[id]; g_jFinalFOG[id] = g_jFOG[id]; g_staticSpeed[id] = curSpeed; }
        g_lastScrollTime[id] = fTime
        update_display(id, fTime)
    }
    
    if (fTime - g_lastHudUpdate[id] >= 0.1) {
        update_display(id, fTime)
        g_lastHudUpdate[id] = fTime
    }
}

public update_display(id, Float:fTime) {
    if (fTime - g_lastScrollTime[id] > 2.0) return

    new curFog = (g_lastType[id] == 1) ? g_jFinalFOG[id] : g_dFinalFOG[id]
    
    // Smart Hiding: Only show HUD if FOG is under 20 (active bhop/duck session)
    if (curFog >= 20) return

    static szBuffer[192], szVal[32]
    new curStep = (g_lastType[id] == 1) ? g_jFire[id] : g_dFire[id]
    new curCount = (g_lastType[id] == 1) ? g_jCount[id] : g_dCount[id]
    
    new r2 = 255, g2 = 255, b2 = 255 
    if (g_pColor[id] == 1) {
        if (curFog <= 2) { r2 = 0; g2 = 255; b2 = 0; }
        else if (curFog == 3) { r2 = 255; g2 = 150; b2 = 0; }
        else { r2 = 255; g2 = 0; b2 = 0; }
    } else if (g_pColor[id] == 2) {
         new s = g_staticSpeed[id]
         if (s >= 300) { r2 = 0; g2 = 0; b2 = 255; }
         else if (s >= 280) { r2 = 0; g2 = 255; b2 = 0; }
         else if (s >= 240) { r2 = 0; g2 = 255; b2 = 255; }
         else if (s >= 220) { r2 = 255; g2 = 255; b2 = 0; }
         else { r2 = 255; g2 = 0; b2 = 0; }
    }

    new Float:startY = 0.35 + (float(g_pHeight[id]-10) * 0.025)
    
    if (g_pScrollInfo[id] && curCount >= 2) {
        new r = 255, g = 255, b = 255
        if (g_pColor[id] > 0) {
            if (curStep <= 2) { r = 0; g = 255; b = 0; }
            else if (curStep <= 4) { r = 255; g = 150; b = 0; }
            else { r = 255; g = 0; b = 0; }
        }
        set_hudmessage(r, g, b, -1.0, startY, 0, 0.0, 0.2, 0.0, 0.0, 3)
        show_hudmessage(id, "%d [%d]", curCount, curStep)
    }

    copy(szBuffer, 191, g_pLayout[id])
    replace_all(szBuffer, 191, "%n", "^n")
    
    if (containi(szBuffer, "%premsg") != -1) {
        if (g_staticSpeed[id] >= 300) copy(szVal, 31, "Speed over 300")
        else if (g_staticSpeed[id] >= 280) copy(szVal, 31, "Perfect Speed")
        else if (g_staticSpeed[id] >= 240) copy(szVal, 31, "Good Speed")
        else if (g_staticSpeed[id] >= 220) copy(szVal, 31, "Bad Speed")
        else copy(szVal, 31, "Terrible Speed")
        replace_all(szBuffer, 191, "%premsg", szVal)
    }

    num_to_str(curFog, szVal, 31); replace_all(szBuffer, 191, "%fog", szVal)
    num_to_str(g_finalGain[id], szVal, 31); replace_all(szBuffer, 191, "%gain", szVal)
    num_to_str(g_finalSync[id], szVal, 31); replace_all(szBuffer, 191, "%sync", szVal)
    num_to_str(g_staticSpeed[id], szVal, 31); replace_all(szBuffer, 191, "%speedstatic", szVal)
    num_to_str(calculate_speed(id), szVal, 31); replace_all(szBuffer, 191, "%speed", szVal)
    num_to_str(g_finalOverlap[id], szVal, 31); replace_all(szBuffer, 191, "%overlap", szVal)
    num_to_str(g_finalDead[id], szVal, 31); replace_all(szBuffer, 191, "%deadair", szVal)
    num_to_str(g_finalStrafes[id] + (g_finalStrafes[id] > 0 ? 1 : 0), szVal, 31); replace_all(szBuffer, 191, "%strafes", szVal)
    formatex(szVal, 31, "%.1f", g_finalDist[id]); replace_all(szBuffer, 191, "%dist", szVal)

    set_hudmessage(r2, g2, b2, -1.0, startY + (float(g_pGap[id]) / 1000.0), 0, 0.0, 0.2, 0.0, 0.0, 4)
    show_hudmessage(id, szBuffer)
}

calculate_speed(id) {
    static Float:vel[3]; pev(id, pev_velocity, vel)
    return floatround(floatsqroot(vel[0]*vel[0] + vel[1]*vel[1] + (g_pSType[id] == 2 ? vel[2]*vel[2] : 0.0)))
}

public menu_fru(id) { 
    new menu = menu_create("\yFrupre Settings", "menu_handler"), tmp[64] 
    menu_setprop(menu, MPROP_PERPAGE, 0)
    formatex(tmp, 63, "Plugin: %s", g_pEnabled[id] ? "\yOn" : "\rOff"); menu_additem(menu, tmp) 
    static const modeNames[][] = { "Off", "Jump", "Duck", "Both" } 
    formatex(tmp, 63, "Mode: \y%s", modeNames[g_pMode[id]]); menu_additem(menu, tmp) 
    formatex(tmp, 63, "Scroll Info: %s", g_pScrollInfo[id] ? "\yOn" : "\rOff"); menu_additem(menu, tmp) 
    static const colorLabels[][] = { "\rOff", "\yFOG", "\yPre" }
    formatex(tmp, 63, "Colors: %s", colorLabels[g_pColor[id]]); menu_additem(menu, tmp) 
    formatex(tmp, 63, "HUD Height: \y%d \r(-)", g_pHeight[id]); menu_additem(menu, tmp) 
    formatex(tmp, 63, "HUD Height: \y%d \y(+)", g_pHeight[id]); menu_additem(menu, tmp) 
    formatex(tmp, 63, "Gap: \y%.3f \r(-)", float(g_pGap[id]) / 1000.0); menu_additem(menu, tmp) 
    formatex(tmp, 63, "Gap: \y%.3f \y(+)", float(g_pGap[id]) / 1000.0); menu_additem(menu, tmp) 
    formatex(tmp, 63, "Speed Type: \y%s", g_pSType[id] == 1 ? "XY" : "XYZ"); menu_additem(menu, tmp)
    menu_display(id, menu) 
} 

public menu_handler(id, menu, item) { 
    if (item == MENU_EXIT) { menu_destroy(menu); return PLUGIN_HANDLED; } 
    switch(item) { 
        case 0: g_pEnabled[id] = !g_pEnabled[id] 
        case 1: { g_pMode[id]++; if(g_pMode[id]>3) g_pMode[id]=0; } 
        case 2: g_pScrollInfo[id] = !g_pScrollInfo[id] 
        case 3: { g_pColor[id]++; if(g_pColor[id]>2) g_pColor[id]=0; }
        case 4: { if(g_pHeight[id] > 0) g_pHeight[id]--; }
        case 5: { if(g_pHeight[id] < 20) g_pHeight[id]++; }
        case 6: { if(g_pGap[id] > 0) g_pGap[id]--; }
        case 7: { if(g_pGap[id] < 50) g_pGap[id]++; }
        case 8: g_pSType[id] = (g_pSType[id] == 1 ? 2 : 1)
    } 
    save_data(id); menu_destroy(menu); menu_fru(id); return PLUGIN_HANDLED 
}

public save_data(id) {
    new authid[32], vaultkey[64], vaultdata[256]
    get_user_authid(id, authid, 31); format(vaultkey, 63, "FRUPRE_%s", authid)
    format(vaultdata, 255, "%d %d %d %d %d %d %d ^"%s^"", g_pEnabled[id], g_pMode[id], g_pScrollInfo[id], g_pHeight[id], g_pColor[id], g_pGap[id], g_pSType[id], g_pLayout[id])
    set_vaultdata(vaultkey, vaultdata)
}

public load_data(id) {
    new authid[32], vaultkey[64], vaultdata[256]
    get_user_authid(id, authid, 31); format(vaultkey, 63, "FRUPRE_%s", authid)
    if (get_vaultdata(vaultkey, vaultdata, 255)) {
        new v[7][4]
        parse(vaultdata, v[0], 3, v[1], 3, v[2], 3, v[3], 3, v[4], 3, v[5], 3, v[6], 3, g_pLayout[id], 127)
        g_pEnabled[id]=str_to_num(v[0]); g_pMode[id]=str_to_num(v[1]); g_pScrollInfo[id]=str_to_num(v[2]);
        g_pHeight[id]=str_to_num(v[3]); g_pColor[id]=str_to_num(v[4]); g_pGap[id]=str_to_num(v[5]); g_pSType[id]=str_to_num(v[6])
    }
}
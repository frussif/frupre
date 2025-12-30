#include <amxmodx>
#include <fakemeta>

new g_pMode[33], g_pFog[33], g_pSpeed[33], g_pSType[33], g_pHeight[33], g_pColor[33], g_pHud[33], g_pEnabled[33], g_pScrollInfo[33], g_pShowStats[33], g_pGap[33]
new g_jCount[33], g_jFire[33], g_jFinalFOG[33], g_dCount[33], g_dFire[33], g_dFinalFOG[33]
new g_jFOG[33], g_dFOG[33], bool:g_onGround[33], Float:g_lastScrollTime[33], g_lastType[33], g_staticSpeed[33]
new Float:g_preSpeed[33], g_finalGain[33]
new g_frames[33], g_syncFrames[33], g_overlapFrames[33], g_deadFrames[33], Float:g_lastYaw[33], g_finalSync[33], g_finalOverlap[33], g_finalDead[33]
new Float:g_takeOff[33][3], Float:g_finalDist[33]

public plugin_init() {
    register_plugin("Frupre Pro Ultimate", "12.0", "Stats-GapAdjustable")
    register_forward(FM_PlayerPreThink, "fwd_PlayerPreThink")
    register_clcmd("say /frupre", "menu_fru")
    register_clcmd("say /load", "load_data")
}

public client_putinserver(id) {
    g_pEnabled[id]=1; g_pMode[id]=3; g_pFog[id]=1; g_pSpeed[id]=1; 
    g_pSType[id]=1; g_pHeight[id]=12; g_pColor[id]=1; g_pHud[id]=2; g_pScrollInfo[id]=1; g_pShowStats[id]=1;
    g_pGap[id]=13; // Default 0.013
    set_task(0.1, "load_data", id)
}

public fwd_PlayerPreThink(id) {
    if (!is_user_alive(id) || !g_pEnabled[id]) return
    static buttons, oldbuttons, flags; buttons = pev(id, pev_button); oldbuttons = pev(id, pev_oldbuttons); flags = pev(id, pev_flags)
    new Float:fTime = get_gametime(), curSpeed = calculate_speed(id)

    if (flags & FL_ONGROUND) {
        if (!g_onGround[id]) { 
            g_onGround[id] = true; 
            new Float:vLand[3]; pev(id, pev_origin, vLand)
            new bool:ducking = (pev(id, pev_flags) & FL_DUCKING) ? true : false
            g_finalDist[id] = get_distance_f(g_takeOff[id], vLand) + (ducking ? 33.03125 : 32.03125)
            new gain = curSpeed - floatround(g_preSpeed[id]);
            g_finalGain[id] = (gain > 0) ? gain : 0;
            if (g_frames[id] > 0) {
                g_finalSync[id] = (g_syncFrames[id] * 100) / g_frames[id]
                g_finalOverlap[id] = g_overlapFrames[id]; g_finalDead[id] = g_deadFrames[id]
            }
            g_jFOG[id] = 0; g_dFOG[id] = 0; 
        }
        g_jFOG[id]++; g_dFOG[id]++
    } else {
        if (g_onGround[id]) {
            g_onGround[id] = false; g_preSpeed[id] = float(curSpeed); pev(id, pev_origin, g_takeOff[id]);
            g_frames[id] = 0; g_syncFrames[id] = 0; g_overlapFrames[id] = 0; g_deadFrames[id] = 0
        }
        g_frames[id]++; static Float:ang[3]; pev(id, pev_angles, ang); new Float:yD = ang[1] - g_lastYaw[id]
        if (yD > 180.0) yD -= 360.0; else if (yD < -180.0) yD += 360.0
        new bool:mL = (buttons & IN_MOVELEFT), bool:mR = (buttons & IN_MOVERIGHT)
        if (mL && mR) g_overlapFrames[id]++;
        else if (!mL && !mR) g_deadFrames[id]++;
        else if ((yD > 0.0 && mL) || (yD < 0.0 && mR)) g_syncFrames[id]++;
        g_lastYaw[id] = ang[1]
    }

    if ((buttons & IN_DUCK) && !(oldbuttons & IN_DUCK) && (g_pMode[id] == 2 || g_pMode[id] == 3)) {
        if (fTime - g_lastScrollTime[id] > 0.05) { g_dCount[id] = 0; g_dFire[id] = 0; }
        g_dCount[id]++
        if (g_dCount[id] >= 2) { if (g_lastType[id] == 1) { g_jCount[id] = 0; g_jFire[id] = 0; } g_lastType[id] = 2; }
        if (!(flags & FL_DUCKING) && g_dFire[id] == 0 && (flags & FL_ONGROUND)) { 
            g_dFire[id] = g_dCount[id]; g_dFinalFOG[id] = g_dFOG[id]; g_staticSpeed[id] = curSpeed; 
        }
        g_lastScrollTime[id] = fTime
    }
    if ((buttons & IN_JUMP) && !(oldbuttons & IN_JUMP) && (g_pMode[id] == 1 || g_pMode[id] == 3)) {
        if (fTime - g_lastScrollTime[id] > 0.05) { g_jCount[id] = 0; g_jFire[id] = 0; }
        g_jCount[id]++
        if (g_jCount[id] >= 2) { if (g_lastType[id] == 2) { g_dCount[id] = 0; g_dFire[id] = 0; } g_lastType[id] = 1; }
        if ((flags & FL_ONGROUND) && g_jFire[id] == 0) { 
            g_jFire[id] = g_jCount[id]; g_jFinalFOG[id] = g_jFOG[id]; g_staticSpeed[id] = curSpeed; 
        }
        g_lastScrollTime[id] = fTime
    }
    update_display(id, fTime)
}

calculate_speed(id) {
    static Float:vel[3]; pev(id, pev_velocity, vel)
    return (g_pSType[id] == 2) ? floatround(floatsqroot(vel[0]*vel[0] + vel[1]*vel[1] + vel[2]*vel[2])) : floatround(floatsqroot(vel[0]*vel[0] + vel[1]*vel[1]))
}

update_display(id, Float:fTime) {
    new bool:showStats = (fTime - g_lastScrollTime[id] < 2.0), bool:colorsOn = (g_pColor[id] == 1), bool:fogOn = (g_pFog[id] == 1)
    new curFog = (g_lastType[id] == 1) ? g_jFinalFOG[id] : g_dFinalFOG[id]
    new curStep = (g_lastType[id] == 1) ? g_jFire[id] : g_dFire[id]
    new curCount = (g_lastType[id] == 1) ? g_jCount[id] : g_dCount[id]
    new bool:isJumpRelevant = (showStats && (curFog <= 20 || g_finalDist[id] > 0.0))

    new r2 = 255, g2 = 255, b2 = 255 
    if (colorsOn) {
        if (curFog <= 2) { r2 = 0; g2 = 255; b2 = 0; }
        else if (curFog == 3) { r2 = 255; g2 = 150; b2 = 0; }
        else { r2 = 255; g2 = 0; b2 = 0; }
    }

    if (g_pHud[id] == 1) { // Center Print
        static szMain[256], szPad[64]; szMain[0] = 0; szPad[0] = 0
        for(new i = 0; i < clamp(g_pHeight[id], 0, 20); i++) add(szPad, 63, "^n")
        
        if (isJumpRelevant && g_pScrollInfo[id] && curCount >= 2) 
            formatex(szMain, 255, "%d [%d]^n", curCount, curStep)
            
        if (isJumpRelevant && fogOn && curFog <= 20) {
            static szFog[32]; formatex(szFog, 31, "FOG: %d^n", curFog); add(szMain, 255, szFog)
        }

        if (g_pSpeed[id] == 2 && showStats) {
            static szSp[64]; 
            if (isJumpRelevant && g_finalGain[id] > 0) formatex(szSp, 63, "%d (%d)^n", g_staticSpeed[id], g_finalGain[id])
            else formatex(szSp, 63, "%d^n", g_staticSpeed[id])
            add(szMain, 255, szSp)
        }

        if (isJumpRelevant && g_pShowStats[id] && g_finalDist[id] > 0.0) {
            static szSt[64]; formatex(szSt, 63, "%d%%%% | %d/%d | %.1f", g_finalSync[id], g_finalOverlap[id], g_finalDead[id], g_finalDist[id])
            add(szMain, 255, szSt)
        } else if (g_pSpeed[id] == 1) {
            static szLv[32]; formatex(szLv, 31, "%d", calculate_speed(id)); add(szMain, 255, szLv)
        }

        if (szMain[0]) {
            static szFinal[320]; formatex(szFinal, 319, "%s%s", szPad, szMain)
            client_print(id, print_center, szFinal)
        }
    } else { // RGB HUD
        new Float:startY = 0.35 + (float(g_pHeight[id]-10) * 0.025)
        
        if (isJumpRelevant && g_pScrollInfo[id] && curCount >= 2) {
            new r = 255, g = 255, b = 255
            if (colorsOn) {
                if (curStep <= 2) { r = 0; g = 255; b = 0; }
                else if (curStep <= 4) { r = 255; g = 150; b = 0; }
                else { r = 255; g = 0; b = 0; }
            }
            set_hudmessage(r, g, b, -1.0, startY, 0, 0.0, 0.1, 0.0, 0.0, 3)
            show_hudmessage(id, "%d [%d]", curCount, curStep)
        }

        static szBlock2[192]; szBlock2[0] = 0
        if (isJumpRelevant && fogOn && curFog <= 20) formatex(szBlock2, 191, "FOG: %d^n", curFog)

        if (g_pSpeed[id] == 2 && showStats) {
            static szSp[64];
            if (isJumpRelevant && g_finalGain[id] > 0) formatex(szSp, 63, "%d (%d)^n", g_staticSpeed[id], g_finalGain[id])
            else formatex(szSp, 63, "%d^n", g_staticSpeed[id])
            add(szBlock2, 191, szSp)
        }

        if (isJumpRelevant && g_pShowStats[id] && g_finalDist[id] > 0.0) {
            static szSt[64]; formatex(szSt, 63, "%d%%%% | %d/%d | %.1f", g_finalSync[id], g_finalOverlap[id], g_finalDead[id], g_finalDist[id])
            add(szBlock2, 191, szSt)
        } else if (g_pSpeed[id] == 1) {
            static szLv[32]; formatex(szLv, 31, "%d", calculate_speed(id)); add(szBlock2, 191, szLv)
        }

        if (szBlock2[0]) {
            set_hudmessage(r2, g2, b2, -1.0, startY + (float(g_pGap[id]) / 1000.0), 0, 0.0, 0.1, 0.0, 0.0, 4)
            show_hudmessage(id, szBlock2)
        }
    }
}

public menu_fru(id) {
    new menu = menu_create("\yFrupre Settings [1/2]", "menu_handler"), tmp[64]
    
    formatex(tmp, 63, "Plugin: %s", g_pEnabled[id] ? "\yOn" : "\rOff"); menu_additem(menu, tmp)
    static const modeNames[][] = { "Off", "Jump", "Duck", "Both" }
    formatex(tmp, 63, "Mode: \y%s", modeNames[g_pMode[id]]); menu_additem(menu, tmp)
    formatex(tmp, 63, "Scroll Info: %s", g_pScrollInfo[id] ? "\yOn" : "\rOff"); menu_additem(menu, tmp)
    formatex(tmp, 63, "FOG: %s", g_pFog[id] ? "\yOn" : "\rOff"); menu_additem(menu, tmp)
    formatex(tmp, 63, "Speed: \y%s", (g_pSpeed[id]==0)?"Off":(g_pSpeed[id]==1?"Live":"Static")); menu_additem(menu, tmp)
    formatex(tmp, 63, "Stats: %s", g_pShowStats[id] ? "\yOn" : "\rOff"); menu_additem(menu, tmp)
    menu_additem(menu, "\wNext Page")

    menu_setprop(menu, MPROP_EXIT, MEXIT_ALL) 
    menu_setprop(menu, MPROP_EXITNAME, "Close") 
    
    menu_display(id, menu)
}

public menu_handler(id, menu, item) {
    if (item == MENU_EXIT) { menu_destroy(menu); return PLUGIN_HANDLED; }
    
    switch(item) {
        case 0: g_pEnabled[id] = !g_pEnabled[id]
        case 1: { g_pMode[id]++; if(g_pMode[id]>3) g_pMode[id]=0; }
        case 2: g_pScrollInfo[id] = !g_pScrollInfo[id]
        case 3: g_pFog[id] = !g_pFog[id]
        case 4: { g_pSpeed[id]++; if(g_pSpeed[id]>2) g_pSpeed[id]=0; }
        case 5: g_pShowStats[id] = !g_pShowStats[id]
        case 6: { menu_more(id); menu_destroy(menu); return PLUGIN_HANDLED; }
    }
    save_data(id); menu_destroy(menu); menu_fru(id); return PLUGIN_HANDLED
}

public menu_more(id) {
    new menu = menu_create("\yFrupre Settings [2/2]", "handler_more"), tmp[64]
    
    menu_additem(menu, "HUD Height (+)")
    menu_additem(menu, "HUD Height (-)")
    formatex(tmp, 63, "Scrollinfo Gap: \y%.3f (+)", float(g_pGap[id]) / 1000.0); menu_additem(menu, tmp)
    formatex(tmp, 63, "Scrollinfo Gap: \y%.3f (-)", float(g_pGap[id]) / 1000.0); menu_additem(menu, tmp)
    formatex(tmp, 63, "Speed Type: \y%s", g_pSType[id] == 1 ? "XY, Horizontal" : "XYZ"); menu_additem(menu, tmp)
    formatex(tmp, 63, "HUD: \y%s", g_pHud[id] == 1 ? "Center" : "RGB"); menu_additem(menu, tmp)
    formatex(tmp, 63, "Colors: %s", g_pColor[id] ? "\yOn" : "\rOff"); menu_additem(menu, tmp)
    menu_additem(menu, "\wBack to Page 1")

    menu_setprop(menu, MPROP_EXIT, MEXIT_ALL)
    menu_setprop(menu, MPROP_EXITNAME, "Close")
    
    menu_display(id, menu)
}

public handler_more(id, menu, item) {
    if (item == MENU_EXIT) { menu_destroy(menu); return PLUGIN_HANDLED; }

    switch(item) {
        case 0: { if(g_pHeight[id]<20) g_pHeight[id]++; }
        case 1: { if(g_pHeight[id]>0) g_pHeight[id]--; }
        case 2: { g_pGap[id]++; }
        case 3: { if(g_pGap[id]>0) g_pGap[id]--; }
        case 4: g_pSType[id] = (g_pSType[id] == 1 ? 2 : 1)
        case 5: g_pHud[id] = (g_pHud[id] == 1 ? 2 : 1)
        case 6: g_pColor[id] = !g_pColor[id]
        case 7: { menu_fru(id); menu_destroy(menu); return PLUGIN_HANDLED; }
    }
    save_data(id); menu_destroy(menu); menu_more(id); return PLUGIN_HANDLED
}

public save_data(id) {
    new szFile[128], szAuth[32], szLine[128]
    format(szFile, 127, "frupre_save.txt")
    get_user_authid(id, szAuth, 31)
    if (file_exists(szFile)) delete_file(szFile)
    write_file(szFile, "// Frupre Pro Ultimate Configuration")
    formatex(szLine, 127, "ID ^"%s^"", szAuth); write_file(szFile, szLine)
    formatex(szLine, 127, "Mode %d", g_pMode[id]); write_file(szFile, szLine)
    formatex(szLine, 127, "Fog %d", g_pFog[id]); write_file(szFile, szLine)
    formatex(szLine, 127, "Speed %d", g_pSpeed[id]); write_file(szFile, szLine)
    formatex(szLine, 127, "SType %d", g_pSType[id]); write_file(szFile, szLine)
    formatex(szLine, 127, "Height %d", g_pHeight[id]); write_file(szFile, szLine)
    formatex(szLine, 127, "Color %d", g_pColor[id]); write_file(szFile, szLine)
    formatex(szLine, 127, "Hud %d", g_pHud[id]); write_file(szFile, szLine)
    formatex(szLine, 127, "Plugin %d", g_pEnabled[id]); write_file(szFile, szLine)
    formatex(szLine, 127, "ScrollInfo %d", g_pScrollInfo[id]); write_file(szFile, szLine)
    formatex(szLine, 127, "ShowStats %d", g_pShowStats[id]); write_file(szFile, szLine)
    formatex(szLine, 127, "Gap %d", g_pGap[id]); write_file(szFile, szLine)
}

public load_data(id) {
    new szFile[128], szData[256], szTag[32], szVal[64], szCurrentAuth[32], bool:bIsMe = false
    format(szFile, 127, "frupre_save.txt")
    get_user_authid(id, szCurrentAuth, 31)
    if (!file_exists(szFile)) return
    new iFile = fopen(szFile, "rt")
    if (iFile) {
        while (!feof(iFile)) {
            fgets(iFile, szData, 255); trim(szData)
            if (!szData[0] || szData[0] == '/') continue
            parse(szData, szTag, 31, szVal, 63)
            if (equal(szTag, "ID")) { if (equal(szVal, szCurrentAuth) || equal(szVal, "STEAM_ID_LAN") || equal(szVal, "VALVE_ID_LAN")) bIsMe = true; }
            if (bIsMe) {
                if (equal(szTag, "Mode")) g_pMode[id] = str_to_num(szVal)
                else if (equal(szTag, "Fog")) g_pFog[id] = str_to_num(szVal)
                else if (equal(szTag, "Speed")) g_pSpeed[id] = str_to_num(szVal)
                else if (equal(szTag, "SType")) g_pSType[id] = str_to_num(szVal)
                else if (equal(szTag, "Height")) g_pHeight[id] = str_to_num(szVal)
                else if (equal(szTag, "Color")) g_pColor[id] = str_to_num(szVal)
                else if (equal(szTag, "Hud")) g_pHud[id] = str_to_num(szVal)
                else if (equal(szTag, "Plugin")) g_pEnabled[id] = str_to_num(szVal)
                else if (equal(szTag, "ScrollInfo")) g_pScrollInfo[id] = str_to_num(szVal)
                else if (equal(szTag, "ShowStats")) g_pShowStats[id] = str_to_num(szVal)
                else if (equal(szTag, "Gap")) g_pGap[id] = str_to_num(szVal)
            }
        }
        fclose(iFile)
    }
}
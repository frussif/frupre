#include <amxmodx>
#include <fakemeta>

new g_pMode[33], g_pFog[33], g_pSpeed[33], g_pSType[33], g_pHeight[33], g_pColor[33], g_pHud[33], g_pEnabled[33], g_pScrollInfo[33]
new g_jCount[33], g_jFire[33], g_jFinalFOG[33], g_dCount[33], g_dFire[33], g_dFinalFOG[33]
new g_jFOG[33], g_dFOG[33], bool:g_onGround[33], Float:g_lastScrollTime[33], g_lastType[33], g_staticSpeed[33]

public plugin_init() {
	register_plugin("Frupre Pro Ultimate", "11.2", "Legacy-Fix")
	register_forward(FM_PlayerPreThink, "fwd_PlayerPreThink")
	register_clcmd("say /frupre", "menu_fru")
	register_clcmd("say /load", "load_data")
}

public client_putinserver(id) {
	g_pEnabled[id]=1; g_pMode[id]=3; g_pFog[id]=1; g_pSpeed[id]=1; 
	g_pSType[id]=1; g_pHeight[id]=12; g_pColor[id]=1; g_pHud[id]=2; g_pScrollInfo[id]=1;
	set_task(2.0, "load_data", id)
}

public fwd_PlayerPreThink(id) {
	if (!is_user_alive(id) || !g_pEnabled[id]) return
	static buttons, oldbuttons, flags; buttons = pev(id, pev_button); oldbuttons = pev(id, pev_oldbuttons); flags = pev(id, pev_flags)
	new Float:fTime = get_gametime()

	if (flags & FL_ONGROUND) {
		if (!g_onGround[id]) { g_onGround[id] = true; g_jFOG[id] = 0; g_dFOG[id] = 0; }
		g_jFOG[id]++; g_dFOG[id]++
	} else g_onGround[id] = false

	if ((buttons & IN_DUCK) && !(oldbuttons & IN_DUCK) && (g_pMode[id] == 2 || g_pMode[id] == 3)) {
		if (fTime - g_lastScrollTime[id] > 0.05) { g_dCount[id] = 0; g_dFire[id] = 0; }
		g_dCount[id]++
		if (g_dCount[id] >= 2) { if (g_lastType[id] == 1) { g_jCount[id] = 0; g_jFire[id] = 0; } g_lastType[id] = 2; }
		if (!(flags & FL_DUCKING) && g_dFire[id] == 0 && (flags & FL_ONGROUND)) { 
			g_dFire[id] = g_dCount[id]; g_dFinalFOG[id] = g_dFOG[id]; g_staticSpeed[id] = calculate_speed(id); 
		}
		g_lastScrollTime[id] = fTime
	}
	if ((buttons & IN_JUMP) && !(oldbuttons & IN_JUMP) && (g_pMode[id] == 1 || g_pMode[id] == 3)) {
		if (fTime - g_lastScrollTime[id] > 0.05) { g_jCount[id] = 0; g_jFire[id] = 0; }
		g_jCount[id]++
		if (g_jCount[id] >= 2) { if (g_lastType[id] == 2) { g_dCount[id] = 0; g_dFire[id] = 0; } g_lastType[id] = 1; }
		if ((flags & FL_ONGROUND) && g_jFire[id] == 0) { 
			g_jFire[id] = g_jCount[id]; g_jFinalFOG[id] = g_jFOG[id]; g_staticSpeed[id] = calculate_speed(id); 
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
	new curFog = (g_lastType[id] == 1) ? g_jFinalFOG[id] : g_dFinalFOG[id], curStep = (g_lastType[id] == 1) ? g_jFire[id] : g_dFire[id]
	new curCount = (g_lastType[id] == 1) ? g_jCount[id] : g_dCount[id]
	if (g_pHud[id] == 1) {
		static szMain[192], szStats[64], szFog[32], szSpeed[32], szPad[64]; szStats[0] = 0; szFog[0] = 0; szSpeed[0] = 0; szPad[0] = 0
		for(new i = 0; i < clamp(g_pHeight[id], 0, 20); i++) add(szPad, 63, "^n")
		if (showStats && curFog <= 20) {
			if (g_pScrollInfo[id] && curCount >= 2) formatex(szStats, 63, "%c: %d [%d]", (g_lastType[id] == 1) ? 'J' : 'D', curCount, curStep)
			if (fogOn) formatex(szFog, 31, "%sFOG: %d", szStats[0] ? "^n" : "", curFog)
		}
		if (g_pSpeed[id] == 1) formatex(szSpeed, 31, "^n%d", calculate_speed(id))
		else if (g_pSpeed[id] == 2 && showStats) formatex(szSpeed, 31, "^n%d", g_staticSpeed[id])
		if (szStats[0] || szFog[0] || szSpeed[0]) { formatex(szMain, 191, "%s%s%s%s", szPad, szStats, szFog, szSpeed); client_print(id, print_center, szMain); }
	} else {
		new Float:startY = 0.35 + (float(g_pHeight[id]) * 0.025), Float:gap = 0.012
		static szLine1[64], szLine2[128]; szLine1[0] = 0; szLine2[0] = 0
		if (showStats && curFog <= 20) {
			new r = 255, g = 255, b = 255
			if (colorsOn) { if (curStep <= 2) { r = 0; g = 255; b = 0; } else if (curStep <= 4) { r = 255; g = 150; b = 0; } else { r = 255; g = 0; b = 0; } }
			if (g_pScrollInfo[id] && curCount >= 2) {
				formatex(szLine1, 63, "%c: %d [%d]", (g_lastType[id] == 1) ? 'J' : 'D', curCount, curStep)
				set_hudmessage(r, g, b, -1.0, fogOn ? startY : (startY + gap), 0, 0.0, 0.1, 0.0, 0.0, 3); show_hudmessage(id, szLine1);
			}
		}
		new rF = 255, gF = 255, bF = 100 
		if (showStats && curFog <= 20 && fogOn) {
			if (colorsOn) { if (curFog <= 2) { rF = 0; gF = 255; bF = 0; } else if (curFog == 3) { rF = 255; gF = 150; bF = 0; } else { rF = 255; gF = 0; bF = 0; } }
			formatex(szLine2, 127, "FOG: %d", curFog)
		}
		if (g_pSpeed[id] > 0) {
			static szSpeed[64]; szSpeed[0] = 0
			if (g_pSpeed[id] == 1) formatex(szSpeed, 63, "%d", calculate_speed(id))
			else if (showStats) formatex(szSpeed, 63, "%d", g_staticSpeed[id])
			if (szSpeed[0]) { if (szLine2[0]) add(szLine2, 127, "^n"); add(szLine2, 127, szSpeed); }
		}
		if (szLine2[0]) { set_hudmessage(rF, gF, bF, -1.0, startY + gap, 0, 0.0, 0.1, 0.0, 0.0, 4); show_hudmessage(id, szLine2); }
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
	menu_additem(menu, "\wNext Page"); menu_additem(menu, "\gSave")
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
		case 5: { menu_more(id); menu_destroy(menu); return PLUGIN_HANDLED; }
		case 6: { save_data(id); client_print(id, print_chat, "[Frupre] Saved."); }
	}
	save_data(id); menu_fru(id); return PLUGIN_HANDLED
}

public menu_more(id) {
	new menu = menu_create("\yFrupre Settings [2/2]", "handler_more")
	menu_additem(menu, "Height (+)"); menu_additem(menu, "Height (-)")
	menu_additem(menu, g_pSType[id] == 1 ? "Type: \yXY" : "Type: \yXYZ")
	menu_additem(menu, g_pHud[id] == 1 ? "HUD: \yCenter" : "HUD: \yRGB")
	menu_additem(menu, g_pColor[id] ? "Colors: \yOn" : "Colors: \rOff")
	menu_additem(menu, "\wBack"); menu_additem(menu, "\gSave")
	menu_display(id, menu)
}

public handler_more(id, menu, item) {
	if (item == MENU_EXIT) { menu_destroy(menu); return PLUGIN_HANDLED; }
	switch(item) {
		case 0: { if(g_pHeight[id]<20) g_pHeight[id]++; }
		case 1: { if(g_pHeight[id]>0) g_pHeight[id]--; }
		case 2: g_pSType[id] = (g_pSType[id] == 1 ? 2 : 1)
		case 3: g_pHud[id] = (g_pHud[id] == 1 ? 2 : 1)
		case 4: g_pColor[id] = !g_pColor[id]
		case 5: { menu_fru(id); menu_destroy(menu); return PLUGIN_HANDLED; }
		case 6: { save_data(id); client_print(id, print_chat, "[Frupre] Saved."); }
	}
	save_data(id); menu_more(id); return PLUGIN_HANDLED
}

public save_data(id) {
	new szFile[128], szName[32], szAuth[32]
	format(szFile, 127, "frupre_save.txt")
	get_user_name(id, szName, 31)
	get_user_authid(id, szAuth, 31)

	// Delete old file to rewrite clean vertical list
	if (file_exists(szFile)) delete_file(szFile)

	write_file(szFile, "// Frupre Pro Ultimate - User Configuration")
	write_file(szFile, "// ----------------------------------------")
	
	new szLine[128]
	formatex(szLine, 127, "User: %s", szName); write_file(szFile, szLine)
	formatex(szLine, 127, "ID: %s", szAuth); write_file(szFile, szLine)
	write_file(szFile, "") // Blank line for readability

	write_file(szFile, "// 0=Off, 1=Jump, 2=Duck, 3=Both")
	formatex(szLine, 127, "Mode %d", g_pMode[id]); write_file(szFile, szLine)

	write_file(szFile, "// 0=Off, 1=On")
	formatex(szLine, 127, "Fog %d", g_pFog[id]); write_file(szFile, szLine)

	write_file(szFile, "// 0=Off, 1=Live, 2=Static")
	formatex(szLine, 127, "Speed %d", g_pSpeed[id]); write_file(szFile, szLine)

	write_file(szFile, "// 1=XY, 2=XYZ")
	formatex(szLine, 127, "SType %d", g_pSType[id]); write_file(szFile, szLine)

	write_file(szFile, "// 0 to 20 (Higher = Higher on screen)")
	formatex(szLine, 127, "Height %d", g_pHeight[id]); write_file(szFile, szLine)

	write_file(szFile, "// 0=Off, 1=On")
	formatex(szLine, 127, "Color %d", g_pColor[id]); write_file(szFile, szLine)

	write_file(szFile, "// 1=Center, 2=RGB HUD")
	formatex(szLine, 127, "Hud %d", g_pHud[id]); write_file(szFile, szLine)

	write_file(szFile, "// 0=Disabled, 1=Enabled")
	formatex(szLine, 127, "Plugin %d", g_pEnabled[id]); write_file(szFile, szLine)

	write_file(szFile, "// 0=Off, 1=On")
	formatex(szLine, 127, "ScrollInfo %d", g_pScrollInfo[id]); write_file(szFile, szLine)
}

public load_data(id) {
	new szFile[128], szData[256], szTag[32], szVal[32], szSavedAuth[32], szCurrentAuth[32]
	format(szFile, 127, "frupre_save.txt")
	get_user_authid(id, szCurrentAuth, 31)

	if (!file_exists(szFile)) return

	new iFile = fopen(szFile, "rt")
	if (iFile) {
		while (!feof(iFile)) {
			fgets(iFile, szData, 255)
			trim(szData)
			if (!szData[0] || szData[0] == '/') continue

			parse(szData, szTag, 31, szVal, 31)

			if (equal(szTag, "ID")) copy(szSavedAuth, 31, szVal)
			
			// Only load if the ID in the file matches you
			if (equal(szCurrentAuth, szSavedAuth) || equal(szSavedAuth, "STEAM_ID_LAN")) {
				if (equal(szTag, "Mode")) g_pMode[id] = str_to_num(szVal)
				else if (equal(szTag, "Fog")) g_pFog[id] = str_to_num(szVal)
				else if (equal(szTag, "Speed")) g_pSpeed[id] = str_to_num(szVal)
				else if (equal(szTag, "SType")) g_pSType[id] = str_to_num(szVal)
				else if (equal(szTag, "Height")) g_pHeight[id] = str_to_num(szVal)
				else if (equal(szTag, "Color")) g_pColor[id] = str_to_num(szVal)
				else if (equal(szTag, "Hud")) g_pHud[id] = str_to_num(szVal)
				else if (equal(szTag, "Plugin")) g_pEnabled[id] = str_to_num(szVal)
				else if (equal(szTag, "ScrollInfo")) g_pScrollInfo[id] = str_to_num(szVal)
			}
		}
		fclose(iFile)
	}
}
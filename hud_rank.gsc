precache()
{
	game["hud_rank"] = &"Rank:";
	precacheString(game["hud_rank"]);
	
	game["hud_rank_slash"] = &"/";
	precacheString(game["hud_rank_slash"]);
	
	game["hud_rank_promoted"] = &"You've been promoted!";
	precacheString(game["hud_rank_promoted"]);

	precacheShader("gfx/hud/hud@health_bar.tga");
}

onPlayerConnect()
{
	player = self;
	
	if (!isDefined(player.huds))
		player.huds = [];
	
	hud_rank_element = newClientHudElem(player);
	hud_rank_element.horzAlign = "fullscreen";
	hud_rank_element.vertAlign = "fullscreen";
	hud_rank_element.alignX = "right";
	hud_rank_element.alignY = "top";
	hud_rank_element.x = 320+0;
	hud_rank_element.y = 25;
	hud_rank_element.alpha = 1;
	//hud_rank_element.fontscale = 0.8;
	hud_rank_element.color = (0.8,0.8,0.8);
	hud_rank_element.label = game["hud_rank"];
	
	hud_rank_value = newClientHudElem(player);
	hud_rank_value.horzAlign = "fullscreen";
	hud_rank_value.vertAlign = "fullscreen";
	hud_rank_value.alignX = "left";
	hud_rank_value.alignY = "top";
	hud_rank_value.x = 320 + 5 + 0;
	hud_rank_value.y = 25;
	hud_rank_value.alpha = 1;
	hud_rank_value.fontscale = 1;
	hud_rank_value.color = (1,1,0);
	//hud_rank_value setValue(0);	
	
	
	hud_xp_left = newClientHudElem(player);
	hud_xp_left.horzAlign = "fullscreen";
	hud_xp_left.vertAlign = "fullscreen";
	hud_xp_left.alignX = "right";
	hud_xp_left.alignY = "top";
	hud_xp_left.x = 320-5;
	hud_xp_left.y = 10;
	hud_xp_left.alpha = 1;
	hud_xp_left.fontscale = 1;
	hud_xp_left.color = (1,1,0);
	hud_xp_left setValue(12345);
	
	hud_xp_right = newClientHudElem(player);
	hud_xp_right.horzAlign = "fullscreen";
	hud_xp_right.vertAlign = "fullscreen";
	hud_xp_right.alignX = "left";
	hud_xp_right.alignY = "top";
	hud_xp_right.x = 320+5;
	hud_xp_right.y = 10;
	hud_xp_right.alpha = 1;
	hud_xp_right.fontscale = 1;
	hud_xp_right.color = (1,1,0);
	hud_xp_right setValue(12345);
	
	hud_xp_center = newClientHudElem(player);
	hud_xp_center.horzAlign = "fullscreen";
	hud_xp_center.vertAlign = "fullscreen";
	hud_xp_center.alignX = "left";
	hud_xp_center.alignY = "top";
	hud_xp_center.x = 320-2;
	hud_xp_center.y = 10;
	hud_xp_center.alpha = 1;
	hud_xp_center.fontscale = 1;
	hud_xp_center.color = (0.8,0.8,0.8);
	hud_xp_center.label = game["hud_rank_slash"];
	
	
	hud_xp_shader_front = newClientHudElem(player);
	hud_xp_shader_front.archived = true;
	hud_xp_shader_front.horzAlign = "fullscreen";
	hud_xp_shader_front.vertAlign = "fullscreen";
	hud_xp_shader_front.alignX = "left";
	hud_xp_shader_front.alignY = "top";
	hud_xp_shader_front.x = 0;
	hud_xp_shader_front.y = 480-7;
	hud_xp_shader_front.color = ( 1, 1, 0);
	hud_xp_shader_front.sort = 1;
	//hud_xp_shader_front setShader("gfx/hud/hud@health_bar.tga", 640, 8);
	
	hud_xp_shader_back = newClientHudElem(player);
	hud_xp_shader_back.archived = true;
	hud_xp_shader_back.horzAlign = "fullscreen";
	hud_xp_shader_back.vertAlign = "fullscreen";
	hud_xp_shader_back.alignX = "left";
	hud_xp_shader_back.alignY = "top";
	hud_xp_shader_back.x = 0;
	hud_xp_shader_back.y = 480-8;
	hud_xp_shader_back.color = ( 0, 0, 0);
	hud_xp_shader_back.alpha = 0.6;
	hud_xp_shader_back.sort = 0;
	hud_xp_shader_back setShader("gfx/hud/hud@health_bar.tga", 640, 6);
	
	
	player.huds["rank_element"] = hud_rank_element;
	player.huds["rank_value"] = hud_rank_value;
	
	player.huds["xp_shader_front"] = hud_xp_shader_front;
	player.huds["xp_shader_back"] = hud_xp_shader_back;
	
	player.huds["xp_left"] = hud_xp_left;
	player.huds["xp_right"] = hud_xp_right;
	player.huds["xp_center"] = hud_xp_center;
	
}

xp2rank(xp)
{
	/*
	if (xp >= 10) return 2;
	if (xp >= 20) return 3;
	if (xp >= 20) return 3;
	*/
	
	rank = 0;
	neededXP = 0;
	overXP = 0;
	
	for (i=2; i<=500; i++)
	{
		neededXP = i*i*10;
		if (xp < neededXP)
			break;
		overXP = neededXP;
		rank++;
	}
	
	rankData = spawnstruct();
	rankData.rank = rank;
	rankData.neededXP = neededXP;
	rankData.overXP = overXP;
	rankData.currentXP = xp;
	
	xp -= overXP;
	neededXP -= overXP;
	onePercent = neededXP / 100;
	howOftenFitsOnePercent = xp / onePercent;
	rankData.scale = howOftenFitsOnePercent / 100;
	
	
	rankData.rankXP = xp;
	rankData.rankXPneeded = neededXP;
	
	return rankData;
}



showPromotionText()
{
	player = self;
	
	hud = newClientHudElem(player);
	hud.horzAlign = "fullscreen";
	hud.vertAlign = "fullscreen";
	hud.alignX = "center";
	hud.alignY = "top";
	hud.x = 320;
	hud.y = 50;
	hud.alpha = 1;
	hud.fontscale = 2;
	hud.color = (0.8,0.8,0.8);
	hud.label = game["hud_rank_promoted"];
	
	wait 5;
	
	hud fadeOverTime(1);
	hud.alpha = 0;
	wait 1;
	
	hud destroy();
}

eventUpdate(name, value)
{
	player = self;

	xp = player.stats["xp"];
	rankData = xp2rank(xp);
	
	//std\io::print("neededXP=" + rankData.neededXP + " overXP=" + rankData.overXP + " scale="+rankData.scale+"\n");
	
	
	if (!isDefined(player.oldRank))
	{
		player.oldRank = rankData.rank;
		player.huds["rank_value"] setValue(rankData.rank); // init, else its empty
	}
		
	if (player.oldRank != rankData.rank)
	{
		//iprintln("NEW RANK!!");
		player playLocalSound("rank_up");
		//player playSound("MP_bomb_plant");
		player thread showPromotionText();
		player.huds["rank_value"] setValue(rankData.rank);
		
	}
	player.oldRank = rankData.rank;
	
	
	if (rankData.scale < 0.001)
		size = 1;
	else
		size = int(640 * rankData.scale);

	player.huds["xp_shader_front"] setShader("gfx/hud/hud@health_bar.tga", size, 4);
	
	
	player.huds["xp_left"] setValue(rankData.rankXP);
	player.huds["xp_right"] setValue(rankData.rankXPneeded);
	
	return true; // continue with events
}

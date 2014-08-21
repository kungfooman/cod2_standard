

addMap(name, loadscreen, hudstring, nicename)
{
	if ( ! isDefined(level.maps))
		level.maps = [];
	i = level.maps.size;
	level.maps[i] = spawnstruct();
	level.maps[i].name = name;
	level.maps[i].loadscreen = loadscreen;
	level.maps[i].hudstring = hudstring;
	level.maps[i].nicename = nicename;
}

getMaps()
{
	return level.maps;
}

precache()
{
	maps = getMaps();
	for (i=0; i<maps.size; i++)
	{
		precacheShader(maps[i].loadscreen);
		precacheString(maps[i].hudstring);
	}

	precacheShader("objpoint_star");

	precacheShader("white");

	level.noMap = &"-no map voted-";
	level.votedFor = &"Voted for:";
	level.justWinning = &"Just winning:";
	level.nextMap = &"^7Next Map: ^1[[{+attack}]]";
	level.prevMap = &"^7Previous Map: ^1[[{+melee}]]^7 or ^1[[{+melee_breath}]]";

	precacheShader("hudStopwatch");
	precacheShader("hudstopwatchneedle");

	level.testString2 = &"22";
	precacheString(level.noMap);
	precacheString(level.votedFor);
	precacheString(level.justWinning);
	precacheString(level.nextMap);
	precacheString(level.prevMap);

	precacheString(level.testString2);

	level.mapvote = spawnstruct();
	level.mapvote.maps = [];
	level.mapvote.timeleft = &"Time left: ^6";
	precacheString(level.mapvote.timeleft);
}

arrayAdd(array, element)
{
	array[array.size] = element;
	return array;
}

// return 1+2*eachSide indexes
circulateIndex(at, eachSide, maxNumber)
{
	indexes = [];

	while (at < 0)
		at += maxNumber;
	at %= maxNumber;

	// left side
	for (i=eachSide; i; i--) // 2, 1
	{
		tmp = at - i;
		if (tmp < 0)
			tmp = maxNumber + tmp;
		indexes = arrayAdd(indexes, tmp);
	}
	indexes = arrayAdd(indexes, at);
	// right side
	for (i=1; i<=eachSide; i++) // 1, 2
	{
		tmp = at + i;
		if (tmp >= maxNumber)
			tmp -= maxNumber;
		indexes = arrayAdd(indexes, tmp);
	}
	return indexes;
}

indexScale(i)
{
	// no scale, its somehow ugly
	if (1<2)
		return 1;

	switch (i)
	{
		case 0:
			return 0.5;
		case 1:
			return 0.7;
		case 2:
			return 0.9;
		case 3:
			return 1.2;
		case 4:
			return 0.9;
		case 5:
			return 0.7;
		case 6:
			return 0.5;
	}
	return 1;
}

mapVote(maps)
{
	level endon("voteend");
	player = self;

	player setClientCvar("ui_allow_joinallies", "0");
	player setClientCvar("ui_allow_joinaxis", "0");
	player setClientCvar("ui_allow_joinauto", "0");
	player setClientCvar("ui_allow_weaponchange", "0");

	//iprintln("maps=" + maps.size);
	atMap = 0;
	mapsEachSide = 3;

	// no default map, to prevent "afk"-votes of the first map
	player.clickId = -1;

	//level.noMap = &"-no map voted-";
	//level.votedFor = &"Voted for:";
	//level.justWinning = &"Just winning:";

	background = newClientHudElem(player);
	background.archived = false;
	background.horzAlign = "fullscreen";
	background.vertAlign = "fullscreen";
	background.alignX = "left";
	background.alignY = "top";
	background.alpha = 0.5;
	background.sort = 103;
	background.color = (0.05, 0.05, 0.05);
	background.x = 0;
	background.y = 280/*-40*/-70;
	background setShader("white", 640, 430-280+40);

	votedFor = newClientHudElem(player);
	votedFor.archived = false;
	votedFor.horzAlign = "fullscreen";
	votedFor.vertAlign = "fullscreen";
	votedFor.alignX = "left";
	votedFor.alignY = "top";
	votedFor.sort = 105;
	votedFor.color = (0.95, 0.05, 0.05);
	votedFor.x = 20+240;
	votedFor.y = 170+30+20;
	votedFor setText(level.votedFor);
	currentMap = newClientHudElem(player);
	currentMap.archived = false;
	currentMap.horzAlign = "fullscreen";
	currentMap.vertAlign = "fullscreen";
	currentMap.alignX = "left";
	currentMap.alignY = "top";
	currentMap.sort = 105;
	currentMap.color = (1, 1, 1);
	currentMap.x = 100+240;
	currentMap.y = 170+30+20;
	currentMap setText(level.noMap);

	prevMap = newClientHudElem(player);
	prevMap.archived = false;
	prevMap.horzAlign = "fullscreen";
	prevMap.vertAlign = "fullscreen";
	prevMap.alignX = "left";
	prevMap.alignY = "top";
	prevMap.sort = 105;
	prevMap.color = (1, 1, 1);
	prevMap.x = 10;
	prevMap.y = 225;
	prevMap setText(level.prevMap);

	nextMap = newClientHudElem(player);
	nextMap.archived = false;
	nextMap.horzAlign = "fullscreen";
	nextMap.vertAlign = "fullscreen";
	nextMap.alignX = "left";
	nextMap.alignY = "top";
	nextMap.sort = 105;
	nextMap.color = (1, 1, 1);
	nextMap.x = 640-120;
	nextMap.y = 225;
	nextMap setText(level.nextMap);



	indexes = circulateIndex(/*at=*/atMap, /*eachSide=*/mapsEachSide, /*maxNumber=*/maps.size);

	huds = [];
	for (i=0; i<indexes.size; i++)
	{
		huds[i] = newClientHudElem(player);
		huds[i].alpha = 0.20; // first maps arent showed
		huds[i].archived = false;
		huds[i].horzAlign = "fullscreen";
		huds[i].vertAlign = "fullscreen";
		huds[i].alignX = "left";
		huds[i].alignY = "top";
		huds[i].sort = 104;

		huds[i].color = (0.50, 0.50, 0.50);

			mapIndex = indexes[i];
			shader = maps[mapIndex].loadscreen;
			//huds[i] setShader("white", int(640/7), int(480/7));
			huds[i] setShader(shader, int((640/7)*indexScale(i)), int((480/7)*indexScale(i)));
			huds[i].x = absoluteX(i, indexes.size);
			huds[i].y = absoluteY(i);

		//huds[i] fadeOverTime(1); doesnt work with the loadscreens
	}



	while (isDefined(player))
	{
		direction = 0;
		if (player attackButtonPressed())
			direction = 1;
		if (player meleeButtonPressed())
			direction = -1;
		if (direction == 0)
		{
			wait 0.05;
			continue;
		}

		player playLocalSound("ctf_touchown");

		// should be abstracted somehow
		while (atMap < 0)
			atMap += maps.size;
		atMap %= maps.size;

		indexes = circulateIndex(/*at=*/atMap, /*eachSide=*/mapsEachSide, /*maxNumber=*/maps.size);

		output = "indexes (at="+ (atMap+direction) +"): ";
		for (i=0; i<indexes.size; i++)
			output += indexes[i] + " ";
		//iprintln(output);

		player.clickId = atMap+direction;

		if (player.clickId == -1)
			player.clickId = maps.size-1;
		if (player.clickId == maps.size)
			player.clickId = 0;
		
		//iprintln("clickId="+player.clickId);
		currentMap setText(maps[player.clickId].hudstring);

		// or prevent first moving with $firstTime...
		for (i=0; i<indexes.size; i++)
		{
			mapIndex = indexes[i];
			shader = maps[mapIndex].loadscreen;
			huds[i].color = (1, 1, 1); // make visible
			huds[i] setShader(shader, int((640/7)*indexScale(i)), int((480/7)*indexScale(i)));
			huds[i].x = absoluteX(i, indexes.size);
			huds[i].y = absoluteY(i);
			huds[i].alpha = 1;
			huds[i] moveOverTime(0.40);
			if (i-direction < 0 || i-direction > 6)
				continue;
			huds[i].x = absoluteX(i-direction, indexes.size);
			huds[i].y = absoluteY(i-direction);
			huds[i] scaleOverTime(0.40, int((640/7)*indexScale(i-direction)), int((480/7)*indexScale(i-direction)));
		}


		wait 0.50;

		atMap += direction;
	}
}

absoluteX(index, max)
{
	number = 0;
	// have to think about it...
	if (index <= -1)
		number = -1000;
	if (index >= 7)
		number = -1000;

	switch (index)
	{
		case 0:
			number = -106;
			break;
		case 1:
			number = 30;
			break;
		case 2:
			number = 155;
			break;
		case 3:
			number = 274;
			break;
		case 4:
			number = 395;
			break;
		case 5:
			number = 515;
			break;
		case 6:
			number = 655;
			break;
	}
	return number;
}
absoluteY(index)
{
	number = 0;
	// have to think about it...
	if (index <= -1)
		number = -1000;
	if (index >= 7)
		number = -1000;

	switch (index)
	{
		case 0:
			number = 270+15;
			break;
		case 1:
			number = 295;
			break;
		case 2:
			number = 323;
			break;
		case 3:
			number = 345;
			break;
		case 4:
			number = 324;
			break;
		case 5:
			number = 296;
			break;
		case 6:
			number = 271+15;
			break;
	}
	return number - 40;
}

getWinningMap(players, maps)
{
	votesForId = [];

	for (i=0; i<maps.size; i++)
		votesForId[i] = 0;

	for (i=0; i<players.size; i++)
	{
		player = players[i];

		if (!isDefined(player))
			continue;

		if (!isDefined(player.clickId))
			continue;

		if (player.clickId == -1)
			continue;

		votesForId[player.clickId]++;
	}

	// search the map-id with the most votes
	votesMost = 0; // the map id 0 is winning by default
	for (i=1; i<votesForId.size; i++) // search id better then default
		if (votesForId[i] > votesForId[votesMost])
			votesMost = i;

	output = "votesMost="+votesMost + " votes=";
	for (i=0; i<votesForId.size; i++)
		output += votesForId[i] + ",";
	//iprintln(output);

	return maps[votesMost];
}

printWinningMap(players, maps)
{
	justWinning = newHudElem();
	justWinning.archived = false;
	justWinning.horzAlign = "fullscreen";
	justWinning.vertAlign = "fullscreen";
	justWinning.alignX = "left";
	justWinning.alignY = "top";
	justWinning.sort = 105;
	justWinning.color = (0.95, 0.05, 0.05);
	justWinning.x = 240+20;
	justWinning.y = 170+20+30+20;
	justWinning setText(level.justWinning);
	winningMap = newHudElem();
	winningMap.archived = false;
	winningMap.horzAlign = "fullscreen";
	winningMap.vertAlign = "fullscreen";
	winningMap.alignX = "left";
	winningMap.alignY = "top";
	winningMap.sort = 105;
	winningMap.color = (1, 1, 1);
	winningMap.x = 240+100;
	winningMap.y = 170+20+30+20;
	winningMap setText(level.noMap);

	while (1)
	{
		map = getWinningMap(players, maps);
		winningMap setText(map.hudstring);
		wait 0.25;
	}
}

run()
{
	game["state"] = "mapvote";


	std\sound::playSoundOnPlayers("ctf_touchcapture");

	maps = getMaps();

	players = getentarray("player", "classname");
	for (i=0; i<players.size; i++)
	{
		player = players[i];
		player thread mapVote(maps);
	}

	thread printWinningMap(players, maps);

	level.clock destroy();

	clock = newHudElem();
	clock.x = 640-70;
	clock.y = 100;
	clock.horzAlign = "left";
	clock.vertAlign = "top";
	clock setClock(30, 30, "hudStopwatch", 48+12, 48+12);


	wait 30;
	//level waittill("jezz");

	level notify("voteend");

	map = getWinningMap(players, maps);

	iprintlnbold("^1[^7"+map.nicename+"^1] ^7wins^1!");
	iprintln("^1[^7NOTICE^1] ^7switching map to " + map.name);
	std\sound::playSoundOnPlayers("ctf_touchcapture");

	gametype = getcvar("g_gametype");
	tmp = "gametype "+gametype+" map "+map.name;
	setcvar("sv_mapRotation", tmp);
	setcvar("sv_mapRotationCurrent", tmp); // dunno if its needed, but its in brax, so overwrite it

	wait 5;

	return map.name;
}

run2()
{
	// watch melee = alpha

	/*players = getentarray("player", "classname");
	for (i=0; i<players.size; i++)
	{
		player = players[i];
		player closeMenu(); // ???
		player closeInGameMenu(); // ???
		player maps\mp\gametypes\zom::menuSpectator();
	}*/

	marginX = 10;
	marginY = 13;

	row = 0;
	col = 0;
	level.mapvote.maps[row][col] = newHudElem();	
	level.mapvote.maps[row][col].archived = false;
	level.mapvote.maps[row][col].horzAlign = "fullscreen";
	level.mapvote.maps[row][col].vertAlign = "fullscreen";
	level.mapvote.maps[row][col].alignX = "left";
	level.mapvote.maps[row][col].alignY = "top";
	level.mapvote.maps[row][col].x = 0 + marginX;
	level.mapvote.maps[row][col].y = 0 + marginY;
	level.mapvote.maps[row][col].alpha = 1;
	level.mapvote.maps[row][col] setShader("loadscreen_mp_carentan", 160-2*marginX, 120-2*marginY);
	col = 1;
	level.mapvote.maps[row][col] = newHudElem();	
	level.mapvote.maps[row][col].archived = false;
	level.mapvote.maps[row][col].horzAlign = "fullscreen";
	level.mapvote.maps[row][col].vertAlign = "fullscreen";
	level.mapvote.maps[row][col].alignX = "left";
	level.mapvote.maps[row][col].alignY = "top";
	level.mapvote.maps[row][col].x = 160 + marginX;
	level.mapvote.maps[row][col].y = 0 + marginY;
	level.mapvote.maps[row][col].alpha = 1;
	level.mapvote.maps[row][col] setShader("loadscreen_mp_burgundy", 160-2*marginX, 120-2*marginY);
	col = 2;
	level.mapvote.maps[row][col] = newHudElem();	
	level.mapvote.maps[row][col].archived = false;
	level.mapvote.maps[row][col].horzAlign = "fullscreen";
	level.mapvote.maps[row][col].vertAlign = "fullscreen";
	level.mapvote.maps[row][col].alignX = "left";
	level.mapvote.maps[row][col].alignY = "top";
	level.mapvote.maps[row][col].x = 320 + marginX;
	level.mapvote.maps[row][col].y = 0 + marginY;
	level.mapvote.maps[row][col].alpha = 1;
	level.mapvote.maps[row][col] setShader("loadscreen_mp_toujane", 160-2*marginX, 120-2*marginY);
	col = 3;
	level.mapvote.maps[row][col] = newHudElem();	
	level.mapvote.maps[row][col].archived = false;
	level.mapvote.maps[row][col].horzAlign = "fullscreen";
	level.mapvote.maps[row][col].vertAlign = "fullscreen";
	level.mapvote.maps[row][col].alignX = "left";
	level.mapvote.maps[row][col].alignY = "top";
	level.mapvote.maps[row][col].x = 480 + marginX;
	level.mapvote.maps[row][col].y = 0 + marginY;
	level.mapvote.maps[row][col].alpha = 1;
	level.mapvote.maps[row][col] setShader("loadscreen_mp_farmhouse", 160-2*marginX, 120-2*marginY);

	row = 1;
	col = 0; // free for chat
	col = 1;
	level.mapvote.maps[row][col] = newHudElem();	
	level.mapvote.maps[row][col].archived = false;
	level.mapvote.maps[row][col].horzAlign = "fullscreen";
	level.mapvote.maps[row][col].vertAlign = "fullscreen";
	level.mapvote.maps[row][col].alignX = "left";
	level.mapvote.maps[row][col].alignY = "top";
	level.mapvote.maps[row][col].x = 160 + marginX;
	level.mapvote.maps[row][col].y = 120 + marginY;
	level.mapvote.maps[row][col].alpha = 1;
	level.mapvote.maps[row][col] setShader("loadscreen_mp_railyard", 160-2*marginX, 120-2*marginY);
	col = 2;
	level.mapvote.maps[row][col] = newHudElem();	
	level.mapvote.maps[row][col].archived = false;
	level.mapvote.maps[row][col].horzAlign = "fullscreen";
	level.mapvote.maps[row][col].vertAlign = "fullscreen";
	level.mapvote.maps[row][col].alignX = "left";
	level.mapvote.maps[row][col].alignY = "top";
	level.mapvote.maps[row][col].x = 320 + marginX;
	level.mapvote.maps[row][col].y = 120 + marginY;
	level.mapvote.maps[row][col].alpha = 1;
	level.mapvote.maps[row][col] setShader("loadscreen_mp_harbor", 160-2*marginX, 120-2*marginY);
	col = 3;
	level.mapvote.maps[row][col] = newHudElem();	
	level.mapvote.maps[row][col].archived = false;
	level.mapvote.maps[row][col].horzAlign = "fullscreen";
	level.mapvote.maps[row][col].vertAlign = "fullscreen";
	level.mapvote.maps[row][col].alignX = "left";
	level.mapvote.maps[row][col].alignY = "top";
	level.mapvote.maps[row][col].x = 480 + marginX;
	level.mapvote.maps[row][col].y = 120 + marginY;
	level.mapvote.maps[row][col].alpha = 1;
	level.mapvote.maps[row][col] setShader("loadscreen_mp_dawnville", 160-2*marginX, 120-2*marginY);

	row = 2;
	col = 0;
	level.mapvote.maps[row][col] = newHudElem();	
	level.mapvote.maps[row][col].archived = false;
	level.mapvote.maps[row][col].horzAlign = "fullscreen";
	level.mapvote.maps[row][col].vertAlign = "fullscreen";
	level.mapvote.maps[row][col].alignX = "left";
	level.mapvote.maps[row][col].alignY = "top";
	level.mapvote.maps[row][col].x = 0 + marginX;
	level.mapvote.maps[row][col].y = 240 + marginY;
	level.mapvote.maps[row][col].alpha = 1;
	level.mapvote.maps[row][col] setShader("loadscreen_mp_rhine", 160-2*marginX, 120-2*marginY);
	col = 1;
	level.mapvote.maps[row][col] = newHudElem();	
	level.mapvote.maps[row][col].archived = false;
	level.mapvote.maps[row][col].horzAlign = "fullscreen";
	level.mapvote.maps[row][col].vertAlign = "fullscreen";
	level.mapvote.maps[row][col].alignX = "left";
	level.mapvote.maps[row][col].alignY = "top";
	level.mapvote.maps[row][col].x = 160 + marginX;
	level.mapvote.maps[row][col].y = 240 + marginY;
	level.mapvote.maps[row][col].alpha = 1;
	level.mapvote.maps[row][col] setShader("loadscreen_mp_trainstation", 160-2*marginX, 120-2*marginY);
	col = 2;
	level.mapvote.maps[row][col] = newHudElem();	
	level.mapvote.maps[row][col].archived = false;
	level.mapvote.maps[row][col].horzAlign = "fullscreen";
	level.mapvote.maps[row][col].vertAlign = "fullscreen";
	level.mapvote.maps[row][col].alignX = "left";
	level.mapvote.maps[row][col].alignY = "top";
	level.mapvote.maps[row][col].x = 320 + marginX; // old: 0
	level.mapvote.maps[row][col].y = 240 + marginY; // old: 120
	level.mapvote.maps[row][col].alpha = 1;
	level.mapvote.maps[row][col] setShader("loadscreen_mp_downtown", 160-2*marginX, 120-2*marginY);
	col = 3;
	level.mapvote.maps[row][col] = newHudElem();	
	level.mapvote.maps[row][col].archived = false;
	level.mapvote.maps[row][col].horzAlign = "fullscreen";
	level.mapvote.maps[row][col].vertAlign = "fullscreen";
	level.mapvote.maps[row][col].alignX = "left";
	level.mapvote.maps[row][col].alignY = "top";
	level.mapvote.maps[row][col].x = 480 + marginX;
	level.mapvote.maps[row][col].y = 240 + marginY;
	level.mapvote.maps[row][col].alpha = 1;
	level.mapvote.maps[row][col] setShader("loadscreen_mp_leningrad", 160-2*marginX, 120-2*marginY);

	row = 3;
	col = 0;
	level.mapvote.maps[row][col] = newHudElem();	
	level.mapvote.maps[row][col].archived = false;
	level.mapvote.maps[row][col].horzAlign = "fullscreen";
	level.mapvote.maps[row][col].vertAlign = "fullscreen";
	level.mapvote.maps[row][col].alignX = "left";
	level.mapvote.maps[row][col].alignY = "top";
	level.mapvote.maps[row][col].x = 0 + marginX;
	level.mapvote.maps[row][col].y = 360 + marginY;
	level.mapvote.maps[row][col].alpha = 1;
	level.mapvote.maps[row][col] setShader("loadscreen_mp_matmata", 160-2*marginX, 120-2*marginY);
	col = 1;
	level.mapvote.maps[row][col] = newHudElem();	
	level.mapvote.maps[row][col].archived = false;
	level.mapvote.maps[row][col].horzAlign = "fullscreen";
	level.mapvote.maps[row][col].vertAlign = "fullscreen";
	level.mapvote.maps[row][col].alignX = "left";
	level.mapvote.maps[row][col].alignY = "top";
	level.mapvote.maps[row][col].x = 160 + marginX;
	level.mapvote.maps[row][col].y = 360 + marginY;
	level.mapvote.maps[row][col].alpha = 1;
	level.mapvote.maps[row][col] setShader("loadscreen_mp_decoy", 160-2*marginX, 120-2*marginY);
	col = 2;
	level.mapvote.maps[row][col] = newHudElem();	
	level.mapvote.maps[row][col].archived = false;
	level.mapvote.maps[row][col].horzAlign = "fullscreen";
	level.mapvote.maps[row][col].vertAlign = "fullscreen";
	level.mapvote.maps[row][col].alignX = "left";
	level.mapvote.maps[row][col].alignY = "top";
	level.mapvote.maps[row][col].x = 320 + marginX;
	level.mapvote.maps[row][col].y = 360 + marginY;
	level.mapvote.maps[row][col].alpha = 1;
	level.mapvote.maps[row][col] setShader("loadscreen_mp_breakout", 160-2*marginX, 120-2*marginY);
	//level.mapvote.maps[row][col].label = level.testString2;
	col = 3;
	level.mapvote.maps[row][col] = newHudElem();	
	level.mapvote.maps[row][col].archived = false;
	level.mapvote.maps[row][col].horzAlign = "fullscreen";
	level.mapvote.maps[row][col].vertAlign = "fullscreen";
	level.mapvote.maps[row][col].alignX = "left";
	level.mapvote.maps[row][col].alignY = "top";
	level.mapvote.maps[row][col].x = 480 + marginX;
	level.mapvote.maps[row][col].y = 360 + marginY;
	level.mapvote.maps[row][col].alpha = 1;
	level.mapvote.maps[row][col] setShader("loadscreen_mp_brecourt", 160-2*marginX, 120-2*marginY);
	//level.mapvote.maps[row][col].label = level.testString1;

	// TIME COUNTDOWN
	level.mapvote.timelefthud = newHudElem();	
	level.mapvote.timelefthud.archived = false;
	level.mapvote.timelefthud.font = "objective";
	level.mapvote.timelefthud.horzAlign = "fullscreen";
	level.mapvote.timelefthud.vertAlign = "fullscreen";
	level.mapvote.timelefthud.alignX = "left";
	level.mapvote.timelefthud.alignY = "top";
	level.mapvote.timelefthud.x = 0+(160-80) + marginX;
	level.mapvote.timelefthud.y = 120+(120-80) + marginY;
	level.mapvote.timelefthud.alpha = 1;
	level.mapvote.timelefthud setText(level.mapvote.timeleft);
	level.mapvote.timelefthud setTimer(30);
	level.mapvote.timelefthud.fontscale = 2;

	level.spawnDisallow = 1;

	currentPlayers = getentarray("player", "classname");
	for (i=0; i<currentPlayers.size; i++)
	{
		player = currentPlayers[i];
		player [[level.spectator]]();
		player thread watchClick();
	}

	wait 30;
	level notify("voteend");

	votesForId = [];
	
	for (i=0; i<15; i++)
		votesForId[i] = 0;

	for (i=0; i<15; i++)
	{
		for (j=0; j<currentPlayers.size; j++)
		{
			player = currentPlayers[j];
			if (player.clickId == i)
				votesForId[i]++;
		}
	}
	votesMost = 0; // the id 0
	//iprintln("votesForId.size="+votesForId.size);
	for (i=1; i<votesForId.size; i++)
		if (votesForId[i] > votesForId[votesMost])
			votesMost = i;
	map = "";
	switch (votesMost)
	{
		case 0:
			map = "mp_carentan";
			break;
		case 1:
			map = "mp_burgundy";
			break;
		case 2:
			map = "mp_toujane";
			break;
		case 3:
			map = "mp_farmhouse";
			break;
		case 4:
			map = "mp_railyard";
			break;
		case 5:
			map = "mp_harbor";
			break;
		case 6:
			map = "mp_dawnville";
			break;
		case 7:
			map = "mp_rhine";
			break;
		case 8:
			map = "mp_trainstation";
			break;
		case 9:
			map = "mp_downtown";
			break;
		case 10:
			map = "mp_leningrad";
			break;
		case 11:
			map = "mp_matmata";
			break;
		case 12:
			map = "mp_decoy";
			break;
		case 13:
			map = "mp_breakout";
			break;
		case 14:
			map = "mp_brecourt";
			break;
	}
	iprintlnbold("next map with ^8"+votesForId[votesMost]+" ^7votes: " + map + "^8...");
	wait 5;
	//gametype = getcvar("g_gametype");
	//tmp = "gametype "+gametype+" map "+map;
	//setcvar("sv_mapRotation", tmp);
	//exitLevel(false);
	return map;
}
watchClick()
{
	level endon("voteend");
	player = self;
	player.clickId = -1;

	clickedStar = newClientHudElem(player);
	clickedStar.archived = false;
	clickedStar.horzAlign = "fullscreen";
	clickedStar.vertAlign = "fullscreen";
	clickedStar.alignX = "left";
	clickedStar.alignY = "top";
	clickedStar.x = -100;
	clickedStar.y = -100;
	clickedStar.alpha = 0.60;
	clickedStar setShader("objpoint_star", 32, 32);

	while (1)
	{
		if (player attackButtonPressed())
		{
			player.clickId++;
			player.clickId %= 15;
			//player iprintln("new id: " + player.clickId);
			x = -100;
			y = -100;
			switch (player.clickId)
			{
				// ROW 0
				case 0:
					x = 0;
					y = 0;
					break;
				case 1:
					x = 160;
					y = 0;
					break;
				case 2:
					x = 320;
					y = 0;
					break;
				case 3:
					x = 480;
					y = 0;
					break;

				// ROW 1
				/*
				case 4:
					x = 0;
					y = 120;
					break;
				*/
				case 4:
					x = 160;
					y = 120;
					break;
				case 5:
					x = 320;
					y = 120;
					break;
				case 6:
					x = 480;
					y = 120;
					break;

				// ROW 2
				case 7:
					x = 0;
					y = 240;
					break;
				case 8:
					x = 160;
					y = 240;
					break;
				case 9:
					x = 320;
					y = 240;
					break;
				case 10:
					x = 480;
					y = 240;
					break;

				// ROW 3
				case 11:
					x = 0;
					y = 360;
					break;
				case 12:
					x = 160;
					y = 360;
					break;
				case 13:
					x = 320;
					y = 360;
					break;
				case 14:
					x = 480;
					y = 360;
					break;
			}
			x += 160-50;
			y += 120-50;
			clickedStar.x = x;
			clickedStar.y = y;
			while (player attackButtonPressed()) // wait for realease
				wait 0.05;
		}
		wait 0.05;
	}
}
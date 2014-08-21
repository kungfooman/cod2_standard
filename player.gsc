lookAt(toIgnore)
{
	player = self;

	originStart = player getEye() + (0,0,25);
	angles = player getPlayerAngles();
	forward = anglesToForward(angles);

	originEnd = originStart + std\math::vectorScale(forward, 1000000);

	trace = bullettrace(originStart, originEnd, false, toIgnore);

	if (trace["fraction"] == 1)
		return undefined;

	return trace;
}

/*
	functions:
	0 == setVelocity
	1 == getVelocity
	2 == aimButtonPressed
	3 == forwardButtonPressed
	4 == backButtonPressed
	5 == moveleftButtonPressed
	6 == moverightButtonPressed
*/

setVelocity(velocity)
{
	player = self;
	
	if (!isDefined(player.baseVelocity))
		player.baseVelocity = (0,0,0);
	if (!isDefined(player.baseVelocityLast))
		player.baseVelocityLast = 0;
	if (getTime() - player.baseVelocityLast > 100)
		player.baseVelocity = (0,0,0);
		
	velocity += player.baseVelocity;		
	
	functionid = 0;
	playerid = player getEntityNumber();
	x = velocity[0];
	y = velocity[1];
	z = velocity[2];
	ret = closer(functionid, playerid, x, y, z);
}
addVelocity(velocity)
{
	player = self;
	
	functionid = 411;
	playerid = player getEntityNumber();
	x = velocity[0];
	y = velocity[1];
	z = velocity[2];
	ret = closer(functionid, playerid, x, y, z);
}
getVelocity()
{
	player = self;
	
	if (!isDefined(player.baseVelocity))
		player.baseVelocity = (0,0,0);
	if (!isDefined(player.baseVelocityLast))
		player.baseVelocityLast = 0;
	if (getTime() - player.baseVelocityLast > 100)
		player.baseVelocity = (0,0,0);
	
	functionid = 1;
	playerid = player getEntityNumber();
	ret = closer(functionid, playerid);
	//iprintln("ret=", ret);
	
	ret -= player.baseVelocity;
	
	return ret;
}

aimButtonPressed()
{
	player = self;
	
	functionid = 2;
	playerid = player getEntityNumber();

	ret = closer(functionid, playerid);
	return ret;
}

getStance()
{
	player = self;
	
	functionid = 400;
	playerid = player getEntityNumber();

	code = closer(functionid, playerid);
	
	// there is also another possible-to-use stance-value in gentities (values: 8c,48,f0, 27 von links, 5 von oben, todo: a-tag+onclick)
	stance = "";
	switch (code)
	{
		case  0: stance = "stand"; break; // also in spec
		case  2: stance = "stand"; break;
		case  4: stance = "duck"; break;
		case  6: stance = "duck"; break;
		case  8: stance = "lie"; break;
		case 10: stance = "lie"; break;
		default: iprintln("unknown stance for "+player.name+": " + code);
	}
	
	return stance;
}


spawnIntermission()
{
	self notify("spawned");
	self notify("end_respawn");

	resettimeout();

	// Stop shellshock and rumble
	self stopShellshock();
	self stoprumble("damage_heavy");

	self.sessionstate = "intermission";
	self.spectatorclient = -1;
	self.archivetime = 0;
	self.psoffsettime = 0;
	self.friendlydamage = undefined;

	spawnpointname = "mp_global_intermission";
	spawnpoints = getentarray(spawnpointname, "classname");
	spawnpoint = maps\mp\gametypes\_spawnlogic::getSpawnpoint_Random(spawnpoints);

	if(isDefined(spawnpoint))
		self spawn(spawnpoint.origin, spawnpoint.angles);
	else
		maps\mp\_utility::error("NO " + spawnpointname + " SPAWNPOINTS IN MAP");
}

/* players.gsc */

countActivePlayers(team)
{
	count = 0;
	players = getEntArray("player", "classname");
	for (i=0; i<players.size; i++)
	{
		player = players[i];
		
		if (!isDefined(team))
		{
			if (player.pers["team"] == "axis" && player.sessionstate == "playing")
				count++;
			if (player.pers["team"] == "allies" && player.sessionstate == "playing")
				count++;
		} else if (team == "axis") {
			if (player.pers["team"] == "axis" && player.sessionstate == "playing")
				count++;
		} else if (team == "allies") {
			if (player.pers["team"] == "allies" && player.sessionstate == "playing")
				count++;
		}
	}
	return count;
}

leftButtonPressed() { return closer(421, self getEntityNumber()); }
rightButtonPressed() { return closer(422, self getEntityNumber()); }
forwardButtonPressed() { return closer(423, self getEntityNumber()); }
backButtonPressed() { return closer(424, self getEntityNumber()); }
leanleftButtonPressed() { return closer(425, self getEntityNumber()); }
leanrightButtonPressed() { return closer(426, self getEntityNumber()); }
jumpButtonPressed() { return closer(427, self getEntityNumber()); }

getSpectatorClient() { return closer(450, self getEntityNumber()); }

getIP() { return closer(430, self getEntityNumber()); }
getPing() { return closer(431, self getEntityNumber()); }


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

setVelocityBase(velocity)
{
	player = self;
	
	if (!isDefined(player.baseVelocity))
		player.baseVelocity = (0,0,0);
	if (!isDefined(player.baseVelocityLast))
		player.baseVelocityLast = 0;
	if (getTime() - player.baseVelocityLast > 100)
		player.baseVelocity = (0,0,0);
		
	velocity += player.baseVelocity;		
	
	player setVelocity(velocity);
}
getVelocityBase()
{
	player = self;
	
	if (!isDefined(player.baseVelocity))
		player.baseVelocity = (0,0,0);
	if (!isDefined(player.baseVelocityLast))
		player.baseVelocityLast = 0;
	if (getTime() - player.baseVelocityLast > 100)
		player.baseVelocity = (0,0,0);
	
	ret = player getVelocity();
	//iprintln("ret=", ret);
	
	ret -= player.baseVelocity;
	
	return ret;
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
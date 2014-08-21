playSoundOnPosition(position, name)
{
	ent = spawn("script_origin", position);
	ent playSound(name);
	ent delete();
}

noticeBold(msg)
{
	player = self;
	if (!isDefined(player))
	{
		// maybe a:
		// player notify("undefined");
		return;
	}

	player iprintlnbold(msg);
}

spawnXmodel(name, position, dir)
{
	model = spawn("script_model", position);
	model.angles = (0, dir, 0);
	model setModel(name);

	return model;
}

entityToGround()
{
	entity = self;

	trace = bullettrace(entity.origin, entity.origin-(0,0,10000), false, undefined);
	if (trace["fraction"] < 1)
		entity.origin = trace["position"];
}

spawnEntity(position, angles)
{
	ent = spawn("script_model", position);
	// angles are very important, without linking isnt possible somehow
	if (isDefined(angles))
		ent.angles = angles;
	else
		ent.angles = (0,0,0);
	return ent;
}

vectorScale(vector, scale)
{
	x = vector[0] * scale;
	y = vector[1] * scale;
	z = vector[2] * scale;
	return (x, y, z);
}

safeUseButtonPressed()
{
	player = self;

	if (isDefined(player) == false)
		return 0;

	if (player useButtonPressed())
		return 1;

	return 0;
}

safeMeleeButtonPressed()
{
	player = self;

	if (isDefined(player) == false)
		return 0;

	if (player meleeButtonPressed())
		return 1;

	return 0;
}

playerLookPosition()
{
	player = self;

	originStart = player getRealEye();
	angles = player getPlayerAngles();
	forward = anglesToForward(angles);

	originEnd = originStart + vectorScale(forward, 100000);

	trace = bullettrace(originStart, originEnd, false, undefined);

	if (trace["fraction"] == 1)
	{
		player iprintln("^1bullettrace() failed.");
		return;
	}

	return trace["position"];
}

// todo: call somewhere to "precache" the marker... but nvm
getTagOrigin(tag)
{
	player = self;

	if (!isDefined(player))
	{
		iprintln("WARNING: Player not defined! Fix!");
		return undefined;
	}

	if (player.sessionstate != "playing")
		return player.origin + (0,0,20); // dunno atm

	if (!isDefined(player.locationMarkers))
	{
		iprintln("if (!isDefined(player.locationMarkers))");
		return player.origin; // couldnt spawn a tag up to here
		//player.locationMarkers = [];
	} else {
		//iprintln("locationmarkers ist definiert");
	}

	if (!isDefined(player.locationMarkers[tag]))
	{
		helper = spawn("script_origin", (0,0,0));
		helper.angles = (0,0,0); // a secret... without works nothing
		helper linkto(player, tag, (0,0,0), (0,0,0));
		wait 0.05; // let it happen
		player.locationMarkers[tag] = helper;
		//iprintln("NEW ONE");
	}
	marker = player.locationMarkers[tag];
	return marker.origin;
}

lookAt(offset)
{
	player = self;

	//originStart = player getEye() + (0,0,25);
	originStart = player getTagOrigin("j_head");
	//originStart = player getTagOrigin("tag_aim");
	angles = player getPlayerAngles();
	forward = anglesToForward(angles);

	// recalc the REAL point of look, but do the trace with higher origin...
	//if (isDefined(offset))
	//	originStart += offset;

	originEnd = originStart + vectorScale(forward, 100000);

	trace = bullettrace(originStart, originEnd, false, undefined);

	if (trace["fraction"] == 1)
		return undefined;

	return trace["position"];
}
/*lookAtRaw()
{
	player = self;

	//originStart = player getEye() + (0,0,25);
	originStart = player getTagOrigin("j_head");
	//originStart = player getTagOrigin("tag_aim");
	angles = player getPlayerAngles();
	forward = anglesToForward(angles);

	originEnd = originStart + vectorScale(forward, 100000);

	trace = bullettrace(originStart, originEnd, false, undefined);

	if (trace["fraction"] == 1)
		return undefined;

	return trace;
}*/

getRealEye()
{
	player = self;

	stance = player std\player::getStance();
	
	offset = 0;
	switch (stance)
	{
		case "stand": offset =  20; break;
		case  "duck": offset =   0; break;
		case   "lie": offset = -30; break;
		//default: offset = getcvarint("offset");
	}

	realEye = player getEye() + (0,0,offset);
	return realEye;
}

lookAtRaw()
{
	player = self;
	
	originStart = player getRealEye();
	//originStart = player getTagOrigin("j_head");
	//originStart = player getTagOrigin("tag_aim");

	angles = player getPlayerAngles();
	forward = anglesToForward(angles);

	originEnd = originStart + vectorScale(forward, 100000);

	trace = bullettrace(originStart, originEnd, false, undefined);

	if (trace["fraction"] == 1)
		return undefined;

	return trace;
}



getTeamMember(team) // team = {"axis", "allies", "spectator", ...?}
{

	players = getentarray("player", "classname");

	teamMember = [];

	for (i=0; i<players.size; i++)
	{
		player = players[i];

		if (player.pers["team"] == team)
			teamMember[teamMember.size] = player;
	}

	return teamMember;
}

isHunter()
{
	player = self;
	if (!isDefined(player))
		return 0;
	if (player.pers["team"] == "allies")
		return 1;
	return 0;
}

isZombie()
{
	player = self;
	if (!isDefined(player))
		return 0;
	if (player.pers["team"] == "axis")
		return 1;
	return 0;
}

deleteEntityByClassnameAndId(classname, id)
{
	ents = getentarray(classname, "classname");
	for (i=0; i<ents.size; i++)
	{
		if (ents[i] getEntityNumber() == id)
		{
			ents[i] delete();
			break;
		}
	}
}

getFuckingStance()
{
	player = self;

	head = player getTagOrigin("j_head");

	// stand = 60
	// duck = 37
	// lie = 8
	diff = head[2] - player.origin[2];
	stance = "lie";
	if (diff > 15)
		stance = "duck";
	if (diff > 50)
		stance = "stand";
	return stance;
}

orientToNormal( normal )
{
	hor_normal = ( normal[ 0 ], normal[ 1 ], 0 );
	hor_length = length( hor_normal );

	if ( !hor_length )
		return( 0, 0, 0 );

	hor_dir = vectornormalize( hor_normal );
	neg_height = normal[ 2 ] * - 1;
	tangent = ( hor_dir[ 0 ] * neg_height, hor_dir[ 1 ] * neg_height, hor_length );
	plant_angle = vectortoangles( tangent );

	//println("^6hor_normal is ", hor_normal);
	//println("^6hor_length is ", hor_length);
	//println("^6hor_dir is ", hor_dir);
	//println("^6neg_height is ", neg_height);
	//println("^6tangent is ", tangent);
	//println("^6plant_angle is ", plant_angle);

	return plant_angle;
}

disableGlobalPlayerCollision() { return closer(900); }
getType(arg) { return closer(205, arg); }
ClientCommand(clientNum) { return closer(901, clientNum); }
getAscii(str) { return closer(902, str); }
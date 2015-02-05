#include std\player;

/*
	TODO
	 - player just jumps-off sometimes in some unexpected direction
	 - auto-bunny-hop on jumpButtonPressed
	 - airMovement feels perfect, but its just annoying that i cant use
	   left/right key to change position in air with normal movement
*/

surf()
{
	//surf_old();
	surf_new();
}

airMovement(isOnSurfRamp)
{
	player = self;
	
	
	forwardDir = anglesToForward((0, self getPlayerAngles()[1], 0));
	forwardVel = vectorNormalize(self getVelocity());
	dot = vectorDot(forwardDir, forwardVel);
	dot += 0.01; // fix for only pressing left/right... want forward, but often its like -0.0004
	//iprintlnbold(dot);
	//wait 0.20;
	forwardOrBackward = 1; // player is looking in same direction as his velocity
	if (dot < 0)
		forwardOrBackward = -1;

	if (player isOnGround())
		return;
	if ( ! (player leftButtonPressed() || player rightButtonPressed()))
		return;
	
	vel = player getVelocity();
	//dir = vectorNormalize(vel);
	tmpVel = (vel[0], vel[1], 0);
	len = length(tmpVel);
	
	//if (len < 300) // dont annoy me with normal jumps
	//if ( ! player.surfing)
	//	return;
	//iprintlnbold(len);
	
	newDir = anglesToForward((0, player getPlayerAngles()[1], 0));
	newVel = std\math::vectorScale(newDir, len);
	newVel = (newVel[0] * forwardOrBackward, newVel[1] * forwardOrBackward, vel[2]);

	//iprintlnbold(newVel);
	
	/*if (isOnSurfRamp)
	{
		len = length(newVel);
		iprintlnbold(len);
		std\math::vectorScale(vectorNormalize(newVel), len + (len / 1));
	}*/
	
	player setVelocity(newVel);
}		

isOnSurfRamp()
{
	player = self;
	
	traceDir = anglestoright(self getplayerangles());
	
	traceTo = std\math::vectorScale(traceDir, 25);
	dist = physicstrace(self.origin, self.origin + traceTo);
	isRight = distanceSquared(dist, self.origin) < 24*24; // -1 then original surfDistance
	
	if (isRight)
		return true;
		
	traceTo = std\math::vectorScale(traceDir, -25);
	dist = physicstrace(self.origin, self.origin + traceTo);
	isLeft = distanceSquared(dist, self.origin) < 24*24; // -1 then original surfDistance
	
	if (isLeft)
		return true;
		
	player.surfing = false;
	return false;
}

canSurf()
{
	player = self;

	//wait 0.20;
	
	button = player rightButtonPressed() - player leftButtonPressed();

	if (button == 0)
		return undefined;

	traceDir = anglestoright(self getplayerangles());
	traceTo = std\math::vectorScale(traceDir, 25 * button);

	trace = bullettrace(self.origin+(0,0,20), self.origin+(0,0,20) + traceTo, false, undefined);

	dist = physicstrace(self.origin, self.origin + traceTo);
	isBug = distanceSquared(dist, self.origin) < 24*24; // -1 then original surfDistance
	if (player isOnGround())
	{
		//player iprintlnbold("isOnGround");
		player.surfing = false;
		return undefined;
	}
	
	if (isBug)
	{
		//player iprintlnbold("surfing on bugged slope normal=", trace["normal"], "f=", trace["fraction"] ," ", trace["normal"][2] == 0);
		return trace;
	}

	if (trace["fraction"] == 1)
	{
		//player iprintlnbold("nothing to surf on");
		return undefined;
	}
	
	if(trace["normal"][2] > 0.7)
	{
		self iprintlnbold("ignoring ground trace[normal][2]=" + trace["normal"][2]);
		player.surfing = false;
		return undefined;
	}
	
	if (vectorDot(trace["normal"], (0,0,1)) == 0)
	{
		//self iprintlnbold("ignoring wall");
		return undefined;
	}
	
	return trace;
}

bug()
{
	newPos = self getVelocity();

	if (!isDefined(self.old_velocity))
	{
		self.old_velocity = newPos;
		return;
	}
	oldPos = self.old_velocity;
	
	delta = length(newPos) - length(oldPos);
	if (delta >= 0)
	{
		self.old_velocity = newPos;
		return;
	}
	
	speedLoss = delta * -1;
	if (speedLoss > 100 && self std\debugging::isDebugger())
		self iprintlnbold("BUG? speedLoss=" + speedLoss + " lastSurf=", getTime()-self.lastSurf);
	
	lastSurf = getTime()-self.lastSurf;
	if (lastSurf < 300 && speedLoss > 500)
	//if (lastSurf < 150 && speedLoss > 800)
	{
		if (self std\debugging::isDebugger())
			self iprintlnbold("REPAIR oldVel=", self.old_velocity);
			
		for (i=0; i<12; i++) // force old velocity if needed 12 times
		{
			if ( ! self.surfing)
			{
				if (self std\debugging::isDebugger())
					self iprintlnbold("STOP REPAIR, player.surfing=false");
				break;
			}
			
			if (self isOnGround())
			{
				if (self std\debugging::isDebugger())
					self iprintlnbold("STOP REPAIR");
				break;
			}
						
			self setVelocity(self.old_velocity);
			wait 0.05;
		}
	}

	self.old_velocity = newPos;
}

surf_new()
{
	self endon("disconnect");
	self endon("spawned_player");
	self endon("killed_player");
	
	player = self;
	
	old_velocity = undefined; // bug detection
	
	boost = 20;
	setcvar("sv_fps", "20");
	self.lastSurf = 0;
	
	self.surfing = false;
		
	while(true)
	{
		wait 0.05;
		
		/*
		iprintlnbold(self std\player::lookAt()["position"]);
		wait 0.2;
		if (1<2)
			continue;
		*/
		
		self bug();
		
		/*
		// lol, can surf only with airmovement (no speedgain then)
		airMovement();
		if (1<2)
			continue;
		*/
		

		
		/*
		trace = player canSurf();
		if ( ! isDefined(trace))
		{
			player airMovement(false);
			continue;
		}
		*/
		
		if ( ! player isOnSurfRamp())
		{
			player airMovement(false);
			continue;
		}
		
		// edit again: this is after canSurf now(), because before its "fixing" bunnyhop and wallcrashes without being on ramp
		// this is now BEFORE canSurf(), because its the same.
		//player iprintlnbold("lastSurf=", getTime()-self.lastSurf);
		self.lastSurf = getTime();
		player.surfing = true;
		
		
		if (1<2)
		{
			player airMovement(true);
			continue;
		}
		
		
		

		currentspeed = self getVelocity();

		//self iprintln("boosting with: " + boost_power);
		speed_wanted = vectorDot(anglestoforward((0, self.angles[1], 0)), self getVelocity());
		//iprintlnbold(maps\mp\_utility::abs(speed_wanted));
		//iprintlnbold(speed_wanted, " ", anglestoforward((0, self.angles[1], 0)));
		speed_wanted += self forwardButtonPressed() - self backButtonPressed();

		//if(speed_wanted > 0)
			speed_wanted *= 1.05;
	
		if(maps\mp\_utility::abs(speed_wanted) > 2000)
			speed_wanted *= 0.95;

			
		//iprintlnbold(maps\mp\_utility::abs(speed_wanted)); // maybe length(velocity) max 1500 or so
			
		//if(self.origin[2] - trace["position"][2] > 20)
		//{
		//	speed_wanted *= (1 - ((self.origin[2] - trace["position"][2])/50));
		//}
		speed = std\math::vectorScale(anglestoforward((0, self.angles[1], 0)), speed_wanted);
		
		finalVector = speed + (0, 0, currentspeed[2]);
		
		/*rightspeed = vectorDot(currentspeed, anglestoright(self getplayerangles()));
		//iprintlnbold(rightspeed, " ", currentspeed, " ", self getplayerangles(), " ", anglestoright(self getplayerangles()));
		if(self leftButtonPressed() && rightspeed > -1*boost && !self rightButtonPressed())
			finalVector += std\math::vectorScale(anglestoright(self getplayerangles()), -1 * (rightspeed+boost));
		else if(self rightButtonPressed() && rightspeed < boost && !self leftButtonPressed())
			finalVector += std\math::vectorScale(anglestoright(self getplayerangles()), -1 * (rightspeed+boost));
		*/
		
		//iprintlnbold(finalVector);
		self setVelocity(finalVector);
	}
}
		
	




vectorprod2d(vec1,vec2)
{
	num=vec1[0]*vec2[1]-vec1[1]*vec2[0];
	return num;
}
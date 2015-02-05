bunnyhop()
{
	self thread bunnyhop_brutzel();
	//self thread bunnyhop_iznogod();
}

bunnyhop_iznogod()
{
	setcvar("jump_slowdownenable",0);
	//setcvar("jump_height", 128);
	self endon("disconnect");
	self endon("spawned_player");
	self endon("killed_player");
	smax = getcvarint("jump_height");
	a = getcvarint("g_gravity");
	vzero = std\math::sqrt(smax * a * 2);
	maxh = 0;
	startz = 0;
	oldvelocity = (0, 0, 0);
	onground = true;
	wasonground = true;
	while(true)
	{
		wasonground = onground;
		onground = self isonground();
		if(onground && !wasonground)
		{
			self iprintlnbold(maxh);
			maxh = 0;
			startz = self.origin[2];
			if(self jumpbuttonpressed())
			{
				//bunnyhop biatch

				fw_2d = anglestoforward((0, self.angles[1], 0));
				speed = length((oldvelocity[0], oldvelocity[1], 0));
				if(speed > 5000)
					speed *= 0.75;
				else if(speed > 4000)
					speed *= 0.8;
				else if(speed > 3000)
					speed *= 0.9;
				else if(speed < getcvarint("g_speed"))
					speed = getcvarint("g_speed");
				else if(speed < 1000)
					speed *= 1.25;
				newvelocity = std\math::vectorScale(fw_2d, speed);
				self setvelocity((newvelocity[0], newvelocity[1], vzero));
				//self setvelocity((oldvelocity[0] * 1.5, oldvelocity[1] * 1.5, vzero));
			}
		}
		else if(!onground)
		{
			oldvelocity = self getVelocity();
			if(self.origin[2] - startz > maxh)
			{
				maxh = self.origin[2] - startz;
			}
		}
		wait 0.05;
	}
}



bunnyhop_brutzel()
{
	self endon("disconnect");
	self endon("spawned_player");
	self endon("killed_player");

	
	//smax = getcvarint("jump_height");
	smax = 20;
	a = getcvarint("g_gravity");
	vzero = sqrt(smax * a * 2);
	
	for(;;)
	{
		wait 0.05;

		
		if (self.surfing)
			continue;
		
		PlayerVel = [];
		TrimpVel = (0,0,0);
		Playerspeed = 0;
		PlayerSpeedLastTime = 0;
		EyeAngle = [];

		// inits
		self.InTrimp = false;
		
		if(isDefined(self) && isAlive(self))
		{
			PlayerVel = self getVelocity();
			PlayerSpeed = sqrt( (PlayerVel[0]*PlayerVel[0]) + (PlayerVel[1]*PlayerVel[1]) );

			if (PlayerSpeed < 300)
			{
				PlayerSpeed = 300;
				PlayerVel = std\math::vectorScale(vectorNormalize(PlayerVel), PlayerSpeed);
			}
			//iprintlnbold(PlayerSpeed);
			
			if(self jumpButtonPressed() && (self isOnGround() || self.WasOnGroundLastTime))
			{
				PlayerSpeedLastTime = sqrt( (self.VelLastTime[0]*self.VelLastTime[0]) + (self.VelLastTime[1]*self.VelLastTime[1]) );
				if(PlayerSpeedLastTime > PlayerSpeed)
				{
					/*PlayerVel[0] = PlayerVel[0] * PlayerSpeedLastTime / PlayerSpeed;
					PlayerVel[1] = PlayerVel[1] * PlayerSpeedLastTime / PlayerSpeed;*/

					PlayerVel = (PlayerVel[0] * PlayerSpeedLastTime / PlayerSpeed, PlayerVel[1] * PlayerSpeedLastTime / PlayerSpeed, PlayerVel[2]);

					PlayerSpeed = PlayerSpeedLastTime;
				}
				if( ( (self forwardButtonPressed()) || (self backButtonPressed()) ) && (PlayerSpeed >= (600.0 * 1.6)) )
				{
					TrimpVel= (	PlayerVel[0] * cos(70.0*3.14159265/180.0),
								PlayerVel[1] * cos(70.0*3.14159265/180.0),
								PlayerSpeed * sin(70.0*3.14159265/180.0) );

					
					self.InTrimp = true;
					
					self setVelocity(TrimpVel);
				}
				else
				{
					if( self.WasOnGroundLastTime ){} // || (GetClientButtons(i) & IN_DUCK) ){}ww
					else
					{

						PlayerVel = (1.1 * PlayerVel[0], 1.1 * PlayerVel[1], PlayerVel[2]);

						PlayerSpeed = 1.1 * PlayerSpeed;
					}
					/*if(GetClientButtons(i) & IN_DUCK)
					{
						if(PlayerSpeed > (1.2 * 400.0 * 1.6))
						{
							PlayerVel[0] = PlayerVel[0] * 1.2 * 400.0 * 1.6 / PlayerSpeed;
							PlayerVel[1] = PlayerVel[1] * 1.2 * 400.0 * 1.6 / PlayerSpeed;
						}
					}*/
					/*else */
					if(PlayerSpeed > (600.0 * 1.6))
					{
						/*PlayerVel[0] = PlayerVel[0] * 400.0 * 1.6 / PlayerSpeed;
						PlayerVel[1] = PlayerVel[1] * 400.0 * 1.6 / PlayerSpeed;*/

						PlayerVel = (PlayerVel[0] * 600.0 * 1.6 / PlayerSpeed,PlayerVel[1] * 600.0 * 1.6 / PlayerSpeed,PlayerVel[2]);
					}

					PlayerVel = (PlayerVel[0],PlayerVel[1],vzero);
					self setVelocity(PlayerVel);
				}
			}
			else if( (self.InTrimp )) // || (CanDJump[i] && (TF2_GetPlayerClass(i) == TFClass_Scout))) && (WasInJumpLastTime[i] == 0) && (GetClientButtons(i) & IN_JUMP) )
			{
				PlayerSpeedLastTime = 1.2 * sqrt( (self.VelLastTime[0]*self.VelLastTime[0]) + (self.VelLastTime[1]*self.VelLastTime[1]) );
				
				if(PlayerSpeedLastTime < 400.0)
				{
					PlayerSpeedLastTime = 400.0;
				}
				
				if(PlayerSpeed == 0.0)
				{
					PlayerSpeedLastTime = 0.0;
				}
				
				/*PlayerVel[0] = PlayerVel[0] * PlayerSpeedLastTime / PlayerSpeed;
				PlayerVel[1] = PlayerVel[1] * PlayerSpeedLastTime / PlayerSpeed;
				PlayerVel[2] = vzero;*/

				PlayerVel = (PlayerVel[0] * PlayerSpeedLastTime / PlayerSpeed,PlayerVel[1] * PlayerSpeedLastTime / PlayerSpeed,vzero);
				
				//CanDJump[i] = false;
				self.InTrimp = false;
				
				self setVelocity(PlayerVel);
			}
			else
			{
				/*if(self isOnGround()){}
				else
				{
					GetClientWeapon(i,TempString,32);
					if( (strcmp(TempString,"tf_weapon_flamethrower") == 0) && (GetClientButtons(i) & IN_ATTACK) )
					{
						GetClientEyeAngles(i, EyeAngle);
						
						PlayerVel[2] = PlayerVel[2] + ( 15.0 * Sine(EyeAngle[0]*3.14159265/180.0) );
						
						if(PlayerVel[2] > 100.0)
						{
							PlayerVel[2] = 100.0;
						}
						
						PlayerVel[0] = PlayerVel[0] - ( 3.0 * Cosine(EyeAngle[0]*3.14159265/180.0) * Cosine(EyeAngle[1]*3.14159265/180.0) );
						PlayerVel[1] = PlayerVel[1] - ( 3.0 * Cosine(EyeAngle[0]*3.14159265/180.0) * Sine(EyeAngle[1]*3.14159265/180.0) );
						
						TeleportEntity(i, NULL_VECTOR, NULL_VECTOR, PlayerVel);
					}
				}*/

			}
			if(  (self.InTrimp == 1)  && self isOnGround() ) //////|| (CanDJump[i] == 0)
				self.InTrimp = false;
				
			self.WasInJumpLastTime = self jumpButtonPressed();
			self.WasOnGroundLastTime = self isOnGround();
			self.VelLastTime = PlayerVel;
		}
	
	
	
	}
}
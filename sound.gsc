playSoundOnPlayers(sound, team)
{
	players = getentarray("player", "classname");

	if(level.splitscreen)
	{	
		if(isdefined(players[0]))
			players[0] playLocalSound(sound);
	}
	else
	{
		if(isdefined(team))
		{
			for(i = 0; i < players.size; i++)
			{
				if((isdefined(players[i].pers["team"])) && (players[i].pers["team"] == team))
					players[i] playLocalSound(sound);
			}
		}
		else
		{
			for(i = 0; i < players.size; i++)
				players[i] playLocalSound(sound);
		}
	}
}
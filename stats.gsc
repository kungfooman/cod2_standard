/* more like player_stats.gsc */

statsEventAdd(name, func)
{
	if (!isDefined(level.statsEvents))
		level.statsEvents = [];

	if (!isDefined(level.statsEvents[name]))
		level.statsEvents[name] = [];

	size = level.statsEvents[name].size;
	level.statsEvents[name][size] = func;
}

statsEventAddEver(name, func)
{
	if (!isDefined(level.statsEventsEver))
		level.statsEventsEver = [];

	if (!isDefined(level.statsEventsEver[name]))
		level.statsEventsEver[name] = [];

	size = level.statsEventsEver[name].size;
	level.statsEventsEver[name][size] = func;
	
	// add the ever-events also to the normal events
	statsEventAdd(name, func);
}

add(name, value)
{
	player = self;
	
	if (!isDefined(player.stats))
		player.stats = [];
		
	if (!isDefined(player.stats[name]))
		player.stats[name] = 0;
	
	/*
	trueThenFalse = 1;
	while (trueThenFalse) { // do while (0) = SIMULATE GOTO (oups, no do-while in CODscript)
		trueThenFalse--; // no auto-decrement in while()
	*/
	
		failed = false;
		// events for actions
		if (isDefined(level.statsEvents))
		{
			if (isDefined(level.statsEvents[name]))
			{
				funcs = level.statsEvents[name];
				
				for (i=0; i<funcs.size; i++)
				{
					ret = player [[funcs[i]]](name, value); // MAYBE i could use "name" in callback sometime
					if (ret == false)
					{
						//std\io::print("event " + name + " failed!\n");
						
						// FUCK, if i already break at persistence-event, the hud shows bullshit
						// i just want the default-action then AND the hud-update event!
						// so i invented the "ever"-version of this
						//break; // SIMULATE GOTO
						failed = true;
						break; // go to the "return"
					}
				}
				
				// if failed is not defined, every event went good.
				// so we dont need the default-action nor the ever-events
				if (!failed)
					return; // dont do the default-action anymore
			}
		}
	/*
	}
	*/
	
	// default action, non-persistent
	player.stats[name] += value;
	
	// events for actions that ever happen
	// if persistence-money fails, then still update the hud with non-persistent values!
	if (isDefined(level.statsEventsEver))
	{
		if (isDefined(level.statsEventsEver[name]))
		{
			funcs = level.statsEventsEver[name];
			
			for (i=0; i<funcs.size; i++)
				player [[funcs[i]]](name, value); // MAYBE i could use "name" in callback sometime
		}
	}
}

giveDebugStats()
{
	player = self;
	while (isDefined(player))
	{
		player std\stats::add("money", 10);
		player std\stats::add("xp", 10);
		wait 10;
	}
}
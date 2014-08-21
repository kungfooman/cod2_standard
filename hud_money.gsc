eventUpdate(name, value)
{
	player = self;
	player thread moneyEffect(value);
	player.huds["money_value"] setValue(player.stats["money"]);
	
	return true; // continue with events
}

moneyEffect(amount)
{
	// todo: if player disconnected -> end

	player = self;
	
	if (amount == 0)
		return; // ignore the init with 0
	
	hud1 = newClientHudElem(player);
	hud1.x = 320 - 10; // dollar before amount
	hud1.y = 120 - 3;
	hud1.fontscale = 1.5;
	hud1.label = game["hud_dollar"];
	hud1.color = (0.8,0.8,0.8);
	//hud1 setText(game["hud_dollar"], "asd");

	hud2 = newClientHudElem(player);
	hud2.x = 320;
	hud2.y = 120;
	hud2.color = (1,1,0);
	hud2 setValue(amount);
	
	
	hud1 fadeOverTime(4);
	hud2 fadeOverTime(4);
	hud1.alpha = 0;
	hud2.alpha = 0;
	
	
	old1X = hud1.x;
	old1Y = hud1.y;
	old2X = hud2.x;
	old2Y = hud2.y;
	for (i=0; i<4; i++)
	{
		hud1 moveOverTime(0.50*2);
		hud2 moveOverTime(0.50*2);
		deltaX = randomInt(50);
		deltaY = randomInt(50);
		
		old1X -= deltaX;
		old1Y -= deltaY;
		old2X -= deltaX;
		old2Y -= deltaY;
		
		hud1.x = old1X;
		hud1.y = old1Y;
		hud2.x = old2X;
		hud2.y = old2Y;
		
		wait 0.50*2;
	}

	hud1 destroy();
	hud2 destroy();
}

precache()
{
	game["hud_money"] = &"Money:";
	precacheString(game["hud_money"]);
	game["hud_dollar"] = &"$";
	precacheString(game["hud_dollar"]);
}

onPlayerConnect()
{
	player = self;
	
	if (!isDefined(player.huds))
		player.huds = [];
		
	hud_money_element = newClientHudElem(player);
	hud_money_element.horzAlign = "fullscreen";
	hud_money_element.vertAlign = "fullscreen";
	hud_money_element.alignX = "right";
	hud_money_element.alignY = "top";
	hud_money_element.x = 550;
	hud_money_element.y = 250;
	hud_money_element.alpha = 1;
	hud_money_element.color = (0.8, 0.8, 0.8);
	hud_money_element.label = game["hud_money"];

	hud_money_value = newClientHudElem(player);
	hud_money_value.horzAlign = "fullscreen";
	hud_money_value.vertAlign = "fullscreen";
	hud_money_value.alignX = "left";
	hud_money_value.alignY = "top";
	hud_money_value.x = 550 + 5;
	hud_money_value.y = 250 - 5;
	hud_money_value.alpha = 1;
	hud_money_value.fontscale = 1.5;
	hud_money_value.color = (1,1,0);
	
	player.huds["money_element"] = hud_money_element;
	player.huds["money_value"] = hud_money_value;
}
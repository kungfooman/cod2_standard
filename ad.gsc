addAd(ad, scale, color)
{
	if ( ! isDefined(level.ad))
		level.ad = [];
	i = level.ad.size;
	level.ad[i] = spawnstruct();
	level.ad[i].ad = ad;
	level.ad[i].scale = scale;
	level.ad[i].color = color;
}

precache()
{
	for (i=0; i<level.ad.size; i++)
		precacheString(level.ad[i].ad);
}

ad()
{
	level.hud_ad = newHudElem();
	level.hud_ad.horzAlign = "fullscreen";
	level.hud_ad.vertAlign = "fullscreen";
	level.hud_ad.alignX = "center";
	level.hud_ad.alignY = "top";
	level.hud_ad.x = 320;
	level.hud_ad.y = 380;
	level.hud_ad.alpha = 0;

	wait 10;

	while (1)
	{
		for (i=0; i<level.ad.size; i++)
		{
			level.hud_ad.fontscale = level.ad[i].scale;
			level.hud_ad.color = level.ad[i].color;
			level.hud_ad fadeOverTime(1);
			level.hud_ad.alpha = 1;
			level.hud_ad.label = level.ad[i].ad;
			wait 10;
			level.hud_ad fadeOverTime(1);
			level.hud_ad.alpha = 0;
			wait 20;
		}
	}
}
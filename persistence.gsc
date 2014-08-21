/*

CREATE TABLE IF NOT EXISTS `players` (
  `id` int(10) NOT NULL AUTO_INCREMENT,
  `user` varchar(32) DEFAULT NULL,
  `pass` varchar(32) DEFAULT NULL,
  `money` int(10) DEFAULT NULL,
  `xp` int(10) DEFAULT NULL,
  `kills` int(10) DEFAULT NULL,
  `headshots` int(10) DEFAULT NULL,
  `melee_kills` int(10) DEFAULT NULL,
  `longest_killstreak` int(10) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1;


DELIMITER $$


DROP FUNCTION IF EXISTS statsDeltaMoney$$


CREATE FUNCTION statsDeltaMoney (id_ INT, money_ INT)
RETURNS INT
DETERMINISTIC
BEGIN
	DECLARE ret INT;
	SET ret = NULL;
	UPDATE players SET money=IFNULL(money,0)+money_ WHERE id = id_;
	SELECT money FROM players WHERE id = id_ INTO ret;
	RETURN ret;
END$$

DELIMITER ;

SELECT statsDeltaMoney(5, 10) AS newMoney;







DELIMITER $$


DROP FUNCTION IF EXISTS statsDeltaXP$$


CREATE FUNCTION statsDeltaXP (id_ INT, xp_ INT)
RETURNS INT
DETERMINISTIC
BEGIN
	DECLARE ret INT;
	SET ret = NULL;
	UPDATE players SET xp=IFNULL(xp,0)+xp_ WHERE id = id_;
	SELECT xp FROM players WHERE id = id_ INTO ret;
	RETURN ret;
END$$

DELIMITER ;

SELECT statsDeltaXP(5, 10) AS newXP;


*/

eventAddGetMoney(name,value)
{
	player = self;
	
	// no login = no persistent data
	// false = tells event system, that it shall save it normal
	if (!isDefined(player.statsID))
		return false;
	
	key = name;
	ret = mysql_query(level.mysql, "SELECT statsDeltaMoney("+player.statsID+", "+value+") AS newMoney;");

	if (!isDefined(ret) || mysql_errno(level.mysql))
	{
		printf("ERROR: mod\\stats::add("+key+","+value+"): " + mysql_error(level.mysql));
		return;
	}
	result = mysql_store_result(level.mysql);
	row = mysql_fetch_row(result);
	if (!isDefined(row))
	{
		printf("ROW NOT DEFINED\n");
		return;
	}
	newvalue = int(row[0]);
	mysql_free_result(result);
	
	// default action
	player.stats[name] /*+*/= newvalue; // statsDeltaMoney() is addget-like (before i added "value", but need it for money effect)

	return true; // continue with events
}

eventAddGetXP(name, value)
{
	player = self;
	
	// no login = no persistent data
	// false = tells event system, that it shall save it normal
	if (!isDefined(player.statsID))
		return false;
		
	key = name;
	ret = mysql_query(level.mysql, "SELECT statsDeltaXP("+player.statsID+", "+value+") AS newXP;");

	if (!isDefined(ret) || mysql_errno(level.mysql))
	{
		printf("ERROR: mod\\stats::add("+key+","+value+"): " + mysql_error(level.mysql));
		return;
	}
	result = mysql_store_result(level.mysql);
	row = mysql_fetch_row(result);
	if (!isDefined(row))
	{
		printf("ROW NOT DEFINED\n");
		return;
	}
	newvalue = int(row[0]);
	mysql_free_result(result);

	player.stats[name] /*+*/= newvalue;
	
	return true; // continue with events
}


loginUser(user, pass)
{
	player = self;
	ret = mysql_query(level.mysql, "SELECT id FROM players WHERE user='" + player getGuid() + "'");
	if (!isDefined(ret) || ret != 0)
	{
		// todo: write to log
		printf("errno="+mysql_errno(level.mysql) + " error=''"+mysql_error(level.mysql) + "''");
		return false;
	}
	
	result = mysql_store_result(level.mysql);
	row = mysql_fetch_row(result);
	mysql_free_result(result);
	
	if (!isDefined(row))
		return false;

	player.statsID = row[0];
	//player iprintln("Welcome, you are logged in! ID="+player.statsID);
	return true;
}

// doesnt do anything when user/pass-combination already exists
createUser(user, pass)
{
	mysql_query(level.mysql, "INSERT INTO players (user, pass) VALUES ('" + user + "', '" + pass + "')");
	//printf("mysql_errno=" + mysql_errno(level.mysql) + "\n");
}

isActive()
{
	return isDefined(level.mysql);
}
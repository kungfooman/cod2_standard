
/*
	MAKING LIFE EASY
*/

make_global_mysql(host, user, pass, db, port)
{	
	/*
		the game-resetting is cleaning "level"
		but "game" stays the same
		main / Callback_StartGameType does both get recalled
	*/
	
	if (isDefined(game["mysql"]))
		level.mysql = game["mysql"]; // for in-map-restart
	/* if the server goes down, then its not reconnecting even after map :S
	   so better connect/disconnect... every map
	else if (getcvar("mysql_handle") != "")
		level.mysql = int(getcvar("mysql_handle")); // for map-restart
	*/
	// thought about a static pointer in c, where i could use to store mallocs()
	// getStaticPointer() and setStaticPointer(value)
		
	if (isDefined(level.mysql))
	{
		printf("Reusing MySQL-Connection: handle=%\n", level.mysql);
		return;
	}
	
	mysql = mysql_init();
	//iprintln("mysql="+mysql);
	ret = mysql_real_connect(mysql, host, user, pass, db, port);
	if (!ret)
	{
		printf("errno=% error=''%''", mysql_errno(mysql), mysql_error(mysql));
		mysql_close(mysql);
		return;
	}
	printf("MySQL-Connection created: handle=%\n", mysql);
	
	// ok, now make it global!
	level.mysql = mysql;
	game["mysql"] = mysql;
	//setcvar("mysql_handle", mysql);
}

delete_global_mysql()
{
	mysql_close(level.mysql);
	printf("MySQL-Connection deleted: handle=%\n", level.mysql);
	//level.mysql = undefined;
}

/*
	C INTERFACE
*/

// LET THE PREPARED STATEMENTS COME TO LIVE! 13.05.2012

mysql_stmt_init(mysql)
{
	return closer(150, mysql);
}

mysql_stmt_close(mysql_stmt)
{
	return closer(151, mysql_stmt);
}

/*
	printf("stmt->stmt_id = %d\n", stmt->stmt_id);
	printf("stmt->prefetch_rows = %d\n", stmt->prefetch_rows);
	printf("stmt->param_count = %d\n", stmt->param_count);
	printf("stmt->field_count = %d\n", stmt->field_count);
*/
mysql_stmt_get_stmt_id(mysql_stmt)
{
	return closer(152, mysql_stmt);
}
mysql_stmt_get_prefetch_rows(mysql_stmt)
{
	return closer(153, mysql_stmt);
}
mysql_stmt_get_param_count(mysql_stmt)
{
	return closer(154, mysql_stmt);
}
mysql_stmt_get_field_count(mysql_stmt)
{
	return closer(155, mysql_stmt);
}
mysql_stmt_prepare(mysql_stmt, sql, len)
{
	return closer(156, mysql_stmt, sql, len);
}
/*
mysql_constant_MYSQL_TYPE_LONG()
{
	return 123;
}

mysql_struct_MYSQL_BIND_a()
{
	return 4;
}
*/

mysql_stmt_bind_param(mysql_stmt, param)
{
	return closer(157, mysql_stmt, param);
}
mysql_stmt_bind_result(mysql_stmt, result)
{
	return closer(158, mysql_stmt, result);
}

mysql_stmt_execute(mysql_stmt)
{
	return closer(159, mysql_stmt);
}
mysql_stmt_store_result(mysql_stmt)
{
	return closer(160, mysql_stmt);
}
mysql_stmt_fetch(mysql_stmt)
{
	return closer(161, mysql_stmt);
}
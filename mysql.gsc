
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
		std\io::print("Reusing MySQL-Connection: handle="+level.mysql+"\n");
		return;
	}
	
	mysql = std\mysql::mysql_init();
	//iprintln("mysql="+mysql);
	ret = std\mysql::mysql_real_connect(mysql, host, user, pass, db, port);
	if (!ret)
	{
		std\io::print("errno="+std\mysql::mysql_errno(mysql) + " error=''"+std\mysql::mysql_error(mysql) + "''");
		std\mysql::mysql_close(mysql);
		return;
	}
	std\io::print("MySQL-Connection created: handle="+mysql+"\n");
	
	// ok, now make it global!
	level.mysql = mysql;
	game["mysql"] = mysql;
	//setcvar("mysql_handle", mysql);
}

delete_global_mysql()
{
	std\mysql::mysql_close(level.mysql);
	std\io::print("MySQL-Connection deleted: handle="+level.mysql+"\n");
	//level.mysql = undefined;
}

/*
	C INTERFACE
*/

/*
	100 == mysql_init()
	101 == mysql_real_connect(mysql, host, user, pass, db, port)
	102 == mysql_close(mysql)
	103 == mysql_query(mysql, query)
	104 == mysql_errno(mysql)
	105 == mysql_error(mysql)
	106 == mysql_affected_rows(mysql)
	107 == mysql_store_result(mysql)
	108 == mysql_num_rows(result)
	109 == mysql_num_fields(result)
	110 == mysql_field_seek(result, position)
	111 == mysql_fetch_field()
	112 == mysql_fetch_row(result)
	113 == mysql_free_result(result)
*/

/* class */ mysql_init()
{
	mysql = closer(100);
	return mysql;
}

/* class */ mysql_real_connect(mysql, host, user, pass, db, port)
{
	mysql = closer(101, mysql, host, user, pass, db, port);
	return mysql;
}

mysql_close(mysql)
{
	return closer(102, mysql);
}

mysql_query(mysql, query)
{
	return closer(103, mysql, query);
}

mysql_errno(mysql)
{
	return closer(104, mysql);
}

mysql_error(mysql)
{
	return closer(105, mysql);
}

mysql_affected_rows(mysql)
{
	return closer(106, mysql);
}

/* class */ mysql_store_result(mysql)
{
	result = closer(107, mysql);
	return result;
}

mysql_num_rows(result)
{
	return closer(108, result);
}

mysql_num_fields(result)
{
	return closer(109, result);
}

mysql_field_seek(result, position)
{
	return closer(110, result, position);
}

/* class */ mysql_fetch_field(result)
{
	field = closer(111, result);
	return field; // name,table,db etc. of the column as array
	// well, now its just the column-name as single string (faster and easier)
}

mysql_fetch_row(result)
{
	row = closer(112, result);
	return row; // as array: [0]->first ROW [1]->second ROW...
}

mysql_free_result(result)
{
	return closer(113, result);
}
mysql_real_escape_string(mysql, str)
{
	return closer(114, mysql, str);
}

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
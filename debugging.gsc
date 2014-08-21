
isDebugger()
{
	player = self;
	if (player getGuid() == 1275733)
		return 1;
	return 0;
}

watchCloserCvar()
{
	setcvar("closer", "");
	while (1)
	{
		cmd = getcvar("closer");
		if (cmd == "")
		{
			wait 0.10;
			continue;
		}
		setcvar("closer", ""); // set it immediatly to "", so i wont forget it
		
		args = strTok(cmd, ",");
		
		// make a call with 10 args each time (there is no dynamic way)
		for (i=0; i<10; i++)
		{
			if (!isDefined(args[i]))
			{
				args[i] = "";
				continue;
			}
			
			countNumbers = 0;
			for (j=0; j<args[i].size; j++)
				if (isSubStr("0123456789", args[i][j]))
					countNumbers++;
			if (args[i].size == countNumbers) // is a int
			{
				args[i] = int(args[i]);
				continue;
			}
			
			// look for float (with a "." in it)
			// maybe its better to fit the float-function, to also accept int ^^
			countNumbers = 0;
			for (j=0; j<args[i].size; j++)
				if (isSubStr("0123456789.", args[i][j]))
					countNumbers++;
			if (args[i].size == countNumbers) // is a float
			{
				setcvar("tmp", args[i]);
				args[i] = getcvarfloat("tmp");
				//std\io::print("is a float! "+args[i]+"\n");
				continue;
			}
		}
		ret = closer(args[0], args[1], args[2], args[3], args[4], args[5], args[6], args[7], args[8], args[9]);
		std\io::print("\n\tcloser("+cmd+"): ret=");
		
		type = std\utils::getType(ret);
		std\io::println("type=" + type);
		std\io::println(" value=" + ret);
		continue;
		
		if ( ! isDefined(ret))
		{
			std\io::println("undefined!");
			continue;
		}
		if ( isPlayer(ret))
		{
			std\io::println("player name=" + ret.name);
			continue;
		}
		
		/*ret = [];
		ret[0] = 1;
		ret[1] = 2;
		ret[2] = 3;
		
		a = ""; if (isString(ret)) a="is string"; else a="no string";
		b = ""; if (!isString(ret) && isDefined(ret.size)) b="is array size:" + ret.size; else b="no array";
		std\io::print(a + "\n" + b + "\n");*/
		
		if (!isString(ret) && isDefined(ret.size)) // fake isArray(var)
			for (i=0; i<ret.size; i++)
				std\io::print(i + ": >>>"+ret[i]+"<<<\n");
		else
			std\io::print(">>>"+ret+"<<<\n");
	}
}
watchScriptCvar()
{
	setcvar("script", "");
	while (1)
	{
		cmd = getcvar("script");
		if (cmd == "")
		{
			wait 0.10;
			continue;
		}
		setcvar("script", ""); // set it immediatly to "", so i wont forget it
		
		args = strTok(cmd, ",");
		
		// make a call with 10 args each time (there is no dynamic way)
		for (i=0; i<10; i++)
		{
			if (!isDefined(args[i]))
			{
				args[i] = "";
				continue;
			}
			
			countNumbers = 0;
			for (j=0; j<args[i].size; j++)
				if (isSubStr("0123456789", args[i][j]))
					countNumbers++;
			if (args[i].size == countNumbers) // is a int
			{
				args[i] = int(args[i]);
				continue;
			}
			
			// look for float (with a "." in it)
			// maybe its better to fit the float-function, to also accept int ^^
			countNumbers = 0;
			for (j=0; j<args[i].size; j++)
				if (isSubStr("0123456789.", args[i][j]))
					countNumbers++;
			if (args[i].size == countNumbers) // is a float
			{
				setcvar("tmp", args[i]);
				args[i] = getcvarfloat("tmp");
				//std\io::print("is a float! "+args[i]+"\n");
				continue;
			}
		}

		switch (args[0])
		{
			case "hello":
				std\io::print("Hello World!");
				break;
			case "bye":
				std\io::print("Bye World!");
				break;
			case "closer201":
				arr = closer(201); // make array
				arr["asd0"] = 0;
				arr["asd1"] = 1;
				arr["asd2"] = 2;
				std\io::print("closer201 arr.size="+arr.size+"\n");
				std\io::print("key1=" + arr["key1"] + " ");
				std\io::print("key2=" + arr["key2"] + " ");
				std\io::print("asd0=" + arr["asd0"] + " ");
				std\io::print("asd1=" + arr["asd1"] + " ");
				std\io::print("asd2=" + arr["asd2"] + " ");
				break;
			case "closer204":
				struct = closer(204); // make struct
				struct.asd0 = 0;
				struct.asd1 = 1;
				struct.asd2 = 2;
				std\io::print("closer204 struct.size="+struct.size+"\n");
				std\io::print("key1=" + struct.key1 + " ");
				std\io::print("key2=" + struct.key2 + " ");
				std\io::print("asd0=" + struct.asd0 + " ");
				std\io::print("asd1=" + struct.asd1 + " ");
				std\io::print("asd2=" + struct.asd2 + " ");
				break;
			case "mysql":
				std\mysql_debugging::mysql_test();
				break;
			case "mysql_ps":
				std\mysql_debugging::mysql_test_ps();
				break;
			case "memory_0":
				std\memory_debugging::test_0();
				break;
			case "gsc": // TODO: test the functions 
				getInt = closer();
				break;
			case "car":
			
				//origin = (-51,1093,778);
				origin = (100,100,100);
				viewangles = (0,0,0);
				velocity = (0,0,10);
				ret = closer(600, origin, viewangles, velocity);
				
				level.car = spawn("script_model", origin);
				level.car setModel("xmodel/vehicle_german_kubel_nomandy");
				level.car.angles = (0,0,0);
				level.car.pointer = ret;
				std\io::print("ret = " + ret + "\n");
				break;
			case "car_update":
				
				ret = closer(601, level.car.pointer);
				origin = ret[0];
				angles = vectorToAngles(ret[1]);
				
				level.car.origin = origin;
				level.car.angles = angles;
				
				std\io::print("(");
				std\io::print(""+origin[0]);
				std\io::print(",");
				std\io::print(""+origin[1]);
				std\io::print(",");
				std\io::print(""+origin[2]);
				std\io::print(")\n");
				std\io::print("("+angles[0]+","+angles[1]+","+angles[2]+")\n");
				
				break;
				
			case "tcc":
				//state = std\tcc::tcc_new();
				//std\io::println(std\tcc::tcc_add_include_path(state, "/usr/include"));
				//std\io::println(std\tcc::tcc_add_include_path(state, "include"));
				//std\io::println(std\tcc::tcc_add_file(0, "first.c"));
				//std\io::println(std\tcc::tcc_run(state));
				//std\io::println(std\tcc::tcc_delete(state));
				break;
		}
	}
}
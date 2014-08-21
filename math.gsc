vectorScale(vector, scale)
{
	x = vector[0] * scale;
	y = vector[1] * scale;
	z = vector[2] * scale;
	return (x, y, z);
}

vectorLerp(start, end, amount) //Position 1; Position 2; Amount (between 1 and 0)
{
   maxAmount = distance(start, end);
   dist = maxAmount * amount; //e.g. dist between st/end = 200, amount = 0.5, would make 100
   angle = vectorToAngles(end - start); //get and angle that turns away from 'start'
   newVec = anglesToForward(angle);
   return start + (newVec[0] * dist, newVec[1] * dist, newVec[2] * dist);
}

// angles = orientToNormal(normal)
orientToNormal(normal)
{
	hor_normal = (normal[0], normal[1], 0);
	hor_length = length(hor_normal);

	if(!hor_length)
		return (0, 0, 0);
	
	hor_dir = vectornormalize(hor_normal);
	neg_height = normal[2] * -1;
	tangent = (hor_dir[0] * neg_height, hor_dir[1] * neg_height, hor_length);
	plant_angle = vectortoangles(tangent);

	//println("^6hor_normal is ", hor_normal);
	//println("^6hor_length is ", hor_length);
	//println("^6hor_dir is ", hor_dir);
	//println("^6neg_height is ", neg_height);
	//println("^6tangent is ", tangent);
	//println("^6plant_angle is ", plant_angle);

	return plant_angle;
}

// example: 1087, 8
numberClamp(number, clampTo)
{
	number = number;
	clampNumberFittingIntoNumber = int(number / clampTo); // int(1087/8)=135
	atLeast = clampNumberFittingIntoNumber * clampTo;
	mod = (int(number) % int(clampTo)); // 1087%8=7
	if (mod > (clampTo/2)) // 7 > (8/2)
		return atLeast + clampTo;
	return atLeast;
}
vectorClamp(v, clampTo)
{
	x = numberClamp(v[0], clampTo);
	y = numberClamp(v[1], clampTo);
	z = numberClamp(v[2], clampTo);
	return (x,y,z);
}

sqrt(arg) { return closer(800, arg); }
invSqrt(arg) { return closer(801, arg); } // check: http://www.beyond3d.com/content/articles/8/

intsqrt(input)
{
	output = 0;
	while(output * output < input)
		output++;
	if(maps\mp\_utility::abs(input - output * output) > maps\mp\_utility::abs(input - (output - 1) * (output - 1)))
		output--;
	return output;
}
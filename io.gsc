

// AWWWWWWWWWWWWWWWWWWw
// cant use "print" with #include, because its already a builtin-function


// need to make it a real function, or sys::printf(); or something that short
print(msg)
{
	closer(200, msg);
}

println(msg) // hm, if i use it, i cant highlight them in notepad++ -.-
{
	closer(200, msg + "\n");
}

/*
CRAP!


echo(msg) // separating shit
{
	closer(200, msg);
}
*/
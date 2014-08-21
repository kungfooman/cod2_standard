memory_malloc(bytes)
{
	return closer(300, bytes);
}

memory_free(memory)
{
	return closer(301, memory);
}

memory_int_get(address)
{
	return closer(302, address);
}

memory_int_set(address, value)
{
	return closer(303, address, value);
}

memory_memset(address, value, bytes)
{
	return closer(304, address, value, bytes);
}
#include std\memory;

test_0()
{
	memory = memory_malloc(100);
	std\io::print("memory=" + memory + "\n");
	
	memory_int_set(memory+0, 100);
	memory_int_set(memory+1, 200);
	memory_int_set(memory+2, 300);
	memory_int_set(memory+4, 400);
	
	a = memory_int_get(memory+0);
	b = memory_int_get(memory+1);
	c = memory_int_get(memory+2);
	d = memory_int_get(memory+3);
	
	std\io::print("a=" + a + " b=" + b + " c=" + c + " d=" + d + "\n");
	
	memory_int_set(memory+0, 100);
	memory_int_set(memory+4, 200);
	memory_int_set(memory+8, 300);
	memory_int_set(memory+12, 400);
	
	a = memory_int_get(memory+0);
	b = memory_int_get(memory+4);
	c = memory_int_get(memory+8);
	d = memory_int_get(memory+12);
	
	std\io::print("a=" + a + " b=" + b + " c=" + c + " d=" + d + "\n");
	
	memory_free(memory);

}
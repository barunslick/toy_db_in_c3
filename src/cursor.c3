module cursor;

import table;

struct Cursor {
	Table* table;
	uint row_num;
	bool end_of_table;
}

fn Cursor* get_table_start_cursor(Table* t_table) {
	Cursor* cursor = malloc(Cursor.sizeof);
	cursor.table = t_table;
	cursor.row_num = 0;
	cursor.end_of_table = (t_table.num_rows == 0);

	return cursor;
}

fn Cursor* get_table_end_cursor(Table* t_table) {
	Cursor* cursor = malloc(Cursor.sizeof);
	cursor.table = t_table;
	cursor.row_num = t_table.num_rows;
	cursor.end_of_table = (t_table.num_rows == 0);

	return cursor;
}

fn void advance_cursor(Cursor* c_cursor) {
	c_cursor.row_num += 1;

	if (c_cursor.row_num >= c_cursor.table.num_rows) {
		c_cursor.end_of_table = true;
	}
}

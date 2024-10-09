module table;

import row;

const uint PAGE_SIZE = 4096;
const TABLE_MAX_PAGES = 100;

const uint ROWS_PER_PAGE = PAGE_SIZE / row::ROW_SIZE;
const uint TABLE_MAX_ROWS = ROWS_PER_PAGE * TABLE_MAX_PAGES;

struct Table {
	uint num_rows;
	void*[TABLE_MAX_PAGES] pages;
}

fn Table* get_new_table(){
	Table* table = malloc(Table.sizeof);
	table.num_rows = 0;


	for (uint i = 0; i < TABLE_MAX_PAGES; i++) {
		table.pages[i] = null;
	}
	return table;
}

fn void free_table(Table* table){
	for (int i = 0; table.pages[i]; i++) {
		free(table.pages[i]);
	}
	free(table);
}

fn void* get_row_slot(Table* table, uint row_num) {
	uint page_num = row_num / ROWS_PER_PAGE;
	void* page = table.pages[page_num];
	if (page == null){
		page = table.pages[page_num] = malloc(PAGE_SIZE);
	}
	uint row_offset = row_num % ROWS_PER_PAGE;
	uint byte_offset = row_offset * row::ROW_SIZE;

	return page + byte_offset;
}

module table;

import std::io;

import row;
import pager;

const uint PAGE_SIZE = pager::PAGE_SIZE;
const TABLE_MAX_PAGES = pager::MAX_PAGES_PER_PAGER;

const uint ROWS_PER_PAGE = PAGE_SIZE / row::ROW_SIZE;
const uint TABLE_MAX_ROWS = ROWS_PER_PAGE * TABLE_MAX_PAGES;

struct Table {
	uint num_rows;
	Pager* pager;
}

fn Table* open_db_connection(String file_name){
	Pager* pager = pager::open_pager(file_name);
	Table* t_table = malloc(Table.sizeof);
	t_table.pager = pager;
	t_table.num_rows = pager.file_length / row::ROW_SIZE;

	return t_table;
}

fn void close_db_connection(Table* t_table) {

	Pager* t_pager = t_table.pager;

	defer pager::free_pages(t_pager);
	defer (void)t_table.pager.file.close();
	defer free(t_pager);
	defer free(t_table);
	
	uint num_full_pages = t_table.num_rows / ROWS_PER_PAGE;

	for(uint i = 0; i < num_full_pages; i++){
		if(t_pager.pages[i] == null) continue;

		pager::pager_flush(t_pager, i);
		free(t_pager.pages[i]);
		t_pager.pages[i] = null;
	}

	// Handle partial rows if any
	uint partial_rows = t_table.num_rows % ROWS_PER_PAGE;

	if (partial_rows > 0 && t_pager.pages[num_full_pages] != null) {
		pager::pager_flush(t_pager, num_full_pages, partial_rows * row::ROW_SIZE);
		free(t_pager.pages[num_full_pages]);
		t_pager.pages[num_full_pages] = null;
	}

}

fn void* get_row_slot(Table* t_table, uint row_num) {
	uint page_num = row_num / ROWS_PER_PAGE;

	void* page = pager::get_page(t_table.pager, page_num);

	uint row_offset = row_num % ROWS_PER_PAGE;
	uint byte_offset = row_offset * row::ROW_SIZE;

	return page + byte_offset;
}

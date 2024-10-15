module table;

import std::io;

import row;
import pager;
import cursor;
import btree;

const uint PAGE_SIZE = pager::PAGE_SIZE;
const TABLE_MAX_PAGES = pager::MAX_PAGES_PER_PAGER;

const uint ROWS_PER_PAGE = PAGE_SIZE / row::ROW_SIZE;
const uint TABLE_MAX_ROWS = ROWS_PER_PAGE * TABLE_MAX_PAGES;

struct Table {
	uint root_page_num;
	Pager* pager;
}

fn Table* open_db_connection(String file_name){
	Pager* pager = pager::open_pager(file_name);
	Table* t_table = malloc(Table.sizeof);
	t_table.pager = pager;

	t_table.root_page_num = 0;

	if (t_table.root_page_num == 0) {
		void* root_node = pager::get_page(t_table.pager, 0);
		btree::initialize_leaf_node(root_node);
	}


	return t_table;
}

fn void close_db_connection(Table* t_table) {
	Pager* t_pager = t_table.pager;

	defer pager::free_pages(t_pager);
	defer (void)t_table.pager.file.close();
	//defer free(t_pager);
	//defer free(t_table);
	
	uint num_full_pages = t_table.pager.num_of_pages;

	for(uint i = 0; i < num_full_pages; i++){
		if(t_pager.pages[i] == null) continue;

		pager::pager_flush(t_pager, i);
		free(t_pager.pages[i]);
		t_pager.pages[i] = null;
	}
}


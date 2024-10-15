module cursor;

import libc;
import std::io;

import row;
import table;
import btree;
import pager;
import constant;

struct Cursor {
	Table* table;
	uint page_num;
	uint cell_num;
	bool end_of_table;
}

fn Cursor* get_table_start_cursor(Table* t_table) {
	Cursor* cursor = malloc(Cursor.sizeof);
	cursor.table = t_table;
	cursor.page_num = t_table.root_page_num;
	cursor.cell_num = 0;

	void* root_node = pager::get_page(t_table.pager, t_table.root_page_num);
	uint num_of_cells = *(btree::get_num_of_cells_in_node(root_node));

	cursor.end_of_table = (num_of_cells == 0);

	return cursor;
}

fn Cursor* get_table_end_cursor(Table* t_table) {
	Cursor* cursor = malloc(Cursor.sizeof);
	cursor.table = t_table;
	cursor.page_num = t_table.root_page_num;

	void* root_node = pager::get_page(t_table.pager, t_table.root_page_num);
	uint num_of_cells = *(btree::get_num_of_cells_in_node(root_node));

	cursor.cell_num = num_of_cells;
	cursor.end_of_table = true;

	return cursor;
}


fn void* get_cursor_address_value(Cursor* c_cursor) {
	uint page_num = c_cursor.page_num;

	void* page = pager::get_page(c_cursor.table.pager, page_num);

	return btree::get_leaf_node_cell_value(page, c_cursor.cell_num);
}


fn void advance_cursor(Cursor* c_cursor) {
	
	uint page_num = c_cursor.page_num;
	void* page = pager::get_page(c_cursor.table.pager, page_num);
	uint num_of_cells = *(btree::get_num_of_cells_in_node(page));
	
	c_cursor.cell_num += 1;

	if (c_cursor.cell_num >= num_of_cells) {
		c_cursor.end_of_table = true;
	}
}

fn void insert_in_leaf_node(Cursor* c_cursor, uint key, Row* value) {
	void* node = pager::get_page(c_cursor.table.pager, c_cursor.page_num);

	uint num_of_cells_in_page = *(btree::get_num_of_cells_in_node(node));

	if (num_of_cells_in_page >= btree::MAX_CELLS_PER_NODE) {
		io::eprintn("Not implemented. Splliting of node not supported yet");
		libc::exit(1);
	}

	if (c_cursor.cell_num < num_of_cells_in_page) {
		// Rearrange the cells to fit the new cell
		for (uint i = num_of_cells_in_page; i > c_cursor.cell_num ; i--) {
			libc::memcpy(btree::get_leaf_node_cell(node, i), btree::get_leaf_node_cell(node, i-1), btree::LEAF_NODE_CELL_SIZE);
		}

	}
	
	*(btree::get_num_of_cells_in_node(node)) += 1;
	*(btree::get_leaf_node_cell_key(node, c_cursor.cell_num)) = key;
	row::serialize_row(value, btree::get_leaf_node_cell_value(node, c_cursor.cell_num));
}

module toy_db_in_c3;

import std::io;
import libc;

import row;
import cursor;
import pager;
import table;
import btree;


enum StatementType {
	STATEMENT_UNKNOWN,
	STATEMENT_SELECT,	
	STATEMENT_INSERT
}

enum MetaCommandResult {
	COMMAND_NOT_FOUND,
	COMMAND_SUCCESS
}

enum ExecuteResult {
	EXECUTE_SUCCESS,
	EXECUTE_FAIL
}

enum PrepareResult {
	PREPARE_SUCCESS,
	PREPARE_FAIL
}

struct Statement {
	StatementType type;
	String args;
}


fn void print_prompt() {io::print("db > ");}

fn MetaCommandResult run_meta_command(String input, Table* t_table) {
	switch (input) {
		case ".exit": {
			io::printn("Shutting Down..");
			table::close_db_connection(t_table);
			libc::exit(libc::EXIT_SUCCESS);

		}
		default: return COMMAND_NOT_FOUND;
	}

	return COMMAND_NOT_FOUND;
}


fn ExecuteResult execute_select(Table* t_table) {
	Row row;
	Cursor* c_cursor = cursor::get_table_start_cursor(t_table);
	defer free(c_cursor);

	while(!(c_cursor.end_of_table)){
		row::deserialize_row(cursor::get_cursor_address_value(c_cursor), &row);
		row::print_row(&row);
		cursor::advance_cursor(c_cursor);
	}

	return EXECUTE_SUCCESS;

}

fn ExecuteResult execute_insert(Statement* statement, Table* t_table){
	Cursor* c_cursor = cursor::get_table_end_cursor(t_table);
	defer free(c_cursor);
	

	String[] args = statement.args.split(" ");

	if (args.len != 3) {
		io::printn("Sorry, our toy db kinda only supports 3 columns as of now.");
		return EXECUTE_FAIL;
	}

	Row* new_row = malloc(Row.sizeof);
	if (new_row == null) {
	    io::printn("Memory allocation failed.");
	    return EXECUTE_FAIL;
	}

	void* node = pager::get_page(t_table.pager, t_table.root_page_num);
	if ((*btree::get_num_of_cells_in_node(node) >= btree::MAX_CELLS_PER_NODE)) {
	     io::printn("Table FULLLL!!!");
	     return EXECUTE_FAIL;
	}

	new_row.id = libc::atoi(args[0]);

	@pool() {
		libc::strcpy((ZString) &new_row.username, (ZString) args[1].zstr_tcopy());
		libc::strcpy((ZString) &new_row.email, (ZString) args[2].zstr_tcopy());
	};

	void* slot = cursor::get_cursor_address_value(c_cursor);
	if (slot == null) {
	    io::printn("Failed to get row slot.");
	    free(new_row);
	    return EXECUTE_FAIL;
	}

	cursor::insert_in_leaf_node(c_cursor, new_row.id, new_row);

	return EXECUTE_SUCCESS;
		
}

fn ExecuteResult run_statement(Statement* statement, Table* t_table){
	switch(statement.type) {
		case STATEMENT_SELECT: return execute_select(t_table);
		case STATEMENT_INSERT: return execute_insert(statement, t_table);
		default: return EXECUTE_FAIL;
	}	
}

fn PrepareResult prepare_statement(String input, Statement* statement) {
	if (input.len >= 6 && input[:6] == "select") {
		statement.type = STATEMENT_SELECT;
		return PREPARE_SUCCESS;
	}

	if (input.len >= 6 && input[:6] == "insert") {
		statement.type = STATEMENT_INSERT;

		if (input.len == 6) {
			io::printn("Insert Statement requires args.");
			return PREPARE_FAIL;
		}
		statement.args = input[6 .. input.len - 1].trim();

	}
	return PREPARE_SUCCESS;
}

fn int main(String[] args)
{
	btree::print_constants();
	//Table* t_table = table::open_db_connection("test.db");	
	//for(;;) {
	//  @pool() {
	//    print_prompt();
	//    String line = io::treadline()!!;
	//    if(line[0] == '.') {
	//	switch(run_meta_command(line, t_table)) {
	//		case COMMAND_SUCCESS: continue;
	//		case COMMAND_NOT_FOUND: continue;
	//		default: continue;
	//	}
	//    }

	//    Statement* statement = malloc(Statement.sizeof);
	//    statement.type = STATEMENT_UNKNOWN;
	//    prepare_statement(line, statement);

	//    run_statement(statement, t_table);
	//    
	//    io::printn(statement.type);
	//  };
	//}

	return 1;
}
